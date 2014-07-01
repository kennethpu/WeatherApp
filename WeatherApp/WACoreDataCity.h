//
//  WACoreDataCity.h
//  WeatherApp
//
//  Created by Kenneth Pu on 7/1/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WACoreDataApp, WACoreDataCurrentWeather, WACoreDataDailyWeather, WACoreDataHourlyWeather;

@interface WACoreDataCity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) WACoreDataApp *app;
@property (nonatomic, retain) WACoreDataCurrentWeather *currentWeather;
@property (nonatomic, retain) NSOrderedSet *hourlyForecast;
@property (nonatomic, retain) NSOrderedSet *dailyForecast;
@end

@interface WACoreDataCity (CoreDataGeneratedAccessors)

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
@end
