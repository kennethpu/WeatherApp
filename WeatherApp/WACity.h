//
//  WACity.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAWeather.h"

@interface WACity : NSObject <NSCoding>

/// English name of city
@property (nonatomic, copy, readonly) NSString *name;

/// English name of state/country containing city
@property (nonatomic, copy, readonly) NSString *state;

/// Url of image to display in background of CityView
@property (nonatomic, copy, readonly) NSString *imgUrl;

/// Initializes a City instance with the required properties
/// @param name english name of city
/// @param state english name of state/country containing city
/// @param imgUrl url of image to display for city
- (id)initWithName:(NSString*)name
             state:(NSString*)state
            imgUrl:(NSString*)imgUrl;

@end
