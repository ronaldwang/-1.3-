//
//  Util.m
//  UnitsChanges
//
//  Created by zhangmeng on 14/11/12.
//  Copyright (c) 2014年 MR_ZhangM. All rights reserved.
//

#import "Util.h"

@implementation Util
@synthesize themeColor,dataType;

+ (Util*)shareInstance{
    static dispatch_once_t pred;
    static Util *currentUtil = nil;
    dispatch_once(&pred, ^{
        currentUtil = [[self alloc] init];
    });
    return currentUtil;
}

- (Util*)init{
    self = [super init];
    if (self) {
        if ([Util  isSave]) {
            self.themeColor = [Util colorWithHexString:[Util  takeColorString]];
            self.dataType = [Util  takeDataType];
        }else{
            if ([Util  isThemeSave]) {
                self.themeColor = [Util colorWithHexString:[Util  takeColorString]];
            }else{
                 self.themeColor = [UIColor colorWithRed:26/255.0 green:183/255.0 blue:234/255.0 alpha:1.0];
            }
            self.dataType = 2;
        }
        
        self.themeArray = [NSMutableArray arrayWithObjects:@"#20c0fa",@"#f42061",@"#0ba287",@"#fd7a11",@"#771efd",@"#15bd39",@"#efcf1d",@"#f641c1",nil];
    }
    return self;
}

//  数据类型
+ (void)saveDataType:(int)dataType :(BOOL)isSave{
    [[NSUserDefaults  standardUserDefaults]  setObject:[NSNumber numberWithInt:dataType] forKey:@"dataType"];
     [[NSUserDefaults  standardUserDefaults]  setBool:isSave forKey:@"isSave"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];
}

+(int) takeDataType{
    
    int  dataType =  [[[NSUserDefaults  standardUserDefaults]  objectForKey:@"dataType"]  intValue];
    BOOL   isSave = [Util  isSave];
    return isSave == YES?dataType:2;
    
}


+ (BOOL)isSave{
   return [[[NSUserDefaults  standardUserDefaults]  objectForKey:@"isSave"]  boolValue];
}

+ (BOOL)isThemeSave{
    return [[[NSUserDefaults  standardUserDefaults]  objectForKey:@"isThemeSave"]  boolValue];
}

+ (BOOL)isKeepingSound{
    return [[[NSUserDefaults  standardUserDefaults]  objectForKey:@"isKeepingSound"]  boolValue];
}

//  颜色
+ (void)saveColorString:(NSString*)colorString{
    [[NSUserDefaults  standardUserDefaults]  setObject:colorString forKey:@"colorString"];
    [[NSUserDefaults  standardUserDefaults]  setBool:YES forKey:@"isThemeSave"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];
}

+(NSString*)takeColorString{
    NSString  *color = [[NSUserDefaults  standardUserDefaults]  objectForKey:@"colorString"];
    return color == nil?@"#20c0fa":color ;
}

// 时间
+ (void)saveRequestDate:(NSString*)dateString{

    [[NSUserDefaults  standardUserDefaults]  setObject:dateString forKey:@"dateString"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];

}

+ (NSString*)takeRequestDate{
    return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"dateString"];
}

+ (void)saveCurrencyForChartView:(NSString*)currency{
    [[NSUserDefaults  standardUserDefaults]  setObject:currency forKey:@"ChartView"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];
}
+(NSString*)takeCurrencyForChartView{
     return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"ChartView"];
}


+(void)saveAllCountryInfor:(NSMutableDictionary *)allCountryInfor{
    [[NSUserDefaults  standardUserDefaults]  setObject:allCountryInfor forKey:@"allCountry"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];
}
+(NSMutableDictionary*)takeAllCountryInfor{
    return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"allCountry"];
}

+(void)saveSelectedCounrty:(NSMutableArray*)selectedCountry{
    [[NSUserDefaults  standardUserDefaults]  setObject:selectedCountry forKey:@"selectedCountry"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];

}
+(NSMutableArray*)takeSelectedCountry{
  return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"selectedCountry"];
}


+(void)saveCollectCountry:(NSMutableArray*)collectCountry{
    [[NSUserDefaults  standardUserDefaults]  setObject:collectCountry forKey:@"collectCountry"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];

}

+(NSArray*)takeCollectCountry{
    return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"collectCountry"];
}


