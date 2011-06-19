//
//  myAVRdebugger.h
//  debugger
//
//  Created by Matt Poppe on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "usbDriver.h"

#define kXPLAINDEBUGGER_PRODID		0x2335
#define	kRAVENUSBDEBUGGER_PRODID	0X2334
#define kATMEL_VENID				0x03EB

#define	knumOfLeds	3


@interface myAVRdebugger : usbDriver {

	
}

enum zigbee_subTask
{
    packet_qty = 0x01,
    packet_first = 0x02,
};


+ (NSArray *)usbDescriptor;
- (id)init;
- (void)ledOn:(UInt8)num;
- (void)ledOff:(UInt8)num;
- (BOOL)ledsAvail;
- (BOOL)initLeds;

//Alarms
- (BOOL)alarmsAvail;
- (void)checkForAlarms;
- (void)getFirstAlarm;


//Zigbee
-(BOOL)zigbeeAvail;
-(BOOL)zigbeeDeviceInfo;
-(void)checkZigbee;
-(void)getFirstZigbee;
@end
