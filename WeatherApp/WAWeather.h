//
//  WAWeather.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAWeather : NSObject

/// Weather Properties
@property (nonatomic, copy, readonly) NSString *condition, *temperature, *hiTemp, *loTemp, *icon, *time;

/// Initializes a current Weather instance with the required properties
- (id)initWithCondition:(NSString*)condition
                   icon:(NSString*)icon
            temperature:(NSString*)temperature
                 hiTemp:(NSString*)hiTemp
                 loTemp:(NSString*)loTemp
                   time:(NSString*)time;

/// Initializes an hourly Weather instance with the required properties
- (id)initWithIcon:(NSString*)icon
       temperature:(NSString*)temperature
              time:(NSString*)time;

/// Initializes a daily Weather instance with the given properties
- (id)initWIthIcon:(NSString*)icon
            hiTemp:(NSString*)hiTemp
            loTemp:(NSString*)loTemp
              time:(NSString*)time;

@end
