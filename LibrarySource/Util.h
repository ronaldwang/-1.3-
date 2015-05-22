//
//  Util.h
//  UnitsChanges
//
//  Created by zhangmeng on 14/11/12.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MHFileTool.h"
#import "DES.h"
#import "Localisator.h"
#import <AudioToolbox/AudioToolbox.h>

#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
#define IS_IOS8  ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO) 


#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)) : NO)

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)


@interface Util : NSObject
@property (nonatomic,assign)   int   dataType;   // 数据类型
@property (nonatomic,retain)  UIColor *themeColor;  // 主题色
@property (nonatomic,retain)  NSMutableArray  *themeArray;

+(Util*)shareInstance;


//  数据类型
+ (void)saveDataType:(int)dataType :(BOOL)isSave;
+(int) takeDataType;

+ (BOOL)isSave;
+ (BOOL)isThemeSave;
+ (BOOL)isKeepingSound;

//  颜色
+ (void)saveColorString:(NSString*)colorString;
+(NSString*)takeColorString;

//  时间
+ (void)saveRequestDate:(NSString*)dateString;
+ (NSString*)takeRequestDate;

//  所有的国家信息
+(void)saveAllCountryInfor:(NSMutableDictionary*)allCountryInfor;
+(NSMutableDictionary*)takeAllCountryInfor;

//  已选中国家
+(void)saveSelectedCounrty:(NSMutableArray*)selectedCountry;
+(NSMutableArray*)takeSelectedCountry;

//  已收藏国家
+(void)saveCollectCountry:(NSMutableArray*)collectCountry;
+(NSArray*)takeCollectCountry;


//  index
+(void)saveSelectedIndex:(NSIndexPath*)index;
+ (NSIndexPath*)takeSelectedIndex;

+(void)saveChangeDic:(NSMutableDictionary*)changeDic;
+(NSMutableDictionary*)takeChangeDic;

+ (void)saveCurrencyForChartView:(NSString*)currency;
+(NSString*)takeCurrencyForChartView;

+ (NSMutableArray*)readSeclectCountry;
+ (NSMutableDictionary *)readDataFromNSUserDefaults;


+ (UIColor *) colorWithHexString: (NSString *)color;
+ (NSString*)takeRequestTimeDifference:(NSString*)dateString;
+(NSString *)roundUp:(float)number afterPoint:(int)position;


+(NSString*)numberFormatterSetting:(NSString*)numberString withFractionDigits:(int)FractionDigits withInput:(BOOL)isInpunt;
+(double)numberFormatterForFloat:(NSString*)string;


+(void)saveColorByNSUserDefaults:(NSString*)colorString;
+(void)saveDataTypeByNSUserDefaults:(NSString*)dayaType :(BOOL)isSave;

+(NSString*)readColorString;
+(int)readDataType;
+(BOOL)dataTypeIsSave;


+ (void)saveDefaultVauleByNsuer:(NSString *)defaultValue;
+ (NSString*)readDefaultValue;


+ (void)saveObligateValuesList:(NSArray*)valuesList;
+ (NSArray*)takeObligateValuesList;


+(void)saveAppPurchaseStateWithProductID:(NSString*)productid;
+(BOOL)isAppPurchaseWithProductID:(NSString*)productid;


+ (NSMutableArray*)readQuestionData;


+(void)saveTextByNSUserDefaults:(NSMutableDictionary*)rateDic;
+(NSString*)changeDateToStringWith:(NSDate*)date;
+(NSMutableDictionary*)deaWithRequestData:(NSDictionary*)dataDic;

+ (void)saveSayingContentArray:(NSArray*)contentArray;
+ (NSArray*)takeSayingContent;


#pragma mark
#pragma mark   APP   WATCH
+(void)saveWidgetState:(NSString*)state;
+(NSString*)widgetSatte;

+(void)saveWidgetResult:(NSString*)result;
+(NSString*)widgetResult;


+(BOOL)takeTimeDifference:(NSString*)dateString;


+ (void)saveUserInput:(NSString*)input;
+ (NSString*)takeUserInput;
+ (BOOL)isUserIput;

+(void)saveCurrentIndex:(NSString*)index;
+ (NSString*)takeCurrentIndex;


+ (NSString*) deviceName;



@end
