//
//  WACoreDataDailyWeather.h
//  WeatherApp
//
//  Created by Kenneth Pu on 7/1/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WACoreDataCity;

@interface WACoreDataDailyWeather : NSManagedObject

@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * hiTemp;
@property (nonatomic, retain) NSNumber * loTemp;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) WACoreDataCity *city;

@end
