//
//  MemberListModel.h
//  IM
//
//  Created by chan on 15/5/16.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberListModel : NSObject
@property (nonatomic, copy) NSString *affiliation;
@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, strong) DDXMLElement *element;
@end
