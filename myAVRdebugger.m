//
//  myAVRdebugger.m
//  debugger
//
//  Created by Matt Poppe on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "myAVRdebugger.h"
#import "usbDriver.h"

static char		outBuf[8096];
char			inBuf[8096];

@implementation myAVRdebugger


+ (NSArray *)usbDescriptor
{
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys: 
			 [NSNumber numberWithLong:kXPLAINDEBUGGER_PRODID], @"productID",
			 [NSNumber numberWithUnsignedShort:kATMEL_VENID], @"vendorID",
			 [NSString stringWithString:@"AVR XPLAIN SERIES USED AS A DEBUGGER"], @"name", NULL], 
			
			[NSDictionary dictionaryWithObjectsAndKeys: 
			 [NSNumber numberWithUnsignedShort:kRAVENUSBDEBUGGER_PRODID], @"productID",
			 [NSNumber numberWithUnsignedShort:kATMEL_VENID], @"vendorID",
			 [NSString stringWithString:@"AVR Raven USB device"], @"name", NULL], 
			
			NULL];
}


- (id)init
{
	self = [super init];
	return self;
	
}
- (id)initWithService:(io_service_t)usbDev
{
	if((self = [super initWithService:usbDev]))
	{
		[self initLeds];
	}
	return self;
}
- (BOOL)initLeds
{
	for(int x=1; x<(knumOfLeds+1); x++) 
	{
		[self ledOff:x];
	}
	return YES;
}

- (BOOL)ledsAvail{
	return YES;
}

- (void)ledOn:(UInt8)num{
	outBuf[0] = 1;
    outBuf[1] = task_LED;
	outBuf[2] = led_on;
	outBuf[3] = num;
	
	
	NSLog(@"tried to turn on %i", num);
	[self transferData:&outBuf[0] length:4];
}
- (void)ledOff:(UInt8)num{

	outBuf[0] = 1;
    outBuf[1] = task_LED;
	outBuf[2] = led_off;
	outBuf[3] = num;
	
	
	NSLog(@"Tried to turn off %i", num);
	[self transferData:&outBuf[0] length:4];
}

- (BOOL)alarmsAvail{
	return YES;
}


- (void)checkForAlarms{
    outBuf[0] = 1;
	outBuf[1] = task_alarm;
	outBuf[2] = 1;
    outBuf[3] = 0;
	[self transferData:&outBuf[0] length:4];
}
- (void)getFirstAlarm{
    outBuf[0] = 1;
    outBuf[1] = task_alarm;
    outBuf[2] = 2;
    outBuf[3] = 0;
    [self transferData:&outBuf[0] length:4];
}
-(BOOL)zigbeeAvail;
{
    return YES;
}

-(void)checkZigbee
{
    outBuf[0] = 1;
    outBuf[1] = task_zigbee;
    outBuf[2] = packet_qty;
    outBuf[3] = 0;
    [self transferData:outBuf length:4];
}

-(void)getFirstZigbee
{
    outBuf[0] = 1;
    outBuf[1] = task_zigbee;
    outBuf[2] = packet_first;
    outBuf[3] = 0;
    [self transferData:outBuf length:4];
}

-(BOOL)zigbeeDeviceInfo
{
    return YES;
}

-(void)getShortAddr
{
    outBuf[0] = 1;
}

@end
