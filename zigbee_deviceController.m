//
//  zigbee_deviceController.m
//  debugger
//
//  Created by Matt Poppe on 5/29/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "zigbee_deviceController.h"
#import "usbDriver.h"
#import "usbInfo.h"

@implementation zigbee_deviceController

@synthesize driver;
@synthesize executionButton, coordCheckBox;
@synthesize shrtAddrStr, longAddrStr, panIdStr;

- (id)init
{

    self = [super init];
    if (self) {
               
    }
    
    return self;
}

- (void)awakeFromNib
{
    [shrtAddrStr setStringValue:@"Default Value"];
    [longAddrStr setStringValue:@"LONG  Def Val"];
    [panIdStr setStringValue:@"PAN ID DEF"];
    [coordCheckBox setState:YES];
   
}

- (void)dealloc
{
    [super dealloc];
}

- (void)getShortAddr
{
    
}


@end
