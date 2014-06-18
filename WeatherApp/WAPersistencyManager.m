//
//  WAPersistencyManager.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WAPersistencyManager.h"

@interface WAPersistencyManager () {
    // A mutable array of cities
    NSMutableArray *cities;
}
@end

@implementation WAPersistencyManager

- (id)init
{
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/cities.bin"]];
        cities = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (cities == nil) {
            cities = [NSMutableArray arrayWithArray:
                      @[[[WACity alloc] initWithName:@"San Francisco"
                                               state:@"California"
                                              imgUrl:@"http://upload.wikimedia.org/wikipedia/en/7/75/DowntownSF.jpg"],
                        [[WACity alloc] initWithName:@"Taipei"
                                               state:@"Taiwan"
                                              imgUrl:@"http://www.celestica.com/uploadedImages/Worldwide_Locations/English/taiwan_Taipei-101.jpg"]]];
        }
    }
    return self;
}

/// Returns an array of currently saved cities
- (NSArray*)getCities
{
    return cities;
}

/// Add a city to the currently saved cities at the provided position
- (void)addCity:(WACity*)city
        atIndex:(int)index
{
    if (cities.count >= index) {
        [cities insertObject:city atIndex:index];
    } else {
        [cities addObject:city];
    }
}

/// Delete a city from the currently saved cities at the provided position
- (void)deleteCityAtIndex:(int)index
{
    [cities removeObjectAtIndex:index];
}

/// Saves the downloaded images in the Documents directory
- (void)saveImage:(UIImage*)image
         filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

/// Gets the specified image from the Documents directory
- (UIImage*)getImage:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    return [UIImage imageWithData:data];
}

/// Archives current list of cities
- (void)saveCities
{
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/cities.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cities];
    [data writeToFile:filename atomically:YES];
}

@end
