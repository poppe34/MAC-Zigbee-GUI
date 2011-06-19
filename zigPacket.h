//
//  zPacket.h
//  debugger
//
//  Created by Matt Poppe on 4/24/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zigbee_layers.h"

@interface zigPacket : NSObject {
//@private
    uint8_t packetLen;  
    NSMutableDictionary *zigPacketDiction;
    NSMutableString *decodedMACStr, *decodedNWKStr, *decodedAPSStr, *packetStr;
    mac_t mac_layer;
    nwk_t nwk_layer;
    NSNumber *testNum, *src, *dest, *srcPanId, *destPanId;
    NSString *frameType;
    uint8_t frame[128];
    
}
#define packet_read(packet, var) *(var *)packet;\
                                        packet+=sizeof(var)


@property(assign) uint8_t packetLen;
@property(assign) NSMutableDictionary *zigPacketDiction;
@property(assign) NSMutableString *decodedMACStr, *decodedNWKStr, *decodedAPSStr, *packetStr;
@property(assign) mac_t mac_layer;
@property(assign) nwk_t nwk_layer;
@property(assign) NSNumber *testNum;

- (id)init;
- (void)dealloc;
- (id)initWithData:(voidPtr)zig
            length:(uint8_t)len;

- (void)zigbee_breakdown:(voidPtr)zig;
- (void)zigbee_packetDisplay:(voidPtr)zig;

/* MAC Layer */
- (voidPtr)zigbee_macBreakdown:(voidPtr)zig;
- (void)zigbee_macFCF_breakdown;

/* NWK Layer */
- (voidPtr)zigbee_nwkBreakdown:(voidPtr)zig;
- (void)zigbee_nwkFCF_breakdown;

int zigbee_hexToBin(int val, uint8_t cnt);
@end
