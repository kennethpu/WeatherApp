//
//  WACity.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WACity.h"
#import "WALibraryAPI.h"

@implementation WACity

/// Initializes a City instance with the required properties
/// @param name english name of city
/// @param state english name of state/country containing city
/// @param imgUrl url of image to display for city
/// @param currentCondition weather object describing current weather conditions
/// @param hourlyforecast nsarray of weather objects denoting hourly forecast
/// @param dailyForecast nsarray of weather objects denoting daily forecast
- (id)initWithName:(NSString*)name
             state:(NSString*)state
            imgUrl:(NSString*)imgUrl
 currentConditions:(WAWeather*)currentConditions
    hourlyForecast:(NSArray*)hourlyForecast
     dailyForecast:(NSArray*)dailyForecast
{
    self = [super init];
    if (self) {
        _name = name;
        _state = state;
        _imgUrl = imgUrl;
        self.currentConditions = currentConditions;
        self.hourlyForecast = hourlyForecast;
        self.dailyForecast = dailyForecast;
    }
    return self;
}

/// Initializes a City instance with the required properties
/// @param name english name of city
/// @param state english name of state/country containing city
/// @param imgUrl url of image to display for city
- (id)initWithName:(NSString*)name
             state:(NSString*)state
            imgUrl:(NSString*)imgUrl
{
    return [self initWithName:name
                        state:state
                       imgUrl:imgUrl
            currentConditions:nil
               hourlyForecast:nil
                dailyForecast:nil];
}

/// Archives an instance of a City
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.imgUrl forKey:@"img_url"];
    [aCoder encodeObject:self.currentConditions forKey:@"current"];
    [aCoder encodeObject:self.hourlyForecast forKey:@"hourly"];
    [aCoder encodeObject:self.dailyForecast forKey:@"daily"];
}

/// Unarchives an instance of a City
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _state = [aDecoder decodeObjectForKey:@"state"];
        _imgUrl = [aDecoder decodeObjectForKey:@"img_url"];
        self.currentConditions = [aDecoder decodeObjectForKey:@"current"];
        self.hourlyForecast = [aDecoder decodeObjectForKey:@"hourly"];
        self.dailyForecast = [aDecoder decodeObjectForKey:@"daily"];
    }
    return self;
}


@end