+(void)saveChangeDic:(NSMutableDictionary*)changeDic{
    [[NSUserDefaults  standardUserDefaults]  setObject:changeDic forKey:@"changeDic"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];

}
+(NSMutableDictionary*)takeChangeDic{
    return [[NSUserDefaults  standardUserDefaults]  objectForKey:@"changeDic"];
}


+(void)saveSelectedIndex:(NSIndexPath*)index{
    
    NSDictionary  *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithInt:(int)index.section],@"section",[NSNumber  numberWithInt:(int)index.row],@"row", nil];
    
    [[NSUserDefaults  standardUserDefaults]  setObject:dic forKey:@"index"];
    [[NSUserDefaults  standardUserDefaults]  synchronize];
}
+ (NSIndexPath*)takeSelectedIndex{
    
    NSDictionary   *dic = [[NSUserDefaults  standardUserDefaults]  objectForKey:@"index"];
    NSIndexPath  *index = [NSIndexPath  indexPathForRow:[[dic  objectForKey:@"row"]  integerValue] inSection:[[dic  objectForKey:@"section"]  integerValue]];
    
    return  index;
}



#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


#pragma mark  
#pragma   mark     四舍五入
+(NSString *)roundUp:(float)number afterPoint:(int)position{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:number];

    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

#pragma mark
#pragma mark   *******计算时间差*******
+ (NSString*)takeRequestTimeDifference:(NSString*)dateString{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:dateString];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    return timeString;
}

+(NSString*)numberFormatterSetting:(NSString*)numberString withFractionDigits:(int)FractionDigits withInput:(BOOL)isInpunt{

    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
    [fmt  setRoundingMode:NSNumberFormatterRoundFloor];
    [fmt setMaximumFractionDigits:FractionDigits];  //最大小数点位数
    if (!isInpunt) {
        [fmt  setMinimumFractionDigits:FractionDigits];
    }
    fmt.locale = [NSLocale   currentLocale];
    NSNumber  *number = [NSNumber  numberWithDouble:[numberString  doubleValue]];
    NSString *result = [fmt stringFromNumber:number];
    return result;
}


+(double)numberFormatterForFloat:(NSString*)string{
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
    [fmt setMaximumFractionDigits:1]; // to avoid any decimal
    fmt.locale = [NSLocale   currentLocale];
    NSNumber  *number = [fmt  numberFromString:string];
    double result = [number  floatValue];
    return result;

}


#pragma mark
#pragma  mark        数据处理
+(NSMutableDictionary*)deaWithRequestData:(NSDictionary*)dataDic{
    NSMutableDictionary * dic = [NSMutableDictionary  dictionary];
    NSArray  *dataAarray = [dataDic  objectForKey:@"resources"];
    for (NSDictionary  *unitDic  in dataAarray) {
        NSDictionary  *resource = [[unitDic  objectForKey:@"resource"]  objectForKey:@"fields"];
        NSArray  *array = [[resource  objectForKey:@"symbol"]  componentsSeparatedByString:@"="];
        if (array.count == 2) {
            NSString  *name = [array  objectAtIndex:0];
            NSString  *price = [resource   objectForKey:@"price"];
            [dic   setObject:price forKey:name];
        }
    }
    return dic;
}


#pragma mark    日期转 字符串
+(NSString*)changeDateToStringWith:(NSDate*)date{
    NSDateFormatter  *dateFormater = [[NSDateFormatter  alloc ] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString  *dateString = [dateFormater stringFromDate:date];
    return dateString;
}


+(void)saveTextByNSUserDefaults:(NSMutableDictionary*)rateDic
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:rateDic forKey:@"rateDic"];
    [shared synchronize];
}


+(void)saveColorByNSUserDefaults:(NSString*)colorString
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:colorString forKey:@"colorString"];
    [shared synchronize];
}

+(void)saveDataTypeByNSUserDefaults:(NSString*)dayaType :(BOOL)isSave{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:dayaType forKey:@"DataType"];
    [shared  setBool:isSave forKey:@"DataTypeIsSave"];
    [shared synchronize];
}

+ (void)saveDefaultVauleByNsuer:(NSString *)defaultValue{
   
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:defaultValue forKey:@"defaultValue"];
    [shared synchronize];
  
}
+ (NSString*)readDefaultValue{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSString *defaultvalue = [shared valueForKey:@"defaultValue"];
    
     return defaultvalue == nil?@"100":defaultvalue;
}


