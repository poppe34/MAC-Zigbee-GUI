//
//  myUSB.m
//  debugger
//
//  Created by Matt Poppe on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "myUSB.h"

IOUSBDeviceInterface320 ** connectUSB(void)
{
	IOReturn						err = 0;
    io_service_t					usbDeviceRef=IO_OBJECT_NULL;
	CFMutableDictionaryRef			myDictionaryRef = 0;
	UInt32							prodID=	kProductID;
	UInt32							vendID= kVendorID;
	CFNumberRef						CFvalue;
	io_iterator_t					iterator = 0;
	IOUSBDeviceInterface320			**dummy;
	mach_port_t						myMasterPort = 0;
	
	// Request master port

	err = IOMasterPort(MACH_PORT_NULL, &myMasterPort);
	
	IO_ERR(3, "connectUSB: Failed to return a Master Port", err);
	
	//setup a matching dictionary to find the device in the IO registry
	
	myDictionaryRef = IOServiceMatching(kIOUSBDeviceClassName);
	
	//if (!myDictionaryRef && usbDebug) NSLog(@"Failed to return a dictionary reference");
	
	CFvalue = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &prodID);
	
	//if (!CFvalue && usbDebug) NSLog(@"Failed to return a CF Number");
	
	CFDictionaryAddValue(myDictionaryRef, CFSTR(kUSBProductID), CFvalue);
	CFRelease(CFvalue);
	
	CFvalue = 0;
	
	CFvalue = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &vendID);
	
	//if (!CFvalue && usbDebug) NSLog(@"connectUSB: Failed to return a CF Number");
	
	CFDictionaryAddValue(myDictionaryRef, CFSTR(kUSBVendorID), CFvalue);
	CFRelease(CFvalue);
	
	//Get the matching services
	err = IOServiceGetMatchingServices(myMasterPort, myDictionaryRef, &iterator);	
	IO_ERR(3, "connectUSB: Get IO Service Matching", err);
	
	myDictionaryRef = 0;
	
	while ( (usbDeviceRef = IOIteratorNext(iterator)) ) 
    {
		dummy = getDevice(usbDeviceRef);
		IOObjectRelease(usbDeviceRef);
	}
	

	//mach_port_deallocate(mach_task_self(), myMasterPort);

	displayError(3, "Hello USB", "connectUSB");
	
	return dummy;
}

