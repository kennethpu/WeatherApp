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

/// City Properties
@property (nonatomic, copy) NSString *name, *state, *imgUrl;

/// Initializes a City instance with the required properties
- (id)initWithName:(NSString*)name
             state:(NSString*)state;

/// Initializes a City instance with the required properties
- (id)initWithName:(NSString*)name
             state:(NSString*)state
            imgUrl:(NSString*)imgUrl;

@end
