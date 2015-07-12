//
//  MemberListModel.m
//  IM
//
//  Created by chan on 15/5/16.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "MemberListModel.h"

@implementation MemberListModel


- (void)setElement:(DDXMLElement *)element
{
    _affiliation = [[element attributeForName:@"affiliation"] stringValue];
    _nick = [[element attributeForName:@"nick"] stringValue];
    _jid = [[element attributeForName:@"jid"] stringValue];
    _role = [[element attributeForName:@"role"] stringValue];
}

- (NSString *)description
{
    NSString *log = [NSString stringWithFormat:@"affiliation:%@,nick:%@,jid:%@,role:%@", _affiliation, _nick, _jid, _role];
    return log;
}
@end
