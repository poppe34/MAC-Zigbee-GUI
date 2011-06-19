//
//  usbInfo.m
//  debugger
//
//  Created by Matt Poppe on 2/16/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "usbInfo.h"


@implementation usbInfo

@synthesize name, driverClass, driver, venId, prodId, notification, central, locId;

- (id)init
{
	if(self = [super init])
	   {
		   name = @"Default";
		   driverClass = NULL;
		   driver = NULL;
		   venId = 2222;
		   prodId = 0;
		   notification = 0;
		   
	   }
	   return self;
}
@end
