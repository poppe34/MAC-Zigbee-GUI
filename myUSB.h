//
//  myUSB.h
//  debugger
//
//  Created by Matt Poppe on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef _MY_USB
#define _MY_USB

#include <stdio.h>

#include <mach/mach.h>

#include <CoreFoundation/CFNumber.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include "myUSB.h"
#include "myTypes.h"

#define kUSBDeviceName	"IOUSBDevice"
#define kVendorID		0x03EB
#define kProductID		0x2334



UInt8 usbDebug;
//USB Connections

IOUSBConfigurationDescriptorPtr	confDesc;
UInt8 alarmOutPipeRef;
UInt8 alarmInPipeRef;

IOUSBDeviceInterface320 ** connectUSB(void);
IOUSBDeviceInterface320 ** getDevice(io_service_t usbDevice);
IOUSBInterfaceInterface300 ** getInterface(IOUSBDeviceInterface320 **dev, UInt8 num);
IOReturn transferData(IOUSBInterfaceInterface300 ***intf, char *outBuf, int len);
void asyncWriteCB(void *dummy, IOReturn result, void *arg0);
void interfaceInteraction (IOUSBInterfaceInterface300*** intfPtr, io_service_t Ref);

#endif
