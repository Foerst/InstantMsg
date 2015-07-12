//
//  CellMessage.m
//  IM
//
//  Created by Chan on 15/2/10.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "CellMessageModel.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"


#define kDeltaSeconds  5*60//超过时间间隔的消息才显示时间
#define kDaySeconds   24*60*60
#define kWeekSeconds  7*kDaySeconds
#define kYearSecond   365*kDaySeconds
static NSDate *LastMsgDate;//上一次显示的时间
@implementation CellMessageModel

- (instancetype)initWithXMPPMessageArchivingMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)obj
{
//    NSLog(@"%@",[obj.timestamp description]);
    if (self = [super init]) {
        self.obj = obj;
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSData *avatorDataProfile = [appDelegate.xmppvCardAvatarModule photoDataForJID:[UserModel sharedUserModel].xmppJID];
        NSData *avatorDataOther = [appDelegate.xmppvCardAvatarModule photoDataForJID:obj.bareJid];
        if (obj.isOutgoing) {//我
            self.imgData = avatorDataProfile;
        }else{//对方
            self.imgData = avatorDataOther;
        }
        
        if (LastMsgDate == nil) {
            LastMsgDate = obj.timestamp;//记住第一条消息的时间
        }
       
        long  deltaSeconds = (long)[obj.timestamp timeIntervalSinceDate:LastMsgDate];//相邻两条消息的时间间隔
        if (0 == deltaSeconds) {//默认第一条消息显示时间
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"HH:mm"];
            self.timestamp = [self rightTimeStamp:obj.timestamp];
        }else if (deltaSeconds <= kDeltaSeconds && deltaSeconds > 0) {//间隔内的消息不显示时间
            self.timestamp = @"";
        }else{//超过间隔的消息重新显示时间

            self.timestamp = [self rightTimeStamp:obj.timestamp];
            LastMsgDate = obj.timestamp;
        }

        
        self.body = obj.body;
        self.isOutgoing = obj.isOutgoing;
        
        
    }
    return self;
}

#pragma mark -获取正确的日期字符串
- (NSString *)rightTimeStamp:(NSDate *)sinceDate
{
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
