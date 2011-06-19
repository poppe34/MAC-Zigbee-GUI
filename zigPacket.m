//
//  zPacket.m
//  debugger
//
//  Created by Matt Poppe on 4/24/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "zigPacket.h"
#import "misc_stringControl.h"
#import "stdlib.h"

@implementation zigPacket

@synthesize packetLen, zigPacketDiction, decodedMACStr, decodedNWKStr, decodedAPSStr, packetStr;
@synthesize mac_layer, nwk_layer;
@synthesize testNum;

- (id)init
{
    self = [super init];
    if (self) {


        packetLen = 0;
    
        src = [[NSNumber alloc] initWithInt:0];
        dest = [[NSNumber alloc] initWithInt:0];
        srcPanId = [[NSNumber alloc] initWithInt:0];
        destPanId = [[NSNumber alloc] initWithInt:0];
        frameType = [[NSString alloc] initWithString:@"hello"];
        self.testNum = [[NSNumber alloc] initWithInt:1232234];

        packetStr = [[NSMutableString alloc]init];

        NSArray *keys = [NSArray arrayWithObjects:@"packetNum", @"packetValue",@"packetDestAddr", @"packetDestPanId", @"packetSrcAddr", @"packetSrcPanId", nil];
        NSArray *values = [NSArray arrayWithObjects:@"Pizza", frameType, dest, destPanId, src, srcPanId, nil];
        
        zigPacketDiction = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];
        

        
        NSLog(@"Packet Added");
    }
    
    return self;
}
- (id)initWithData:(voidPtr)zig
            length:(uint8_t)len

{
    self = [self init];
    packetLen = len;
    
    for (uint8_t x=0; x<len; x++) {
        frame[x] = *(uint8_t *)zig;
        zig++;
    }
    
    if(self)
    {
          }
    
    [self zigbee_packetDisplay:frame];
    [self zigbee_breakdown:frame];
    
    return self;
}

- (void)dealloc
{
    [decodedMACStr release];
    [zigPacketDiction release];
    [super dealloc];
}

