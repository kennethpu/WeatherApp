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
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", query];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    NSError *error;
    NSData *queryData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    id queryResults = [NSJSONSerialization JSONObjectWithData:queryData options:0 error:&error];
    
    NSDictionary *responseData = queryResults[@"responseData"];
    NSDictionary *imageData = responseData[@"results"][0];
    
    NSString *imageUrl = imageData[@"url"];
    
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
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
//    NSDictionary *response = weatherResults[@"response"];
    NSDictionary *currentObservation = weatherResults[@"current_observation"];
    
    NSString *condition = currentObservation[@"weather"];
    NSString *icon = currentObservation[@"icon_url"];
    double tempValue = [currentObservation[@"temp_f"] doubleValue];
    NSString *temperature = [NSString stringWithFormat:@"%.0f", tempValue];
    NSString *time = [currentObservation[@"observation_time"] componentsSeparatedByString:@", "][1];
    
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
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/hourly/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
    //    NSDictionary *response = weatherResults[@"response"];
    NSArray *forecast = weatherResults[@"hourly_forecast"];
    
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
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/forecast10day/q/%@/%@.json", WUKey, state, city];
    NSString *webStringUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:webStringUrl];
    
    NSError *error;
    NSData *weatherData = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
//    NSDictionary *response = weatherResults[@"response"];
    NSDictionary *forecast = weatherResults[@"forecast"];
    NSDictionary *simpleForecast = forecast[@"simpleforecast"];
    NSArray *simpleForecastDay = simpleForecast[@"forecastday"];
    
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
