//
//  packets.h
//  debugger
//
//  Created by Matt Poppe on 4/24/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <cocoa/Cocoa.h>

@class zigPacket;

@interface packets : NSObject {
    
    NSMutableArray *zigbeePackets;
    
    IBOutlet id zigbeeView;
    IBOutlet NSButton *addAlarm;
    IBOutlet id totalPacketsString;
    IBOutlet id zigbeeOutputView;
    IBOutlet NSButton *macLayerDecodeTgl, *nwkLayerDecodeTgl, *apsLayerDecodeTgl;
    IBOutlet NSTextView *zigbeeTextView;


}

@property(assign) NSMutableArray *zigbeePackets;
@property(assign) IBOutlet NSButton *addAlarm;

- (id)init;
- (IBAction)addPacketButton:(id)sender;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (void)verboseZigbeePacket:(zigPacket *)pkt
                rowSelected:(int)row;    
- (IBAction)decodeMacSelected:(id)sender;
- (void)newPacket:(voidPtr)pkt;
- (void)addPacketWithData:(voidPtr)pkt;

@end
