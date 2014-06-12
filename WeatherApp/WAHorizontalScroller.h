//
//  WAHorizontalScroller.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/10/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollerDelegate;

@interface WAHorizontalScroller : UIView <UIScrollViewDelegate>

@property (weak) id<HorizontalScrollerDelegate> delegate;

- (void)reload;

@end

@protocol HorizontalScrollerDelegate <NSObject>

@required
// ask the delegate how many views he wants to present inside the horizontal scroller
- (NSInteger)numberOfViewsForHorizontalScroller:(WAHorizontalScroller*)scroller;

// ask the delegate to return the view that should appear at <index>
- (UIView*)horizontalScroller:(WAHorizontalScroller*)scroller viewAtIndex:(int)index;

// inform the delegate that the view at <index> has been clicked
- (void)horizontalScroller:(WAHorizontalScroller*)scroller clickedViewAtIndex:(int)index;

@optional
// ask the delegate for the index of the initial view to display. this method is optional
// and defaults to 0 if its not implemented by the delegate
- (NSInteger)initialViewIndexForHorizontalScroller:(WAHorizontalScroller*)scroller;

@end
