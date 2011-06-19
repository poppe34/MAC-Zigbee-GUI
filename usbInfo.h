//
//  usbInfo.h
//  debugger
//
//  Created by Matt Poppe on 2/16/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class usbCentral;

@interface usbInfo : NSObject {
	
	long		venId;
	long		prodId;
	long		locId;
	NSString*	name;
	Class		driverClass;
	id			driver;
	io_object_t	notification;
	usbCentral *central;
}

@property long venId, prodId, locId;
@property(copy) NSString *name;
@property(assign) Class driverClass;
@property io_object_t notification;
@property(assign) id driver;
@property(assign) usbCentral *central;

@end