- (void)release
{
    [self dealloc];
}
- (voidPtr)zigbee_nwkBreakdown:(voidPtr)zig
{
    nwk_layer.fcf = packet_read(zig, nwk_fcf_t);
    [self zigbee_nwkFCF_breakdown];
    
    return zig;
    
}
- (voidPtr)zigbee_macBreakdown:(voidPtr)zig
{
    uint8_t *holder = zig;
    uint8_t debugging[20];
    
    for (uint8_t x = 0; x<20; x++) {
        debugging[x] = *(uint8_t *)zig++;
    }
    zig = holder;
    mac_layer.mac_fcf = packet_read(zig, mac_fcf_t);

    [self zigbee_macFCF_breakdown];
    
    mac_layer.mac_seq_num = packet_read(zig, uint8_t);
    [decodedMACStr appendFormat:@"Sequence Number: %i\n", mac_layer.mac_seq_num];
    if(self.mac_layer.mac_fcf.mac_dest_addr_mode == 0x02 || self.mac_layer.mac_fcf.mac_dest_addr_mode == 0x03)
    {
        mac_layer.destPanID = packet_read(zig, uint16_t);
        
        if(mac_layer.mac_fcf.mac_dest_addr_mode == 0x02)
        {
            mac_layer.dest_sAddr = packet_read(zig, uint16_t);
            [dest release];
            
            NSLog(@"Destination ADDR: %#.4x\n", mac_layer.dest_sAddr);
            
            dest = [[NSNumber alloc]initWithInt:mac_layer.dest_sAddr];
            [self.zigPacketDiction setObject:dest forKey:@"packetDestAddr"];

            [decodedMACStr appendFormat:@"Destination Address: %1$i (%1$#.4X)\n", mac_layer.dest_sAddr];
            
        } 
        else 
        {
            mac_layer.dest_lAddr = packet_read(zig, uint64_t);

            [dest release];
            
            NSLog(@"Destination ADDR: %#.16qx\n", mac_layer.dest_lAddr);

            dest = [[NSNumber alloc]initWithLongLong:mac_layer.dest_lAddr];
            [self.zigPacketDiction setObject:dest forKey:@"packetDestAddr"];
            [decodedMACStr appendFormat:@"Destination Address: %1$qu (%1$#.16qx)\n", self.mac_layer.dest_lAddr];
        }
        [destPanId release];
        destPanId = [[NSNumber alloc]initWithInt:mac_layer.destPanID];
        [decodedMACStr appendFormat:@"Destination Pan ID: %1$i (%1$#.4x)\n", mac_layer.destPanID];
        [self.zigPacketDiction setObject:dest forKey:@"packetDestAddr"];
        [self.zigPacketDiction setObject:destPanId forKey:@"packetDestPanId"];

        
    }
    if(self.mac_layer.mac_fcf.mac_src_addr_mode == 0x02 || self.mac_layer.mac_fcf.mac_src_addr_mode == 0x03)
    {
        if(mac_layer.mac_fcf.mac_panID_compress)
        {
            mac_layer.srcPanID = mac_layer.destPanID;
        }
        else
        {
            mac_layer.srcPanID = packet_read(zig, uint16_t);
        }
        
        if(mac_layer.mac_fcf.mac_src_addr_mode == 0x02)
        {
            mac_layer.src_sAddr = packet_read(zig, uint16_t);
            [src release];
            
            NSLog(@"Source ADDR: %#.4x\n", mac_layer.src_sAddr);
            
            src = [[NSNumber alloc]initWithInt:mac_layer.src_sAddr];
            [self.zigPacketDiction setObject:src forKey:@"packetSrcAddr"];
            
            [decodedMACStr appendFormat:@"Source Address: %1$i (%1$#.4x)\n", mac_layer.src_sAddr];
        } 
        else 
        {
            mac_layer.src_lAddr = packet_read(zig, uint64_t);
            [src release];
            
            NSLog(@"Source ADDR: %#.16qx\n", mac_layer.src_lAddr);
            
            src = [[NSNumber alloc]initWithLongLong:mac_layer.src_lAddr];
            [self.zigPacketDiction setObject:src forKey:@"packetSrcAddr"];
            [decodedMACStr appendFormat:@"Source Address: %1$qu (%1$#.16qx)\n", self.mac_layer.src_lAddr];

        }
        [srcPanId release];

        [decodedMACStr appendFormat:@"Source Pan ID: %1$i (%1$#.4x)\n", mac_layer.srcPanID];
        srcPanId = [[NSNumber alloc]initWithInt:mac_layer.srcPanID];
        [self.zigPacketDiction setObject:src forKey:@"packetSrcAddr"];
        [self.zigPacketDiction setObject:srcPanId forKey:@"packetSrcPanId"];
    }
    return zig;
}
- (void)zigbee_nwkFCF_breakdown
{
    NSString *nwkFT;
    switch (nwk_layer.fcf.frameType)
    {
        case nwk_data:
            nwkFT = [NSString stringWithString:@"NWK Data Frame\n"];
            break;
        case nwk_command:
            nwkFT = [NSString stringWithString:@"NWK Command Frame\n"];
            break;
        default:
            nwkFT = [NSString stringWithString:@"Unknown NWK Frame Type\n"];
    }

    [decodedNWKStr appendFormat:@"NWK FCF: %1$i (%1$#.4X)\n", nwk_layer.fcf];
    [decodedNWKStr appendFormat:@"\tFrame Type:\t\t\t--------------%.2x",zigbee_hexToBin(self.nwk_layer.fcf.frameType, 2)];
    STRING_TAB(decodedNWKStr);
    [decodedNWKStr appendString:nwkFT];
    [decodedNWKStr appendFormat:@"\tProtocal Version:\t\t\t----------%.4x--\n",zigbee_hexToBin(self.nwk_layer.fcf.protoVer,4)];
    [decodedNWKStr appendFormat:@"\tFrame Pending:\t\t\t-----------%X----\n",mac_layer.mac_fcf.mac_frame_pending];
    [decodedNWKStr appendFormat:@"\tAck Request:\t\t\t----------%X-----\n",self.mac_layer.mac_fcf.mac_ack_request];
    [decodedNWKStr appendFormat:@"\tPAN ID Compression:\t\t---------%X------\n",self.mac_layer.mac_fcf.mac_panID_compress];
    [decodedNWKStr appendFormat:@"\tRESERVED:\t\t\t\t------%.2X%X-------\n",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_reserved2, 2)), self.mac_layer.mac_fcf.mac_reserved1];
    [decodedNWKStr appendFormat:@"\tDestination Addr Mode:\t----%.2X----------\n",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_dest_addr_mode, 2))];
    [decodedNWKStr appendFormat:@"\tFrame Version:\t\t\t--%.2X------------\n",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_frame_ver, 2))];
    [decodedNWKStr appendFormat:@"\tSource Addr Mode:\t\t%.2X--------------",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_src_addr_mode, 2))];
    
    [nwkFT release];
}
- (void)zigbee_macFCF_breakdown
{
    NSString *destMode, *srcMode;
    
    switch (self.mac_layer.mac_fcf.mac_frame_type) {
        case mac_beacon:
            frameType = [[NSString alloc]initWithString:@"MAC Beacon\n"];
            break;
        case mac_data:
            frameType = [[NSString alloc]initWithString:@"MAC Data\n"];
            break;
        case mac_ack:
            frameType = [[NSString alloc]initWithString:@"MAC Ackownledgment\n"];
            break;
        case mac_command:
            frameType = [[NSString alloc]initWithString:@"MAC Command\n"];
            break;
        default:
            frameType = [[NSString alloc]initWithString:@"Unknown Packet Type\n"];
            break;
    }
    [frameType release];
    [self.zigPacketDiction setObject:frameType forKey:@"packetValue"];
    
    switch (self.mac_layer.mac_fcf.mac_dest_addr_mode) {
        case mac_addr_not_pres:
            destMode = [[NSString alloc]initWithString:@"\tAddr Not Present\n"];
            break;
        case mac_short_addr:
            destMode = [[NSString alloc]initWithString:@"\tShort Addr Mode\n"];
            break;
        case mac_long_addr:
            destMode = [[NSString alloc]initWithString:@"\tLong Addr Mode\n"];
            break;
        default:
            destMode = [[NSString alloc]initWithString:@"\tERROR:Unknown Mode\n"];
            break;
    }
    switch (self.mac_layer.mac_fcf.mac_src_addr_mode) {
        case mac_addr_not_pres:
            srcMode = [[NSString alloc]initWithString:@"\tAddr Not Present\n"];
            break;
        case mac_short_addr:
            srcMode = [[NSString alloc]initWithString:@"\tShort Addr Mode\n"];
            break;
        case mac_long_addr:
            srcMode = [[NSString alloc]initWithString:@"\tLong Addr Mode\n"];
            break;
        default:
            srcMode = [[NSString alloc]initWithString:@"\tERROR:Unknown Mode\n"];
            break;
    }
    
    [decodedMACStr appendFormat:@"MAC FCF: %1$i (%1$#.4X)\n", self.mac_layer.mac_fcf];
    [decodedMACStr appendFormat:@"\tFrame Type:\t\t\t-------------%.3X",zigbee_hexToBin(self.mac_layer.mac_fcf.mac_frame_type, 3)];
    STRING_TAB(decodedMACStr);
    [decodedMACStr appendString:frameType];
    [decodedMACStr appendFormat:@"\tSecurity Enabled:\t\t\t------------%X---\n",mac_layer.mac_fcf.mac_security_enbl];
    [decodedMACStr appendFormat:@"\tFrame Pending:\t\t\t-----------%X----\n",mac_layer.mac_fcf.mac_frame_pending];
    [decodedMACStr appendFormat:@"\tAck Request:\t\t\t----------%X-----\n",self.mac_layer.mac_fcf.mac_ack_request];
    [decodedMACStr appendFormat:@"\tPAN ID Compression:\t\t---------%X------\n",self.mac_layer.mac_fcf.mac_panID_compress];
    [decodedMACStr appendFormat:@"\tRESERVED:\t\t\t\t------%.2X%X-------\n",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_reserved2, 2)), self.mac_layer.mac_fcf.mac_reserved1];
    [decodedMACStr appendFormat:@"\tDestination Addr Mode:\t----%.2X----------",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_dest_addr_mode, 2))];
    [decodedMACStr appendString:destMode];
    [decodedMACStr appendFormat:@"\tFrame Version:\t\t\t--%.2X------------\n",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_frame_ver, 2))];
    [decodedMACStr appendFormat:@"\tSource Addr Mode:\t\t%.2X--------------",(zigbee_hexToBin(self.mac_layer.mac_fcf.mac_src_addr_mode, 2))];
    [decodedMACStr appendString:srcMode];

    //[frameType release];
    [destMode release];
    [srcMode release];
    
}

