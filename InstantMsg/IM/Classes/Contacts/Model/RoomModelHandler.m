//
//  RoomModelHandler.m
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "RoomModelHandler.h"
#import "RoomModel.h"
#import "DDXML.h"
#import "GDataXMLNode.h"
@implementation RoomModelHandler


/*queryXml like this
 <query xmlns=\"http://jabber.org/protocol/disco#items\"><item jid=\"wechat@conference.chandemacbook-pro.local\" name=\"&#x6D4B;&#x8BD5;&#x7FA4;\"/><item jid=\"java_developer@conference.chandemacbook-pro.local\" name=\"java&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/><item jid=\"developer@conference.chandemacbook-pro.local\" name=\"iOS&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/><item jid=\"swift_developer@conference.chandemacbook-pro.local\" name=\"swift&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/><item jid=\"html5_developer@conference.chandemacbook-pro.local\" name=\"html5&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/><item jid=\"company@conference.chandemacbook-pro.local\" name=\"&#x516C;&#x53F8;&#x7FA4;\"/><item jid=\"android_developer@conference.chandemacbook-pro.local\" name=\"android&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/><item jid=\"cs_developer@conference.chandemacbook-pro.local\" name=\"c#&#x5F00;&#x53D1;&#x4EA4;&#x6D41;&#x7FA4;\"/></query>
 //XML File
 //<bookcase>
 // <book>
 // <bookName>My First KissXml Article</bookName>
 // <bookAuthor>mOMo</bookAuthor>
 // </book>
 // <book>
 // <bookName>Delete Life</bookName>
 // <bookAuthor>Mary</bookAuthor>
 // </book>
 //</bookcase>
 
 */

+ (NSArray *)handleQueryXMLString:(NSString *)queryXml
{
    
//    NSError *error = nil;
//    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:queryXml options:0 error:&error];
//    if (error == nil) {
//        
//        //開始解析
//        NSArray *children = nil;
//        
//        //使用XPath取得要走訪的節點
//        //            children = [doc nodesForXPath:@"bookcase/book" error:nil];
//        children = [doc nodesForXPath:@"iq" error:nil];
//        
//        //依符合的節點數量走訪
//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:children.count];
//        for (int i=0; i < [children count]; i++) {
//            //建立DDXMLNode
//            DDXMLElement *child = [children objectAtIndex:i];
//            RoomModel *room = [RoomModel new];
//            room.roomJid = [[child attributeForName:@"jid"] stringValue];
//            room.roomName = [[child attributeForName:@"name"] stringValue];
//            [arr addObject:room];
//        }
//        return arr;
//        
//    }
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:queryXml options:0 error:nil];
    
    //使用NSData对象初始化
//    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    
    //获取根节点（Users）
    GDataXMLElement *rootElement = [doc rootElement];
    //获取根节点下的节点（User）
    NSArray *items = [[rootElement elementsForName:@"query"][0] elementsForName:@"item"];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:items.count];
    for (int i=0; i < [items count]; i++) {
        //建立DDXMLNode
        DDXMLElement *child = [items objectAtIndex:i];
        RoomModel *room = [RoomModel new];
        room.roomJid = [[child attributeForName:@"jid"] stringValue];
        room.roomName =[[child attributeForName:@"name"] stringValue];
        [arr addObject:room];

//        NSLog(@"書名：%@", [[child attributeForName:@"jid"] stringValue]);
//        NSLog(@"作者：%@", [[child attributeForName:@"name"] stringValue]);
    }

    return arr;
    
}
    
@end
