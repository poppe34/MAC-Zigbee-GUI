//
//  MyAlarms.m
//  debugger
//
//  Created by Matt Poppe on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAlarms.h"



@implementation MyAlarms

- (id)init{
	if ((self = [super init])) {
		status = activeNotAckd;
		NSArray *keys = [NSArray arrayWithObjects:@"alarmTimestamp", @"alarmValue", @"alarmColor",nil];
		NSArray *values = [NSArray arrayWithObjects:@"Waynes", @"World", [NSColor redColor], nil];
		alarmDiction = [[NSMutableDictionary alloc]initWithObjects:values forKeys:keys];

		NSLog(@"Alarm Added");
	}
	
	return self;
}

- (void)dealloc{
	[alarmDiction release];
	
	[super dealloc];
}



- (void)ackAlarm{
	status = activeAckd;
	[alarmDiction setObject:[NSColor greenColor] forKey:@"alarmColor"];
}

- (ackStatus_t)status{
	return status;
}
@synthesize alarmDiction;

@end
