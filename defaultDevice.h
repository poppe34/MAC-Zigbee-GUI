//
//  defaultDevice.h
//  debugger
//
//  Created by Matt Poppe on 2/21/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "usbDriver.h"

#define kDefaultProdID	0
#define kDefaultVendID	0
#define kDefaultName	@"No Device is Connected at this time"
@interface defaultDevice : usbDriver {

}
/*
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
-(void)checkZigbee;
-(void)getFirstZigbee;
 
 */
@end
