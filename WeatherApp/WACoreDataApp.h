//
//  WACoreDataApp.h
//  WeatherApp
//
//  Created by Kenneth Pu on 7/1/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WACoreDataCity;

@interface WACoreDataApp : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *cities;
@end

@interface WACoreDataApp (CoreDataGeneratedAccessors)

- (void)insertObject:(WACoreDataCity *)value inCitiesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCitiesAtIndex:(NSUInteger)idx;
- (void)insertCities:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCitiesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCitiesAtIndex:(NSUInteger)idx withObject:(WACoreDataCity *)value;
- (void)replaceCitiesAtIndexes:(NSIndexSet *)indexes withCities:(NSArray *)values;
- (void)addCitiesObject:(WACoreDataCity *)value;
- (void)removeCitiesObject:(WACoreDataCity *)value;
- (void)addCities:(NSOrderedSet *)values;
- (void)removeCities:(NSOrderedSet *)values;
@end
