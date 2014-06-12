//
//  WAHTTPClient.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAWeather.h"

@interface WAHTTPClient : NSObject

/// Get the url of the first image resulting from a google image search of the provided query
- (NSString*)getImageUrl:(NSString*)query;

/// Downloads an image linked to by the provided image url
- (UIImage*)downloadImage:(NSString*)url;

/// Fetches current weather conditions for the provided location
- (WAWeather*)getCurrentWeatherForCity:(NSString*)city
                                 state:(NSString*)state;

/// Fetches predicted hourly weather conditions for the provided location
- (NSArray*)getHourlyForecastForCity:(NSString*)city
                               state:(NSString*)state;

/// Fetches predicted daily weather conditions for the provided location
- (NSArray*)getDailyForecastForCity:(NSString*)city
                                state:(NSString*)state;

@end
