//
//  WAPersistencyManager.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WACity.h"

@interface WAPersistencyManager : NSObject

/// Returns an array of currently saved cities
- (NSArray*)getCities;

/// Add a city to the currently saved cities at the provided position
- (void)addCity:(WACity*)city
        atIndex:(int)index;

/// Delete a city from the currently saved cities at the provided position
- (void)deleteCityAtIndex:(int)index;

/// Saves the downloaded images in the Documents directory
- (void)saveImage:(UIImage*)image
         filename:(NSString*)filename;

/// Gets the specified image from the Documents directory
- (UIImage*)getImage:(NSString*)filename;

/// Archives current list of cities
- (void)saveCities;

@end
