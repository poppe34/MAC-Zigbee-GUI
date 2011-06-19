//
//  packets.m
//  debugger
//
//  Created by Matt Poppe on 4/24/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "packets.h"
#import "zigPacket.h"

@implementation packets


@synthesize zigbeePackets, addAlarm;

- (id)init
{
    self = [super init];
    if (self) 
    {
        zigbeePackets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [zigbeePackets release];
    [super dealloc];
}


- (int)numberOfRowsInTableView:(NSTableView *)tableView{
	
	int rows = [self.zigbeePackets count];
        
    [totalPacketsString setStringValue:[NSString stringWithFormat:@"Total Packets: %i", rows]];
    
	return rows;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
	NSString *key = [tableColumn identifier];
	
	zigPacket *thisPacket = [self.zigbeePackets objectAtIndex:row];
    
	return[thisPacket.zigPacketDiction objectForKey:key];
	
	
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{   
    int8_t row = [zigbeeView selectedRow];
    if (row >= 0) {
        
    [self verboseZigbeePacket:[self.zigbeePackets objectAtIndex:row]
                  rowSelected:row];
	}
    else
    {
        [zigbeeOutputView setStringValue:@" "];   
    }
	[zigbeeView reloadData];
	
}
- (IBAction)addPacketButton:(id)sender
{
    zigPacket *newPack = [[zigPacket alloc]init];
    
    [self.zigbeePackets addObject:newPack];
    
    [zigbeeView reloadData];
}
- (void)addPacketWithData:(voidPtr)pkt
{
    uint8_t length = (*((uint8_t *)pkt)-3);

    NSLog(@"The length of the packet is :%i", length);
    
    zigPacket *newPack = [[zigPacket alloc]initWithData:(pkt+3)
                                                 length:length];
    
    [newPack.zigPacketDiction setObject:([[NSNumber alloc]initWithInt:([zigbeePackets count]+1)]) forKey:@"packetNum"];
    [self.zigbeePackets addObject:newPack];
    
    [zigbeeView reloadData];
}
- (void)newPacket:(voidPtr)pkt
{
    
}

- (void)verboseZigbeePacket:(zigPacket *)pkt
                rowSelected:(int)row    
{
    NSRange endRange;
    
    if ([zigbeeView isRowSelected:row]) 
    {
        if(!pkt.decodedMACStr)
        [zigbeeOutputView setStringValue:@"I am just trying to get this to work"];
        else
        {
            if([macLayerDecodeTgl state])
                {
                    [zigbeeOutputView setStringValue:pkt.decodedMACStr];
                    
                    endRange.location = [[zigbeeTextView textStorage] length];
                    
                    endRange.length = 0;
                    
                    [zigbeeTextView setString:(pkt.packetStr)];// withString:(pkt.packetStr)];
                    
                    endRange.length = [(pkt.packetStr) length];
                    
                    [zigbeeTextView scrollRangeToVisible:endRange];
                }
            if([nwkLayerDecodeTgl state]) 
                [zigbeeOutputView setStringValue:pkt.decodedNWKStr];
            if([apsLayerDecodeTgl state])
                [zigbeeOutputView setStringValue:pkt.decodedAPSStr];
        }
    }
    
    else
        [zigbeeOutputView setStringValue:@""];
}
- (IBAction)decodeMacSelected:(id)sender
{
    NSInteger temp = 0;
    int8_t row = [zigbeeView selectedRow];
    
    if([[sender title] isEqualToString:@"NWK Layer"]) 
    {
        [macLayerDecodeTgl setState:temp];
        [apsLayerDecodeTgl setState:temp];
    }
    if([[sender title] isEqualToString:@"MAC Layer"]) 
    {
        [nwkLayerDecodeTgl setState:temp];
        [apsLayerDecodeTgl setState:temp];
    }
    if([[sender title] isEqualToString:@"APS Layer"]) 
    {
        [nwkLayerDecodeTgl setState:temp];
        [macLayerDecodeTgl setState:temp];
    }
    if (row >= 0) 
    [self verboseZigbeePacket:[self.zigbeePackets objectAtIndex:row]
                  rowSelected:row];
    // NSLog(@"Looking at row %i",row);

}
@end
