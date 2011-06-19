//
//  MyAlarms.h
//  debugger
//
//  Created by Matt Poppe on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _ackStatus{
	activeNotAckd,
	activeAckd,
	notActiveNotAckd,
	notActiveAckd,
}ackStatus_t;


@interface MyAlarms : NSObject {


	NSMutableDictionary *alarmDiction;
	ackStatus_t status;
	
}
- (id)init;
- (void)dealloc;
- (void)ackAlarm;

@property(retain) NSMutableDictionary *alarmDiction;

@end
