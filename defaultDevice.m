//
//  defaultDevice.m
//  debugger
//
//  Created by Matt Poppe on 2/21/11.
//  Copyright 2011 Poppe. All rights reserved.
//

#import "defaultDevice.h"
#import "usbHeaders.h"

@implementation defaultDevice

+ (NSArray *)usbDescriptor
{
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys: 
			 [NSNumber numberWithLong:kDefaultProdID], @"productID",
			 [NSNumber numberWithUnsignedShort:kDefaultVendID], @"vendorID",
			 [NSString stringWithString:kDefaultName], @"name", NULL], 
			
			NULL];
}
@end
