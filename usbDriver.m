//
//  usbDriver.m
//  debugger
//
//  Created by Matt Poppe on 2/16/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "usbDriver.h"
#import "usbInfo.h"
#import "MyAlarms.h"
#import "usbHeaders.h"


@implementation usbDriver



@synthesize delegate;

- (id)init
{
	if ((self = [super init])) {
		alarmIntf = NULL;
		dev = NULL;
	}
	return self;
}
- (id)initWithService:(io_service_t)usbDev
{
	if ((self = [super init])) 
	{
		[self getDevice:usbDev];
		[self getInterface];
		
	}
	return self;
}
- (BOOL)transferData:(char *)buf
			  length:(UInt32)num
{
    UInt32 to = 200;
    UInt32 tto = 200;
    
	if(alarmIntf){
		NSLog(@"tried to trans data %i", buf[0]);
        IOReturn err = (*alarmIntf)->WritePipeTO(alarmIntf, 2, buf, num, tto, to); 
        IO_ERR(3, "(usbDriver)transferData:Write to Pipe", err);
        return (!err) ? YES:NO;
	}
	return NO;
}

- (void)readUSB_TEMP:(voidPtr)buf
{
	IOReturn err = 0;
	UInt32 num = 64;
    UInt32 to = 0;
	if(alarmIntf){
        err = (*alarmIntf)->GetPipeStatus(alarmIntf, 1);
        IO_ERR(3, "(usbDriver):readUSB_TEMP attempt to get pipe status", err);
        
        err = (*alarmIntf)->ReadPipeTO(alarmIntf, 1, buf, &num, 500, to);
        IO_ERR(3, "(USBDriver):readUSB_TEMP attempt to read pipe with TO", err);
        
                                       
//		err = (*alarmIntf)->ReadPipe(alarmIntf, 1, buf, &num);

		
	}else 
	{
		//printf("no interface");
	}
	
	
	
}
- (void)testForDevice:(usbInfo *)info
{
	IOReturn						err = 0;
    io_service_t					usbDeviceRef=IO_OBJECT_NULL;
	CFMutableDictionaryRef			myDictionaryRef = 0;
	UInt32							prodID;
	UInt32							vendID;
	CFNumberRef						CFvalue;
	io_iterator_t					iterator = 0;
	mach_port_t						myMasterPort = 0;
	
	
	err = IOMasterPort(MACH_PORT_NULL, &myMasterPort);
	IO_ERR(3, "(usbDriver)interfaceInteraction: Get Master Port",err);
	vendID = info.venId;
	prodID = info.prodId;
		
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
    IO_ERR(3, "(usbDriver)interfaceInteraction: Get Matching Services",err);
	//IO_ERR(3, "connectUSB: Get IO Service Matching", err);
		
	myDictionaryRef = 0;
		
	while ( (usbDeviceRef = IOIteratorNext(iterator)) ) 
	{
	//	dummy = getDevice(usbDeviceRef);
		IOObjectRelease(usbDeviceRef);
	}
	
	
	mach_port_deallocate(mach_task_self(), myMasterPort);
	
	displayError(3, "Hello USB", "connectUSB");
	
}

- (void)getDevice:(io_service_t)usbDevice
{
	IOReturn				err;
	IOCFPlugInInterface		**iodev;		// requires <IOKit/IOCFPlugIn.h>
	SInt32					score;
	displayError(3, "(usbCentral)getDevice:Found Device", "connectUSB");
	
	//Get Plugin Interface
	err = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
	IO_ERR(3, "(usbCentral)getDevice: Create Plugin Interface for usbDevice",err);
	
	//query plugin for usb device
	err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID320), (LPVOID)(&dev));
	IO_ERR(3, "(usbCentral)getDevice: Query Plugin for Device Interface", err);
	
	//release the IOPlugin 
	(*iodev)->Release(iodev);
}

