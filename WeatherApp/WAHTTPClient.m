//
//  WAHTTPClient.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WAHTTPClient.h"

const NSString *WUKey = @"4ef3ba9d0ac7d8b9";

@implementation WAHTTPClient

/// Get the url of the first image resulting from a google image search of the provided query
- (NSString*)getImageUrl:(NSString*)query
{
    // Construct query url
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", query];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    // Get response data
    NSError *error;
    NSData *queryData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    id queryResults = [NSJSONSerialization JSONObjectWithData:queryData options:0 error:&error];
    NSDictionary *responseData = queryResults[@"responseData"];
    
    // Get image url from response data
    int i = 0;
    NSDictionary *imageData = responseData[@"results"][i];
    
    // Get next image url if current url does not end in .jpg/.png/.gif
    NSString *imageUrl = imageData[@"url"];
    while ([imageUrl characterAtIndex:[imageUrl length]-4] != L'.') {
        i++;
        imageData = responseData[@"results"][i];
        imageUrl = imageData[@"url"];
    }
    
    // Return image url
    return imageUrl;
}

/// Downloads an image linked to by the provided image url
- (UIImage*)downloadImage:(NSString*)url
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:data];
}

/// Fetches current weather conditions for the provided location
- (WAWeather*)getCurrentWeatherForCity:(NSString*)city
                                 state:(NSString*)state
{
    // Construct query url
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    // Get response data, check for errors
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (weatherData == nil || error != nil) {
        return nil;
    }
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    if (error != nil) {
        return nil;
    }
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // Get current observation data, check for errors
    NSDictionary *currentObservation = weatherResults[@"current_observation"];
    if (currentObservation == nil) {
        return nil;
    }
    
    // Extract weather information from current observation data
    NSString *condition = currentObservation[@"weather"];
    NSString *icon = currentObservation[@"icon_url"];
    double tempValue = [currentObservation[@"temp_f"] doubleValue];
    NSString *temperature = [NSString stringWithFormat:@"%.0f", tempValue];
    NSString *time = [currentObservation[@"observation_time"] componentsSeparatedByString:@", "][1];
    
    // Initialize a new WAWeather instance and return it
    WAWeather *currentWeather = [[WAWeather alloc] initWithCondition:condition
                                                                icon:icon
                                                         temperature:temperature
                                                              hiTemp:nil
                                                              loTemp:nil
                                                                time:time];
    return currentWeather;
}

/// Fetches predicted hourly weather conditions for the provided location
- (NSArray*)getHourlyForecastForCity:(NSString*)city
                              state:(NSString*)state
{
    // Construct query url
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/hourly/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    // Get response data, check for errors
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (weatherData == nil || error != nil) {
        return nil;
    }
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    if (error != nil) {
        return nil;
    }
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // Get hourly forecast data, check for errors
    NSArray *forecast = weatherResults[@"hourly_forecast"];
    if (forecast == nil) {
        return nil;
    }
    
    // Extract weather information from hourly forecast data
    NSMutableArray *hourlyForecast = [NSMutableArray array];
    for (int i=0; i<=5; i++) {
        NSDictionary *forecastHour = forecast[i];
        NSString *icon = forecastHour[@"icon_url"];
        NSString *temperature = forecastHour[@"temp"][@"english"];
        NSString *hour = [forecastHour[@"FCTTIME"][@"civil"] componentsSeparatedByString:@":"][0];
        NSString *ampm = forecastHour[@"FCTTIME"][@"ampm"];
        NSString *time = [NSString stringWithFormat:@"%@ %@", hour, ampm];
        [hourlyForecast addObject:[[WAWeather alloc] initWithIcon:icon temperature:temperature time:time]];
    }
    return hourlyForecast;
}

/// Fetches predicted daily weather conditions for the provided location
- (NSArray*)getDailyForecastForCity:(NSString*)city
                                 state:(NSString*)state
{
    // Construct query url
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/forecast10day/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    // Get response data, check for errors
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (weatherData == nil || error != nil) {
        return nil;
    }
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    if (error != nil) {
        return nil;
    }
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // Get daily forecast data, check for errors
    NSDictionary *forecast = weatherResults[@"forecast"];
    if (forecast == nil) {
        return nil;
    }
    NSDictionary *simpleForecast = forecast[@"simpleforecast"];
    NSArray *simpleForecastDay = simpleForecast[@"forecastday"];
    
    // Extract weather information from daily forecast data
    NSMutableArray *dailyForecast = [NSMutableArray array];
    for (int i=1; i<=6; i++) {
        NSDictionary *simpleForecastPeriod = simpleForecastDay[i];
        NSString *icon = simpleForecastPeriod[@"icon_url"];
        NSString *hiTemp = simpleForecastPeriod[@"high"][@"fahrenheit"];
        NSString *loTemp = simpleForecastPeriod[@"low"][@"fahrenheit"];
        NSString *time = simpleForecastPeriod[@"date"][@"weekday"];
        [dailyForecast addObject:[[WAWeather alloc] initWIthIcon:icon hiTemp:hiTemp loTemp:loTemp time:time]];
    }
    return dailyForecast;
}

@end
