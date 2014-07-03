//
//  WALibraryAPI.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WACity.h"
#import "WACoreDataCity.h"

@interface WALibraryAPI : NSObject

/// Returns a shared instance of the LibraryAPI object
+ (WALibraryAPI*)sharedInstance;

/// Returns an array of currently saved cities
- (NSOrderedSet*)getCities;

- (WACoreDataCity*)getCityAtIndex:(int)index;

/// Add a city to the currently saved cities at the provided position
- (void)addCity:(WACity*)city
        atIndex:(int)index;

/// Delete a city from the currently saved cities at the provided position
- (void)deleteCityAtIndex:(int)index;

/// Archives current list of cities
- (void)saveCities;

/// Get the url of the first image resulting from a google image search of the provided query
- (NSString*)getImageUrl:(NSString*)query;

/// Downloads the specified images from the given urls
- (void)downloadImageURL:(NSString*)bgUrl
               imageView:(UIImageView*)imageView;

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