- (void)zigbee_packetDisplay:(voidPtr)zig
{
    uint8_t x = 0;
    uint8_t remainder = packetLen%10;
    uint8_t iterations = packetLen/10;
    
    for (uint8_t y=0; y<iterations; y++) {
        x=0;
        [packetStr appendFormat:@"%.4i     ", (y*10)];
        
        while (x<10)
        {
            [packetStr appendFormat:@"%.2x  ", *((uint8_t *)zig+(y*10+x))];
            if(x==4)
                [packetStr appendString:@"      "];
            x++;
        }
        x=0;
            [packetStr appendString:@"\t\t"];
        while (x<10) 
        {
            if((*(((uint8_t *)zig)+(y*10+x)))>32)
                [packetStr appendFormat:@"%c", *((char *)zig+(y*10+x))];
            else
                [packetStr appendString:@"."];
            
            x++;
        }
                [packetStr appendString:@"\n"];
    }

    x=0;
    [packetStr appendFormat:@"%.4i     ", iterations*10];
    while (x<remainder)
    {
        [packetStr appendFormat:@"%.2x  ", *((uint8_t *)zig+(iterations*10+x))];
        if(x==4)
            [packetStr appendString:@"      "];
        x++;
        
    }
    x=0;
    [packetStr appendString:@"\t\t"];
    
    for (uint8_t tabs = 0; tabs<((10-remainder)/2); tabs++) 
    {
        [packetStr appendString:@"\t"];
    } 
           
    while (x<remainder) 
    {
        if((*(((uint8_t *)zig)+(iterations*10+x)))>32)
            [packetStr appendFormat:@"%#c", *((char *)zig+(iterations*10+x))];
        else
            [packetStr appendString:@"."];
            x++;
    }
    
    [packetStr appendString:@"\n"];
    
}
    
- (void)zigbee_breakdown:(voidPtr)zig
{
    decodedMACStr = [[NSMutableString alloc]init];
    decodedNWKStr = [[NSMutableString alloc]init];
    decodedAPSStr = [[NSMutableString alloc]init];
    
    zig = [self zigbee_macBreakdown:zig];
    zig = [self zigbee_nwkBreakdown:zig];
}


int zigbee_hexToBin(int val, uint8_t cnt)
{
    int newValue;
    uint8_t x = 0;
    
    do
    {
        newValue |= (((val>>x) & 0x01)<<(4*x));
        x++;
    }while(x<cnt);
    
    return newValue;
}
@end
