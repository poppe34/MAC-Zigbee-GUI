//
//  usbController.m
//  debugger
//
//  Created by Matt Poppe on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "usbCentral.h"
#import "usbInfo.h"
//Drivers
#import "defaultDevice.h"
#import "myAVRdebugger.h"

#import "usbDriver.h"
#include "myTypes.h"
#include <IOKit/IOMessage.h>


void DeviceAdded(void *refCon, io_iterator_t iterator);
void DeviceRemoved( void *refCon,io_service_t service,natural_t messageType,void *messageArgument );

@interface usbCentral (Private)


- (void)debuggerFound:(usbInfo *)info;


@end

@implementation usbCentral
@synthesize devices, devicesInfo, usbName, delegate;



- (id)init
{
	if ( (self = [super init]) ) 
	{
		devicesInfo = [[NSMutableArray alloc]init];
		devices = [[NSMutableArray alloc]init];
		
		displayError(8, "usbCentral Has Initlilized", "(usbCentral)init" );
	}
	
	
	return self;
}
- (void)awakeFromNib
{
	[self startRegistration];

}

- (void)startRegistration
{
	
	[self registerDevice:[defaultDevice class]];
	[self registerDevice:[myAVRdebugger class]];
	[self startupUSBdrivers];
}
- (void)registerDevice:(Class)driver
{
	NSArray *arr = [driver usbDescriptor];
	
	
	for(UInt8 x=0; x<[arr count]; x++) 
	{	
		NSDictionary *dic = [arr objectAtIndex:x];
		usbInfo *info = [[usbInfo alloc]init];
		
		info.name = [dic objectForKey:@"name"];
		info.venId = [[dic valueForKey:@"vendorID"] longValue];
		info.prodId = [[dic objectForKey:@"productID"] longValue];
		info.driverClass = driver;
		//info.driver = [driver 
		[devicesInfo addObject:info];
		info.central = self;
		printf("Hello Matt Vendor ID:%ld Product ID:%ld\n", info.venId, info.prodId);
	}
	
}


- (void)startupUSBdrivers
{
	IOReturn						err = 0;
    io_service_t					usbDeviceRef=IO_OBJECT_NULL;
	CFMutableDictionaryRef			myDictionaryRef = 0;
	UInt32							prodID;
	UInt32							vendID;
	CFNumberRef						CFvalue;
	io_iterator_t					iterator = 0;
	mach_port_t						myMasterPort = 0;
	CFRunLoopSourceRef				runLoopSource;
	usbInfo*						info;
	
	err = IOMasterPort(MACH_PORT_NULL, &myMasterPort);
	IO_ERR(3, "(usbCentral)startupUSBdrivers: Return a Master Port", err);
	
	//Get a notification port, get its event source and connect it to the current thread
    notifyPort = IONotificationPortCreate(myMasterPort);
	if (!notifyPort) displayError(3, "I didn't get a notify port", "startupUSBdrivers");
	
    runLoopSource = IONotificationPortGetRunLoopSource(notifyPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
	
	
	for(int x=0; x<[devicesInfo count]; x++)
	{
	
		info = (usbInfo *)[devicesInfo objectAtIndex:x];
		vendID = info.venId;
		prodID = info.prodId;
		NSLog(@"Vendor ID: %ld Product ID: %ld", info.venId, info.prodId);
		
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
		
		err = IOServiceAddMatchingNotification(notifyPort,
											   kIOFirstMatchNotification,
											   myDictionaryRef,
											   DeviceAdded,
											   info,
											   &iterator);
	
	
		//Get the matching services
		//err = IOServiceGetMatchingServices(myMasterPort, myDictionaryRef, &iterator);	
		IO_ERR(3, "(usbCentral)startupUSBdrivers: Get IO Service Matching", err);
	
		myDictionaryRef = 0;
		DeviceAdded(info, iterator);
		while ( (usbDeviceRef = IOIteratorNext(iterator)) ) 
		{
			displayError(3, "Hello USB", "connectUSB");
			[self.devices addObject:info];
			
		}
		IOObjectRelease(usbDeviceRef);
	
	}
	
	mach_port_deallocate(mach_task_self(), myMasterPort);
	
	if([self.devices count]==0){
		//[self debuggerFound:[devicesInfo objectAtIndex:0]];
	}
	
}
void DeviceAdded(void *refCon, io_iterator_t iterator)
{
	displayError(8, "Device Added Callback Executed","(usbCentral):DeviceAdded");
	usbInfo *info = (usbInfo *)refCon;
	
	if(info) [info.central deviceAdded:info withIterator:iterator];
					
}
	 
- (void)deviceAdded:(usbInfo *)info
	   withIterator:(io_iterator_t)iterator
{
	IOReturn		err;
	io_service_t	usbDev;
	io_object_t		notification;
	
	while ((usbDev = IOIteratorNext(iterator))){
		displayError(8, "New Device Added", "(usbCentral):deviceAdded");
	
        //Setup our data object we use to track the device while it is plugged
		
        //Request notification if the device is unplugged
     err = IOServiceAddInterestNotification(notifyPort,
                                               usbDev,
                                               kIOGeneralInterest,
                                               DeviceRemoved,
                                               info,
                                               &notification);
	IO_ERR(3, "(usbCentral)deviceAdded: Register for notification", err);
	
	//[dev release];
	//IOObjectRelease(usbDev);
	info.driver = [[info.driverClass alloc]initWithService:usbDev];
	[self debuggerFound:info];
	}
	
}
	
void DeviceRemoved( void *refCon,io_service_t service,natural_t messageType,void *messageArgument ) 
{		
	usbInfo *info = (usbInfo *)refCon;
	if (messageType!=kIOMessageServiceIsTerminated) return;
    if (info)
	{
	
	if(info) NSLog(@"Good Bye: %@", (info.name));
	
		[info.central deviceRemoved:info];
		
	}
}

- (void)deviceRemoved:(usbInfo *)info
{
	usbInfo *defaultInfo = [devicesInfo objectAtIndex:0];
    
    displayError(8, "Device Was Removed", "(usbCentral):deviceRemoved");
    
	[self debuggerLost:defaultInfo];
}


/*
- (IBAction)connectToUSB:(id)sender
{
	outBuf[0] = 0x01;
	outBuf[1] = 0x01;
	outBuf[2] = 0x00;
	outBuf[3] = 0x00;
	outBuf[4] = 0x00;
	outBuf[5] = 0x00;
	outBuf[6] = 0x00;
	outBuf[7] = 0x00;
	device = connectUSB();
	alarmIntf = getInterface(device, 1);
	if (!alarmIntf) {
		printf("I didn't get my alarm Interface");
	}
	

	if(!zigbeeIntf) printf("I didn't get my zigbee Interface");
	//NSLog(@"This is the Zigbee Interface: %@", device);
	
		
}

- (void)dummySend
{

	
	
	//memset(data, 0, 8);
	

	
	
	
}*/


- (void)debuggerFound:(usbInfo *)info
{
	if (delegate) {
        if ([delegate respondsToSelector:@selector(debuggerFound:)]) {
            [delegate debuggerFound:info];
        }
    }else {
		NSLog(@"no Delegate established");
	}

}
- (void)debuggerLost:(usbInfo *)info
{
	if (delegate) {
        if ([delegate respondsToSelector:@selector(debuggerLost:)]) {
            [delegate debuggerLost:info];
        }
    }else {
		NSLog(@"no Delegate established");
	}
	
}
@end
