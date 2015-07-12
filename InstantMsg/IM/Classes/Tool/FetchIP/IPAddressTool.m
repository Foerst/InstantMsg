//
//  IPAddressTool.m
//  ACBarQuery
//
//  Created by Chan on 14/12/22.
//  Copyright (c) 2014年 aicai. All rights reserved.
//

#import "IPAddressTool.h"
#include "IPAddress.h"

@implementation IPAddressTool
+ (NSString *)getIPAddress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;            // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        IMLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        deviceIP = [NSString stringWithUTF8String:ip_names[i]];
    }
    return deviceIP;
}
@end
