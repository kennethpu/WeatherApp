//
//  WAWeather.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WAWeather.h"

@implementation WAWeather

/// Initializes a current Weather instance with the required properties
- (id)initWithCondition:(NSString*)condition
                   icon:(NSString*)icon
            temperature:(NSString*)temperature
                 hiTemp:(NSString*)hiTemp
                 loTemp:(NSString*)loTemp
                   time:(NSString*)time
{
    self = [super init];
    if (self) {
        _condition = condition;
        _icon = [self imageName:icon];
        _temperature = temperature;
        _hiTemp = hiTemp;
        _loTemp = loTemp;
        _time = time;
    }
    return self;
}

/// Initializes an hourly Weather instance with the required properties
- (id)initWithIcon:(NSString*)icon
       temperature:(NSString*)temperature
              time:(NSString*)time
{
    return [self initWithCondition:nil
                              icon:icon
                       temperature:temperature
                            hiTemp:nil
                            loTemp:nil
                              time:time];
}

/// Initializes a daily Weather instance with the given properties
- (id)initWIthIcon:(NSString*)icon
            hiTemp:(NSString*)hiTemp
            loTemp:(NSString*)loTemp
              time:(NSString*)time
{
    return [self initWithCondition:nil
                              icon:icon
                       temperature:nil
                            hiTemp:hiTemp
                            loTemp:loTemp
                              time:time];
}

/// Returns a dictionary to map icon urls returned by weather underground to our own custom icons
+ (NSDictionary*)imageMap {
    static NSDictionary *_imageMap = nil;
    if (!_imageMap) {
        _imageMap = @{
                      @"http://icons.wxug.com/i/c/k/chanceflurries.gif" : @"snow",
                      @"http://icons.wxug.com/i/c/k/flurries.gif"       : @"snow",
                      @"http://icons.wxug.com/i/c/k/chancesnow.gif"     : @"snow",
                      @"http://icons.wxug.com/i/c/k/snow.gif"           : @"snow",
                      @"http://icons.wxug.com/i/c/k/chancerain.gif"     : @"rain",
                      @"http://icons.wxug.com/i/c/k/rain.gif"           : @"rain",
                      @"http://icons.wxug.com/i/c/k/chancesleet.gif"    : @"rain",
                      @"http://icons.wxug.com/i/c/k/sleet.gif"          : @"rain",
                      @"http://icons.wxug.com/i/c/k/chancetstorms.gif"  : @"tstorms",
                      @"http://icons.wxug.com/i/c/k/tstorms.gif"        : @"tstorms",
                      @"http://icons.wxug.com/i/c/k/cloudy.gif"         : @"cloudy",
                      @"http://icons.wxug.com/i/c/k/fog.gif"            : @"fog",
                      @"http://icons.wxug.com/i/c/k/hazy.gif"           : @"fog",
                      @"http://icons.wxug.com/i/c/k/mostlycloudy.gif"   : @"partlysunny",
                      @"http://icons.wxug.com/i/c/k/mostlysunny.gif"    : @"partlysunny",
                      @"http://icons.wxug.com/i/c/k/partlycloudy.gif"   : @"partlysunny",
                      @"http://icons.wxug.com/i/c/k/partlysunny.gif"    : @"partlysunny",
                      @"http://icons.wxug.com/i/c/k/clear.gif"          : @"clear",
                      @"http://icons.wxug.com/i/c/k/sunny.gif"          : @"clear",
                      
                      @"http://icons.wxug.com/i/c/k/nt_chanceflurries.gif"  : @"snow",
                      @"http://icons.wxug.com/i/c/k/nt_flurries.gif"        : @"snow",
                      @"http://icons.wxug.com/i/c/k/nt_chancesnow.gif"      : @"snow",
                      @"http://icons.wxug.com/i/c/k/nt_snow.gif"            : @"snow",
                      @"http://icons.wxug.com/i/c/k/nt_chancerain.gif"      : @"nt_rain",
                      @"http://icons.wxug.com/i/c/k/nt_rain.gif"            : @"nt_rain",
                      @"http://icons.wxug.com/i/c/k/nt_chancesleet.gif"     : @"nt_rain",
                      @"http://icons.wxug.com/i/c/k/nt_sleet.gif"           : @"nt_rain",
                      @"http://icons.wxug.com/i/c/k/nt_chancetstorms.gif"   : @"tstorms",
                      @"http://icons.wxug.com/i/c/k/nt_tstorms.gif"         : @"tstorms",
                      @"http://icons.wxug.com/i/c/k/nt_cloudy.gif"          : @"cloudy",
                      @"http://icons.wxug.com/i/c/k/nt_fog.gif"             : @"fog",
                      @"http://icons.wxug.com/i/c/k/nt_hazy.gif"            : @"fog",
                      @"http://icons.wxug.com/i/c/k/nt_mostlycloudy.gif"    : @"nt_partlysunny",
                      @"http://icons.wxug.com/i/c/k/nt_mostlysunny.gif"     : @"nt_partlysunny",
                      @"http://icons.wxug.com/i/c/k/nt_partlycloudy.gif"    : @"nt_partlysunny",
                      @"http://icons.wxug.com/i/c/k/nt_partlysunny.gif"     : @"nt_partlysunny",
                      @"http://icons.wxug.com/i/c/k/nt_clear.gif"           : @"nt_clear",
                      @"http://icons.wxug.com/i/c/k/nt_sunny.gif"           : @"nt_clear"
                      };
    }
    return _imageMap;
}

/// Use icon url returned by weather underground to get corresponding art asset
- (NSString*)imageName:(NSString*)iconURL
{
    return [WAWeather imageMap][iconURL];
}

@end
