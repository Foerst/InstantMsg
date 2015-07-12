//
//  GroupMessageModel.m
//  IM
//
//  Created by chan on 15/5/15.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "GroupMessageModel.h"
#import "XMPPMessage.h"
#import "MemberListModel.h"

#define kDeltaSeconds  5*60//超过时间间隔的消息才显示时间
#define kDaySeconds   24*60*60
#define kWeekSeconds  7*kDaySeconds
#define kYearSecond   365*kDaySeconds
static NSDate *LastMsgDate;//上一次显示的时间


@implementation GroupMessageModel


- (instancetype)initWithXMPPRoomMessageCoreDataStorageObject:(XMPPRoomMessageCoreDataStorageObject *)obj
{
    if (self = [super init]) {
        _obj = obj;
        _body = obj.body;
        _isFromMe = obj.isFromMe;
        _roomJIDStr = obj.roomJIDStr;
        _timestamp = [self rightTimeStamp:obj.localTimestamp];
        _jidStr = obj.jidStr;
        _nickname = obj.nickname;
        
    }
    return self;
}

- (UIImage *)loadUserImage:(NSString *)jidStr
{
    //从用户的头像模块中提取用户头像
    
    NSData *photoData = [[kAppDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jidStr]];
    
    if (photoData) {
        return [UIImage imageWithData:photoData];
    }
    
    return [UIImage imageNamed:@"DefaultProfileHead"];
}
- (UIImage *)avator
{
//    wechat@conference.chandemacbook-pro.local/nick
#warning 这里可能要进行处理jidStr
    NSString *nick = [_jidStr componentsSeparatedByString:@"/"].lastObject;
    //根据nick获取jidStr
    if (_membreList) {
        for (MemberListModel *member in _membreList) {
            
            if ([nick isEqualToString:member.nick]) {
                _jidStr = member.jid;
                return [self loadUserImage:_jidStr];
            }
        }
    }
    return [self loadUserImage:nil];

}

- (NSDate *)getLocalFromUTC:(NSString *)utc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *ldate = [dateFormatter dateFromString:utc];

    return ldate;
}
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}
#pragma mark -获取正确的日期字符串
- (NSString *)rightTimeStamp:(NSDate *)sinceDate
{
    sinceDate = [self getNowDateFromatAnDate:sinceDate];
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:( NSCalendarUnitYear|                                                               NSCalendarUnitMonth |NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute |NSCalendarUnitSecond |
                                                              NSCalendarUnitWeekday ) fromDate:today];
    //    NSInteger year = [dateComponents year];
    //    NSInteger month = [dateComponents month];
    //    NSInteger day = [dateComponents day];
    //    NSInteger hour = [dateComponents hour];
    //    NSInteger minute = [dateComponents minute];
    //    NSInteger seconds = [dateComponents second];
    //
    //    NSInteger weekday = [dateComponents weekday];
    
    //    同样你也可以从NSDateComponents对象来创建NSDate对象：
    NSInteger tomorrowHour = 23;
    NSInteger tomorrowMinute = 59;
    NSInteger tomorrowSecondes = 60;
    [dateComponents setHour:tomorrowHour];
    [dateComponents setMinute:tomorrowMinute];
    [dateComponents setSecond:tomorrowSecondes];
    
    NSDate *tomorrowDate = [gregorian dateFromComponents:dateComponents];
    
    long  deltaSeconds = (long)[tomorrowDate timeIntervalSinceDate:sinceDate];//消息距离现在的时间间隔
    
    if (deltaSeconds <= kDaySeconds) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        return  [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:sinceDate]];
    }else if (deltaSeconds <= 2*kDaySeconds) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        return  [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:sinceDate]];
    }else if(deltaSeconds <= kWeekSeconds){
        NSString *weekdayStr = [self weekdayOfDate:sinceDate];
        //        IMLog(@"星期 ----》%@",weekdayStr);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        if ([weekdayStr isEqualToString:@"星期日"]) {
            //            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            
            return  [dateFormatter stringFromDate:sinceDate];
        }else{
            [dateFormatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"%@ %@",weekdayStr, [dateFormatter stringFromDate:sinceDate]];
        }
    }else if(deltaSeconds <= kYearSecond){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        return [dateFormatter stringFromDate:sinceDate];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
        [dateFormatter setTimeZone:timeZone];
        
        return [dateFormatter stringFromDate:sinceDate];
    }
    //        if (deltaSeconds <= 60) {//1分钟之内显示秒
    //            self.timestamp = [NSString stringWithFormat:@"%f秒前",deltaSeconds];
    //        }else  if (deltaSeconds <= 900) {//15分钟之内显示x分x秒前
    //            int del = (int)deltaSeconds;
    //            self.timestamp = [NSString stringWithFormat:@"%f分%d秒前",deltaSeconds/60,del%60];
    //        }else  if (deltaSeconds <= kDaySeconds) {//1天之内显示x时：x分
    //            int del = (int)deltaSeconds;
    //            self.timestamp = [NSString stringWithFormat:@"%f分%d秒前",deltaSeconds/60,del%60];
    //        }else  if (deltaSeconds <= kDaySeconds) {//1年之内显示x月/x日 x时：x分
    //            int del = (int)deltaSeconds;
    //            self.timestamp = [NSString stringWithFormat:@"%f分%d秒前",deltaSeconds/60,del%60];
    //        }else  if (deltaSeconds <= kDaySeconds) {//1年之外显示x年/x月/x日
    //            int del = (int)deltaSeconds;
    //            self.timestamp = [NSString stringWithFormat:@"%f分%d秒前",deltaSeconds/60,del%60];
    //        }
    
}



