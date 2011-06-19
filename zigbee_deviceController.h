//
//  zigbee_deviceController.h
//  debugger
//
//  Created by Matt Poppe on 5/29/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "usbCentral.h"

@class usbDriver;

@interface zigbee_deviceController : NSObject <usbCentralDelegate>{

    NSTextField *shrtAddrStr, *longAddrStr, *panIdStr;
    NSButton *coordCheckBox, *executionButton;
    NSComboBox *commandComboBox;
   
    
    usbDriver *driver;
}

@property(retain) usbDriver *driver;
@property(assign) IBOutlet NSButton *executionButton, *coordCheckBox;
@property(assign) IBOutlet NSTextField *shrtAddrStr, *longAddrStr, *panIdStr;

@end
