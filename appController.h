//
//  appController.h
//  debugger
//
//  Created by Matt Poppe on 2/18/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "usbDriver.h"
#import "usbCentral.h"
#import "zigbee_deviceController.h"

@class usbCentral, alarmLog, packets;

@interface appController : NSObject <usbCentralDelegate>{
	usbDriver *driver;
	usbCentral *central;
    zigbee_deviceController *zigDevice;
    
	IBOutlet alarmLog *log;
	IBOutlet packets *zigPackets;

    volatile BOOL isAlarmChecking;
	
	NSButton *led1, *led2, *led3;
	NSTextField *usbName, *usbCheck;
}

@property(retain) usbDriver *driver;
@property(retain) usbCentral *central;
@property(assign) IBOutlet zigbee_deviceController *zigDevice;
@property(assign) IBOutlet NSButton *led1, *led2, *led3;
@property(assign) IBOutlet NSTextField *usbName, *usbCheck;

- (IBAction)ledToggle1:(id)sender;
- (IBAction)ledToggle2:(id)sender;
- (IBAction)ledToggle3:(id)sender;
- (IBAction)connectToUSB:(id)sender;
- (IBAction)readUSB:(id)sender;
- (IBAction) checkZigbeeButton:(id)sender;
- (void)checkZigbee;
- (void)runningCheckAlarms;
- (void)checkUSBAllTypes;


@end
