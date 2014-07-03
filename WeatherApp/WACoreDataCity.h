//
//  WACoreDataCity.h
//  WeatherApp
//
//  Created by Kenneth Pu on 7/3/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WACoreDataApp, WACoreDataCurrentWeather, WACoreDataDailyWeather, WACoreDataHourlyWeather;

@interface WACoreDataCity : NSManagedObject

@property (nonatomic, strong) NSString * imgUrl;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) WACoreDataApp *app;
@property (nonatomic, strong) WACoreDataCurrentWeather *currentWeather;
@property (nonatomic, strong) NSOrderedSet *dailyForecast;
@property (nonatomic, strong) NSOrderedSet *hourlyForecast;
@end

@interface WACoreDataCity (CoreDataGeneratedAccessors)

- (void)insertObject:(WACoreDataDailyWeather *)value inDailyForecastAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDailyForecastAtIndex:(NSUInteger)idx;
- (void)insertDailyForecast:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDailyForecastAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDailyForecastAtIndex:(NSUInteger)idx withObject:(WACoreDataDailyWeather *)value;
- (void)replaceDailyForecastAtIndexes:(NSIndexSet *)indexes withDailyForecast:(NSArray *)values;
- (void)addDailyForecastObject:(WACoreDataDailyWeather *)value;
- (void)removeDailyForecastObject:(WACoreDataDailyWeather *)value;
- (void)addDailyForecast:(NSOrderedSet *)values;
- (void)removeDailyForecast:(NSOrderedSet *)values;
- (void)insertObject:(WACoreDataHourlyWeather *)value inHourlyForecastAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHourlyForecastAtIndex:(NSUInteger)idx;
- (void)insertHourlyForecast:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHourlyForecastAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHourlyForecastAtIndex:(NSUInteger)idx withObject:(WACoreDataHourlyWeather *)value;
- (void)replaceHourlyForecastAtIndexes:(NSIndexSet *)indexes withHourlyForecast:(NSArray *)values;
- (void)addHourlyForecastObject:(WACoreDataHourlyWeather *)value;
- (void)removeHourlyForecastObject:(WACoreDataHourlyWeather *)value;
- (void)addHourlyForecast:(NSOrderedSet *)values;
- (void)removeHourlyForecast:(NSOrderedSet *)values;
@end