IOUSBDeviceInterface320 ** getDevice(io_service_t usbDevice){
	IOReturn				err;
	IOUSBDeviceInterface320 **dummy;
	IOCFPlugInInterface		**iodev;		// requires <IOKit/IOCFPlugIn.h>
	SInt32					score;
	displayError(3, "Found Device", "connectUSB");
	
	//Get Plugin Interface
	err = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
	IO_ERR(3, "connectUSB: Create Plugin Interface for usbDevice",err);
	
	//query plugin for usb device
	err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID320), (LPVOID)(&dummy));
	IO_ERR(3, "connectUSB: Query Plugin for Device Interface", err);
	
	//release the IOPlugin 
	(*iodev)->Release(iodev);
	return dummy;
}
IOUSBInterfaceInterface300 ** getInterface(IOUSBDeviceInterface320 **dev, UInt8 num)
{
	
	IOReturn						err;
	io_service_t					interfaceRef;
    IOUSBFindInterfaceRequest		interfaceRequest;
	IOUSBConfigurationDescriptorPtr configDesc;
	io_iterator_t					iterator = 0;
	UInt32							locID;
	UInt8							numConf;
	IOUSBInterfaceInterface300		**dummy; // An interface to the control interface
	
	err = (*dev)->GetLocationID(dev, &locID);
	IO_ERR(3, "connectUSB: Get Location ID of the USB", err);
						  
	if(err) return dummy;
						  
	for (int x = 0; x<10; x++) 
	{
		err = (*dev)->USBDeviceOpen(dev);
		IO_ERR(3, "connectUSB: Open USB Device", err);
		if (err!=kIOReturnExclusiveAccess) break;	//Loop only if the device is busy
		usleep(500000);
	}
	if(err) return dummy;		
	
	// Get the number of configurations	
	err = (*dev)->GetNumberOfConfigurations(dev, &numConf);
	//NSLog(@"Number of Configurations: %d", numConf);
	IO_ERR(3, "usbConnect: get number of configurations", err);
	
	
	// Get the configuration descriptor pointer
	err = (*dev)->GetConfigurationDescriptorPtr(dev, 0, &configDesc);
	IO_ERR(3, "usbConnect: get the configuration descriptor pointer",err);	
						  
	// Set the Configureation value
	err = (*dev)->SetConfiguration(dev, configDesc->bConfigurationValue);
	IO_ERR(3, "usbConnect: Set the configuration",err);
	/*					  
	// Reset the device
	err = (*dev)->ResetDevice(dev);
	IO_ERR(3, "usbConnect: Reset Device", err);
	*/					  
	if(err) return dummy;				  
						  
	//IOObjectRelease(iterator);
	iterator = 0;
						
	interfaceRequest.bInterfaceClass =kIOUSBFindInterfaceDontCare;
	interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;
	interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
	interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
						  
	// take an iterator over the device interfaces...
	err = (*dev)->CreateInterfaceIterator(dev, &interfaceRequest, &iterator);
	IO_ERR(3, "connectUSB: Create Interface Iterator", err);
	
	for (int x=0; x<num; x++) {
		
	interfaceRef = IOIteratorNext(iterator);
	}
	//if (!interfaceRef && usbDebug) NSLog(@"I didn't get a usb interface Ref");
						  
	interfaceInteraction(&dummy, interfaceRef);
	
	return dummy;
					
}
void interfaceInteraction(IOUSBInterfaceInterface300*** intfPtr, io_service_t Ref)
{	
	IOCFPlugInInterface	**iodev;
	SInt32				score;
	IOReturn			err;
	UInt8				interfaceClass, direction, number, transfertype, interval;
	UInt8				interfaceSubClass, interfaceNumEndpoints, interfaceNumber;
	UInt16				maxPacketSize;
	int					pipeRef = 1;
	char				*message;
	
	err = IOCreatePlugInInterfaceForService(Ref, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
	IO_ERR(3, "openInterface: Create Plugin Interface for usbInterface", err);
	
	//query plugin for device interface
	err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID300), (LPVOID)intfPtr);
	IO_ERR(3, "openInterface: Query Plugin for Device Interface", err);
	
	err = (**intfPtr)->GetInterfaceNumber(*intfPtr, &interfaceNumber);
	IO_ERR(3, "openInterface: Get Interface Number", err);
	//NSLog(@"Interface Number: %d", interfaceNumber);
	
	//err = (**intfPtr)->GetPipeStatus(*intfPtr);
	//ERR(self.usbDebug, "openInterface: Pipe Status", err);
	err = (**intfPtr)->USBInterfaceOpen(*intfPtr);
	IO_ERR(3, "openInterface: Open Interface port", err);
	
	err = (**intfPtr)->GetInterfaceClass(*intfPtr, &interfaceClass);
	err = (**intfPtr)->GetInterfaceSubClass(*intfPtr, &interfaceSubClass);
	//NSLog(@"OpenInterface: interface Class:%d Interface Sub Class:%d", interfaceClass, interfaceSubClass);

	err = (**intfPtr)->GetNumEndpoints(*intfPtr, &interfaceNumEndpoints);
	//NSLog(@"OpenInterface: Number of Endpoints is:%d", interfaceNumEndpoints);
	
	for(pipeRef = 1; pipeRef <= interfaceNumEndpoints; pipeRef++)
	{	
	
		err = (**intfPtr)->GetPipeProperties(*intfPtr, pipeRef, &direction, &number, &transfertype, &maxPacketSize, &interval);
		IO_ERR(3, "openInterface: Get Pipe Properties",err);
		printf("Pipe Reference number:%d, ", pipeRef);
		switch (direction) 
		{
			case kUSBOut:
				message = "out";
				break;
			case kUSBIn:
				message = "in";
				break;
			case kUSBNone:
				message = "none";
				break;
			case kUSBAnyDirn:
				message = "any";
				break;
			default:
				message = "???";
				break;
		}
		
			printf("direction:%s, ", message);
	
		switch (transfertype) 
		{
			case kUSBControl:
				message = "control";
				break;
			case kUSBIsoc:
				message = "isoc";
				break;
			case kUSBBulk:
				message = "bulk";
				break;
			case kUSBInterrupt:
				message = "interrupt";
				break;
			case kUSBAnyType:
				message = "any";
				break;
			default:
				message = "???";
				break;
		}
		printf("transfer type:%s, Pipe Number:%d maxPacketSize:%d, Intervals:%d\n", message, number, maxPacketSize,interval);
	
		if (transfertype == kUSBBulk && direction == kUSBIn) 
		{
			//alarmInPipeRef = number;
		}else if (transfertype == kUSBBulk && direction == kUSBOut) 
		{
			//alarmOutPipeRef = number;
		}
	
	}	
	(*iodev)->Release(iodev);
	
}
							
IOReturn asyncTransferData(IOUSBInterfaceInterface300 ***intf, char *outBuf, int len){
	
    IOReturn				err;
    CFRunLoopSourceRef		cfSource;
    

    err = (**intf)->CreateInterfaceAsyncEventSource(*intf, &cfSource);
    IO_ERR(3, "transferData: Create Interface Async Event Source", err);

    CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
  
    err = (**intf)->WritePipeAsync(*intf, 2, outBuf, 8, (IOAsyncCallback1)asyncWriteCB, (void*)(UInt32)1);
    IO_ERR(3, "transferData: Write Async Pipe", err);
	if (err) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
		return err;
	}
    CFRunLoopRun();
    displayError(3, "returned from CFRunLoopRun", "transferData");
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
	
	return err;
}

void asyncWriteCB(void *dummy, IOReturn result, void *arg0)
{
	//  UInt8	inPipeRef = (UInt32)dummy;
    IO_ERR(3, "asyncWriteCB: Did it work", result);
    printf("MyCallbackfunction: %d, %d\n", (int)dummy, (int)arg0);
    CFRunLoopStop(CFRunLoopGetCurrent());
}




