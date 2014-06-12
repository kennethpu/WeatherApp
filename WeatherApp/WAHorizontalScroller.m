//
//  WAHorizontalScroller.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/10/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WAHorizontalScroller.h"

// Constants to make it easy to modify layout
#define VIEW_PADDING 3
#define VIEWS_OFFSET 30

@implementation WAHorizontalScroller {
    UIScrollView *scroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}


/// Handles taps and centers tapped view in scroll view
- (void)scrollerTapped:(UITapGestureRecognizer*)gesture
{
    // Get touch location
    CGPoint location = [gesture locationInView:gesture.view];
    
    // Iterate over subviews (album covers) and perform a hit test to find the view that was tapped
    for (int index=0; index<[self.delegate numberOfViewsForHorizontalScroller:self]; index++) {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location)) {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}

/// Reloads album data to scroll view, should be called when data is changed
- (void)reload
{
    // Nothing to load if there is no delegate
    if (self.delegate == nil) return;
    
    // Remove all subviews previously added to scroll view
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // Position subviews inside the scroll view starting from VIEWS_OFFSET
    CGFloat xValue = VIEWS_OFFSET;
    for (int i=0; i<[self.delegate numberOfViewsForHorizontalScroller:self]; i++) {
        // Add a view at the right position
        xValue += VIEW_PADDING;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, 0, view.frame.size.width, view.frame.size.height);
        [scroller addSubview:view];
        xValue += view.frame.size.width;
    }
    
    // Set content offset for scroll view to allow user to scroll through album covers
    [scroller setContentSize:CGSizeMake(xValue+VIEWS_OFFSET,self.frame.size.height)];
    
    // If an initial subview is specified, center scroller on it
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)]) {
        int initialViewIndex = [self.delegate initialViewIndexForHorizontalScroller:self];
        UIView *initialView = scroller.subviews[initialViewIndex];
        [scroller setContentOffset:CGPointMake(initialView.frame.origin.x - self.frame.size.width/2 + initialView.frame.size.width/2, 0) animated:YES];
    }
}

/// Handles case where HorizontalScroller is added to another view
- (void)didMoveToSuperview
{
    [self reload];
}

/// Centers the current view in the center of scroll view
- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + ((self.frame.size.width-VIEWS_OFFSET*2)/2) + VIEW_PADDING;
    int viewIndex = xFinal / (self.frame.size.width-VIEWS_OFFSET*2+VIEW_PADDING);
    UIView *view = scroller.subviews[viewIndex];
    [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

/// Handles when user stops dragging inside scroll view
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

/// Handles when the scroll view has come to a complete stop
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

@end
