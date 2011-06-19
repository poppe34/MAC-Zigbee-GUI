/*
 *  debug.h
 *  debugger
 *
 *  Created by Matt Poppe on 2/7/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _DEBUG_H
#define _DEBUG_H

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <stdint.h>
#include <stdlib.h>


typedef uint8_t debugLevel;

#define IO_ERR(level, str, err)	if(level<=(getDebugLevel())) CheckError(err, str)
#define VERBOSE_DEBUG_LEVEL 10

void CheckError(IOReturn err, char* where);
void ShowError(IOReturn err, char* where); 
void ErrorName (IOReturn err, char* out_buf);
void setDebugLevel(debugLevel level);
debugLevel getDebugLevel(void);
void ShowErrorWithOK(IOReturn err, char* where);
void ShowErrorWithOutOK(IOReturn err, char* where);
void displayError(debugLevel level, char *error, char *where);
#endif