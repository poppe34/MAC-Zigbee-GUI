//
//  usbController.h
//  debugger
//
//  Created by Matt Poppe on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import	"usbHeaders.h"
#include <CoreFoundation/CFNumber.h>

@class usbInfo;

@protocol usbCentralDelegate
@optional
- (void)debuggerFound:(usbInfo *)info;
- (void)debuggerLost:(usbInfo *)info;
- (void)deviceFound:(usbInfo *)info;
@end


IOUSBDeviceInterface320 ** device;                // An interface to the device
IOUSBInterfaceInterface300 ** alarmIntf; // An interface to the control interface
IOUSBInterfaceInterface300 ** zigbeeIntf;



IONotificationPortRef notifyPort;	//Port for notifications from IOKit to mainThread


@interface usbCentral : NSObject {

	NSMutableArray *devicesInfo;
	NSMutableArray *devices;

	id delegate;
	
}

@property(copy) NSMutableArray *devicesInfo, *devices;
@property(assign) IBOutlet NSTextField *usbName;
@property(assign) IBOutlet id delegate;

- (id)init;
- (void)startRegistration;
- (void)registerDevice:(Class)driver;
- (void)startRegistration;
- (void)deviceAdded:(usbInfo *)info
	   withIterator:(io_iterator_t)iterator;
- (void)startupUSBdrivers;
//- (void)dummySend; May not need delete in the future if I don't want it
- (void)deviceRemoved:(usbInfo *)info;
- (void)debuggerLost:(usbInfo *)info;

@end


