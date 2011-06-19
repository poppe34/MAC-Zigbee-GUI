//
//  alarmLog.h
//  debugger
//
//  Created by Matt Poppe on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyAlarms.h"

@interface alarmLog : NSObject {

	NSMutableArray *alarmLogArray;
	
	IBOutlet id alarmView;
	IBOutlet id totalUnackAlarmsText;
	IBOutlet id totalAlarmsText;
	
	
}

- (id)init;
- (void)dealloc;
- (IBAction)ackAlarm:(id)sender;
- (IBAction)clearAlarms:(id)sender;
- (void)newAlarmWithString:(char *)str
					length:(NSUInteger)len;
- (IBAction) buttonAddAlarm:(id)sender;

- (NSInteger)numNonAckAlarms:(int)rows;
//- (void)addAlarm:(MyAlarms *)alrm;
- (void)ackAlarms:(MyAlarms *)alrm;
- (void)deactivateAlarm:(MyAlarms *)alrm;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
//d- (int)numberofUnackAlarms:(NSInteger)count;
- (void)removeAlarm:(MyAlarms *)alrm;


@property(assign) NSMutableArray *alarmLogArray;

@end
