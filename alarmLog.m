//
//  alarmLog.m
//  debugger
//
//  Created by Matt Poppe on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "alarmLog.h"

@implementation alarmLog

-(id) init{
	if((self = [super init]))	{alarmLogArray = [[NSMutableArray alloc]init];}
	
    
	return self;
}

-(void)dealloc{
	[alarmLogArray release];
	[super dealloc];
}

@synthesize alarmLogArray;

-(NSMutableArray *)alarms{
	return alarmLogArray;
}

-(void)setAlarms:(NSArray *)newLog{
	if (alarmLogArray != newLog)
    {
        [alarmLogArray autorelease];
		alarmLogArray = [[NSMutableArray alloc] initWithArray: newLog];
    }
}

- (IBAction)ackAlarm:(id)sender
{
	MyAlarms *selAlarm =  [self.alarms objectAtIndex:[alarmView selectedRow]];
	[selAlarm ackAlarm];
	
	
}

- (NSInteger)numNonAckAlarms:(int)rows
{
	NSInteger notAckCount = 0;
	ackStatus_t alrmStatus;
	for(int x=0; x<rows; x++){
		alrmStatus = [[self.alarmLogArray objectAtIndex:x] status];
		if ( (alrmStatus == activeNotAckd) || (alrmStatus == notActiveNotAckd) ){
			notAckCount++;
		}
	}
	[totalUnackAlarmsText setStringValue:[NSString stringWithFormat:@"Total Unack Alarms: %i", notAckCount]];
	return notAckCount;
}

- (void)addAlarmWithAlarm:(MyAlarms *) alrm{
	[self.alarmLogArray addObject:alrm];
}

- (void)newAlarmWithString:(char *)str
					length:(NSUInteger)len
{
	MyAlarms *newAlarm = [[MyAlarms alloc]init];
	NSString *alrmString;
	if(*str) 
	{
		alrmString = [NSString stringWithUTF8String:str];
        [newAlarm.alarmDiction setObject:alrmString forKey:@"alarmValue"];
	
        [self.alarmLogArray addObject:newAlarm];

        [alarmView reloadData];
	}
}

- (void)removeAlarm:(MyAlarms *)alrm
{
    [alarmLogArray removeObject:alrm];
    [alrm release];
    [alrm dealloc];
}

-(IBAction) buttonAddAlarm:(id)sender{
	MyAlarms *newAlrm = [[MyAlarms alloc]init];
	[self addAlarmWithAlarm:newAlrm];
	[alarmView reloadData];
   // [alarmView selectRow: ([alarmLogArray count] - 1) byExtendingSelection: NO];

}

-(void)deactivateAlarm:(MyAlarms *)alrm{

}

-(void)ackAlarms:(MyAlarms *)alrm{
	MyAlarms *selAlarm;
    uint8_t cnt = [alarmLogArray count];
    
    for (uint8_t x = 0; x<cnt; x++) {
        selAlarm = [self.alarms objectAtIndex:x];
        [selAlarm ackAlarm];
    }	
}
				
				
- (int)numberOfRowsInTableView:(NSTableView *)tableView{
	
	int rows = [alarmLogArray count];
	
	[totalAlarmsText setStringValue:[NSString stringWithFormat:@"Total Alarms: %i", rows]];
	
	[self numNonAckAlarms:rows];

	return rows;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	 
	NSString * key = [tableColumn identifier];
	
	MyAlarms *thisAlarm = [alarmLogArray objectAtIndex: row];
	
	
	return[thisAlarm.alarmDiction objectForKey:key];
	
	
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	
	[alarmView reloadData];
	
}

- (IBAction)clearAlarms:(id)sender
{
	[self.alarmLogArray removeAllObjects];
	[alarmView reloadData];
}
@end