- (void)getInterface
{
	
	IOReturn						err;
	io_service_t					interfaceRef;
    IOUSBFindInterfaceRequest		interfaceRequest;
	IOUSBConfigurationDescriptorPtr configDesc;
	io_iterator_t					iterator = 0;
	UInt32							locID;
	UInt8							numConf;
	
	err = (*dev)->GetLocationID(dev, &locID);
	IO_ERR(3, "(usbDriver)getInterface: Get Location ID of the USB", err);
	

	for (int x = 0; x<10; x++) 
	{
		err = (*dev)->USBDeviceOpen(dev);
		IO_ERR(3, "(usbDriver)getInterface: Open USB Device", err);
		if (err!=kIOReturnExclusiveAccess) break;	//Loop only if the device is busy
		usleep(500000);
	}
	if(err) return;		
	
	// Get the number of configurations	
	err = (*dev)->GetNumberOfConfigurations(dev, &numConf);
	//NSLog(@"Number of Configurations: %d", numConf);
	IO_ERR(3, "(usbDriver)getInterface: get number of configurations", err);
	
	// Get the configuration descriptor pointer
	err = (*dev)->GetConfigurationDescriptorPtr(dev, 0, &configDesc);
	IO_ERR(3, "(usbDriver)getInterface: get the configuration descriptor pointer",err);	
	
	// Set the Configureation value
	err = (*dev)->SetConfiguration(dev, configDesc->bConfigurationValue);
	IO_ERR(3, "(usbDriver)getInterface: Set the configuration",err);
	/*					  
	 // Reset the device
	 err = (*dev)->ResetDevice(dev);
	 IO_ERR(3, "usbConnect: Reset Device", err);
	 */					  
	if(err) return;				  
	
	//IOObjectRelease(iterator);
	iterator = 0;
	
	interfaceRequest.bInterfaceClass =kIOUSBFindInterfaceDontCare;
	interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;
	interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
	interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
	
	// take an iterator over the device interfaces...
	err = (*dev)->CreateInterfaceIterator(dev, &interfaceRequest, &iterator);
	IO_ERR(3, "(usbDriver)getInterface: Create Interface Iterator", err);
	
	interfaceRef = IOIteratorNext(iterator); 
		
	
	//if (!interfaceRef && usbDebug) NSLog(@"I didn't get a usb interface Ref");
	
	[self interfaceInteraction:&alarmIntf
					   service:interfaceRef];
	
}
- (void)interfaceInteraction:(IOUSBInterfaceInterface300***)intfPtr
					 service:(io_service_t)Ref
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
	IO_ERR(3, "(usbDriver)interfaceInteraction: Create Plugin Interface for usbInterface", err);
	
	//query plugin for device interface
	err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID300), (LPVOID)intfPtr);
	IO_ERR(3, "(usbDriver)interfaceInteraction: Query Plugin for Device Interface", err);
	
	err = (**intfPtr)->GetInterfaceNumber(*intfPtr, &interfaceNumber);
	IO_ERR(3, "(usbDriver)interfaceInteraction: Get Interface Number", err);
	//NSLog(@"Interface Number: %d", interfaceNumber);
	
	//err = (**intfPtr)->GetPipeStatus(*intfPtr);
	//ERR(self.usbDebug, "openInterface: Pipe Status", err);
	err = (**intfPtr)->USBInterfaceOpen(*intfPtr);
	IO_ERR(3, "(usbDriver)interfaceInteraction: Open Interface port", err);
	
	err = (**intfPtr)->GetInterfaceClass(*intfPtr, &interfaceClass);
    IO_ERR(3, "(usbDriver)interfaceInteraction: Get Interface Class",err);
	
    err = (**intfPtr)->GetInterfaceSubClass(*intfPtr, &interfaceSubClass);
    IO_ERR(3, "(usbDriver)interfaceInteraction: Get Interface Sub Class",err);
	//NSLog(@"OpenInterface: interface Class:%d Interface Sub Class:%d", interfaceClass, interfaceSubClass);
	
	err = (**intfPtr)->GetNumEndpoints(*intfPtr, &interfaceNumEndpoints);
    IO_ERR(3, "(usbDriver)interfaceInteraction: Get Number of Endpoints Properties",err);
	//NSLog(@"OpenInterface: Number of Endpoints is:%d", interfaceNumEndpoints);
	
	for(pipeRef = 1; pipeRef <= interfaceNumEndpoints; pipeRef++)
	{	
		
		err = (**intfPtr)->GetPipeProperties(*intfPtr, pipeRef, &direction, &number, &transfertype, &maxPacketSize, &interval);
		IO_ERR(3, "(usbDriver)interfaceInteraction: Get Pipe Properties",err);
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

- (void)newAlarm:(MyAlarms *)alarm
{
	if (delegate) {
        if ([delegate respondsToSelector:@selector(newAlarm:)]) {
            [delegate newAlarm:alarm];
        }
    }	
}
- (BOOL)ledsAvail{
	return NO;
}

- (BOOL)alarmsAvail{
	return NO;
}

- (void)getFirstAlarm
{
    
}

- (void)checkForAlarms
{
    
}
-(BOOL)zigbeeAvail
{
    return NO;
}
- (void)checkZigbee
{
    
}

- (void)getFirstZigbee
{
    
}
- (void)ledOn:(UInt8)num{
	
}
- (void)ledOff:(UInt8)num{
	
}



@end
