//
//  IPAddress.h
//
//
//  Created by Chan on 14/12/22.
//  Copyright (c) 2014年 aicai. All rights reserved.
//



#define MAXADDRS    32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();

