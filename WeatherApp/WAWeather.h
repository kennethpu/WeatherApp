//
//  WAWeather.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAWeather : NSObject <NSCoding>

/// Short string describing current weather conditions
@property (nonatomic, copy, readonly) NSString *condition;

/// Current temperature in fahrenheit
@property (nonatomic, copy, readonly) NSString *temperature;

/// Predicted daily high temperature in fahrenheit
@property (nonatomic, copy, readonly) NSString *hiTemp;

/// Predicted daily low temperature in fahrenheit
@property (nonatomic, copy, readonly) NSString *loTemp;

/// Icon image name to display current weather conditions
@property (nonatomic, copy, readonly) NSString *icon;

/// Time corresponding to current weather
@property (nonatomic, copy, readonly) NSString *time;

/// Initializes a current Weather instance with the required properties
- (id)initWithCondition:(NSString*)condition
                iconUrl:(NSString*)iconUrl
            temperature:(NSString*)temperature
                 hiTemp:(NSString*)hiTemp
                 loTemp:(NSString*)loTemp
                   time:(NSString*)time;

/// Initializes an hourly Weather instance with the required properties
- (id)initWithIconUrl:(NSString*)iconUrl
          temperature:(NSString*)temperature
                 time:(NSString*)time;

/// Initializes a daily Weather instance with the given properties
- (id)initWithIconUrl:(NSString*)iconUrl
               hiTemp:(NSString*)hiTemp
               loTemp:(NSString*)loTemp
                 time:(NSString*)time;

@end