+(NSString*)readColorString{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSString *colorString = [shared valueForKey:@"colorString"];
    return colorString;
}


+(BOOL)dataTypeIsSave{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [[shared valueForKey:@"DataTypeIsSave"]  boolValue];

}

+(int)readDataType{
    
    if ([Util  dataTypeIsSave]) {
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
        return [[shared valueForKey:@"DataType"]  intValue];
    }else{
        return 2;
    }
}


+ (NSMutableArray*)readSeclectCountry{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSMutableArray *collectCountry = [shared valueForKey:@"selectCountry"];
    return collectCountry;
}

//  汇率
+ (NSMutableDictionary *)readDataFromNSUserDefaults
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSMutableDictionary *value = [shared valueForKey:@"rateDic"];
    return value;
}


//  预留值
+ (void)saveObligateValuesList:(NSArray*)valuesList{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    [shared setObject:valuesList forKey:@"ObligateValues"];
    [shared synchronize];

}
+ (NSArray*)takeObligateValuesList{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    NSArray *value = [shared valueForKey:@"ObligateValues"];
    return value;
}

//  购买
+(void)saveAppPurchaseStateWithProductID:(NSString*)productid{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setBool:YES forKey:productid];
    [shared synchronize];
}

+(BOOL)isAppPurchaseWithProductID:(NSString*)productid{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [[shared valueForKey:productid]  boolValue];
}


+(void)saveWidgetState:(NSString*)state{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:state forKey:@"WidgetState"];
    [shared synchronize];
}

+(NSString*)widgetSatte{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [shared valueForKey:@"WidgetState"];
}


+(void)saveWidgetResult:(NSString*)result{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];  // APP Group ID
    [shared setObject:result forKey:@"WidgetResult"];
    [shared synchronize];
}

+(NSString*)widgetResult{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [shared valueForKey:@"WidgetResult"];
}


+ (void)saveSayingContentArray:(NSArray*)contentArray{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    [shared setObject:contentArray forKey:@"contentArray"];
    [shared synchronize];

}

+ (NSArray*)takeSayingContent{

     NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
     return [shared valueForKey:@"contentArray"];
}

+(void)saveCurrentCurrency:(NSString*)currentCurrency{
   
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    [shared setObject:currentCurrency forKey:@"CurrentCurrency"];
    [shared synchronize];


}
+(NSString*)takeCurrentCurrency{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [shared valueForKey:@"CurrentCurrency"];

}


+ (void)saveUserInput:(NSString*)input{
  
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    [shared setObject:input forKey:@"UserInput"];
    
    if ([input  intValue] == 0) {
         [shared  setBool:NO forKey:@"IsUserInput"];
    }else{
         [shared  setBool:YES forKey:@"IsUserInput"];
    }

    [shared synchronize];

}
+ (NSString*)takeUserInput{

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [shared valueForKey:@"UserInput"];
}

+ (BOOL)isUserIput{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [[shared valueForKey:@"IsUserInput"]  boolValue];
}


+(void)saveCurrentIndex:(NSString*)index{
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    [shared setObject:index forKey:@"CurrentIndex"];
    
    [shared synchronize];
}

+ (NSString*)takeCurrentIndex{
   
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.company.liuWei"];
    return [shared valueForKey:@"CurrentIndex"];
 
}


+ (NSMutableArray*)readQuestionData{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countryInfro" ofType:nil];
    if (filePath)
    {
        NSString *str = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:NULL];
        if (str)
        {
            NSString *desStr = [DES decryptString:str];
            if(desStr)
            {
                NSData *desData = [desStr dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSPropertyListFormat format;
                
                NSMutableArray* plist = [NSPropertyListSerialization propertyListWithData:desData options:NSPropertyListImmutable format:&format error:&error];
                
                if(!plist){
                    NSLog(@"Error: %@",error);
                }
                return plist;
            }
        }
    }
    return nil;
}


+(BOOL)takeTimeDifference:(NSString*)dateString{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *d=[date dateFromString:dateString];
    NSTimeInterval late=[d timeIntervalSince1970]*1;  //  设定的时间
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;   // 当前时间
    NSTimeInterval cha= now - late;
    
    if (cha>0 && (cha/86400>1)) {
        return YES;
    }else{
        return NO;
    }
}



@end
