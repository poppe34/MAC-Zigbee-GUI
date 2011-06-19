//
//  zigbee_layers.h
//  debugger
//
//  Created by Matt Poppe on 5/2/11.
//  Copyright 2011 Poppe. All rights reserved.
//
#ifndef _ZIGBEE_LAYERS
#define _ZIGBEE_LAYERS

#define START_PACKED
#define END_PACKED

#define BITS_1(f1) f1;
#define BITS_2(f1, f2) f1; f2;
#define BITS_3(f1, f2, f3)  f1; f2; f3;
#define BITS_4(f1, f2, f3, f4)  f1; f2; f3; f4;
#define BITS_5(f1, f2, f3, f4, f5)  f1; f2; f3; f4; f5;
#define BITS_6(f1, f2, f3, f4, f5, f6)  f1; f2; f3; f4; f5; f6;
#define BITS_7(f1, f2, f3, f4, f5, f6, f7)  f1; f2; f3; f4; f5; f6; f7;
#define BITS_8(f1, f2, f3, f4, f5, f6, f7, f8) f1; f2; f3; f4; f5; f6; f7; f8;

#define COMBINE(size, data) BITS_##size data

START_PACKED
typedef struct mac_fcf{
    COMBINE(6, (
                uint8_t mac_frame_type:3,
                uint8_t mac_security_enbl:1,
                uint8_t mac_frame_pending:1,
                uint8_t mac_ack_request:1,
                uint8_t mac_panID_compress:1,
                uint8_t mac_reserved1:1))
    COMBINE(4, (
                uint8_t mac_reserved2:2,
                uint8_t mac_dest_addr_mode:2,
                uint8_t mac_frame_ver:2,
                uint8_t mac_src_addr_mode:2))
}mac_fcf_t;
END_PACKED

START_PACKED
typedef struct nwk_fcf{
    COMBINE(3, (uint8_t frameType:2,
                uint8_t protoVer:4,
                uint8_t discoverRoute:2))
    COMBINE(6, (uint8_t MulticastFlag:1,
                uint8_t Security:1,
                uint8_t sourceRoute:1,
                uint8_t destAddrAvail:1,
                uint8_t srcAddrAvail:1,
                uint8_t reserved:3))
}nwk_fcf_t;
typedef struct mac
{
    mac_fcf_t mac_fcf;
    uint8_t mac_seq_num;
    uint16_t destPanID;
    union {
        uint16_t dest_sAddr;
        uint64_t dest_lAddr;
    };
    uint16_t srcPanID;
    union {
        uint16_t src_sAddr;
        uint64_t src_lAddr;
    };
}mac_t;

typedef struct nwk
{
    nwk_fcf_t fcf;
    uint16_t destAddr;
    uint16_t srcAddr;
    uint8_t radius;
    uint8_t seqNum;
    uint64_t destIEEEAddr;
    uint64_t srcIEEEAddr;
    uint8_t multicastControl;
}nwk_t;

enum nwk_frame_type
{
    nwk_data = 0x00,
    nwk_command = 0x01,
};

enum mac_frame_type
{
    mac_beacon = 0x00,
    mac_data = 0x01,
    mac_ack = 0x02,
    mac_command = 0x03,
};

enum mac_addr_mode
{
    mac_addr_not_pres = 0x00,
    mac_short_addr = 0x02,
    mac_long_addr = 0x03,
};

#endif