#pragma mark -返回date对应的星期几
/**
 *  返回date对应的星期几
 *
 *  @param date 日期
 *
 *  @return date对应的周几
 
 */
- (NSString *)weekdayOfDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:date];
    int week = [dd weekday];
    //    int hour = [dd hour];
    //    int minute = [dd minute];
    //    int second = [dd second];
    //    NSLog(@"%i,%i,%i,%i",week,hour,minute,second);
    
    NSString *weekDayStr = @"";
    switch (week) {
        case 1:
            weekDayStr = @"星期日";
            break;
        case 2:
            weekDayStr = @"星期一";
            break;
        case 3:
            weekDayStr = @"星期二";
            break;
        case 4:
            weekDayStr = @"星期三";
            break;
        case 5:
            weekDayStr = @"星期四";
            break;
        case 6:
            weekDayStr = @"星期五";
            break;
        case 7:
            weekDayStr = @"星期六";
            break;
        default:
            weekDayStr = @"";
            break;
    }
    return weekDayStr;
}

//判断日期是今天，昨天还是明天
//-(NSString *)compareDate:(NSDate *)date{
//
//    NSTimeInterval secondsPerDay = 24 * 60 * 60;
//    NSDate *today = [[NSDate alloc] init];
//    NSDate *tomorrow, *yesterday;
//
//    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
//    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
//
//    // 10 first characters of description is the calendar date:
//    NSString * todayString = [[today description] substringToIndex:10];
//    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
//    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
//
//    NSString * dateString = [[date description] substringToIndex:10];
//
//    if ([dateString isEqualToString:todayString])
//    {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
//        [dateFormatter setTimeZone:timeZone];
//        [dateFormatter setDateFormat:@"HH:mm"];
//
//        return  [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:date]];
//
//    } else if ([dateString isEqualToString:yesterdayString]){
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"HH:mm"];
//        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
//        [dateFormatter setTimeZone:timeZone];
//        return  [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:date]];
//
//    }else if ([dateString isEqualToString:tomorrowString]){
//        return @"明天";
//    }else{
//        return dateString;
//    }
//}



@end
