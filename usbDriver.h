//
//  usbDriver.h
//  debugger
//
//  Created by Matt Poppe on 2/16/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "usbHeaders.h"
#include "myTypes.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

typedef enum{
	task_none 	= 0x00,
	task_LED 	= 0x01,
	task_alarm	= 0x02,
	task_zigbee	= 0x03,
}debugger_task_t;

typedef enum alarmTask{
	alarm_none = 0x00,
	alarm_new = 0x01
}alarmTask_t;

typedef enum ledOperation{
	led_off		= 0x00,
	led_on		= 0x01,
	led_toggle	= 0x02,
	led_status	= 0x03,
	led_report	= 0x04
}ledOperation_t;

@class usbInfo, MyAlarms;
@protocol usbDriverDelegate
@optional
- (void) newAlarm:(MyAlarms *)alarm;

@end

@interface usbDriver : NSObject {
	
	IOUSBInterfaceInterface300 ** alarmIntf;
	IOUSBDeviceInterface320 ** dev;

	id delegate;
}

@property(assign) id delegate;

//initlize Methods
- (id)init;
- (id)initWithService:(io_service_t)usbDev;

//USB Device Methods
- (void)newAlarm:(MyAlarms *)alarm;
- (void)ledOn:(UInt8)num;
- (void)ledOff:(UInt8)num;
- (BOOL)ledsAvail;

    /* Alarms */
- (BOOL)alarmsAvail;
- (void)checkForAlarms;
- (void)getFirstAlarm;
    
    /* Zigbee */
-(BOOL)zigbeeAvail;
-(BOOL)zigbeeDeviceInfo;
-(void)checkZigbee;
-(void)getFirstZigbee;

//USB Methods
- (void)getDevice:(io_service_t)usbDevice;
- (void)getInterface;
- (void)interfaceInteraction:(IOUSBInterfaceInterface300***)intfPtr
					 service:(io_service_t)Ref;
- (BOOL)transferData:(char *)buf
			  length:(UInt32)num;
- (void)readUSB_TEMP:(voidPtr)buf;

//Available periphials
-(BOOL)ledsAvail;
-(BOOL)alarmsAvail;
-(BOOL)zigbeeAvail;

@end
