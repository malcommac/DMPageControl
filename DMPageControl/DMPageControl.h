//
//  DMPageControl.h
//  An high customizable alternative to UIPageControl
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 17/11/12.
//  Copyright (c) 2012 http://www.danielemargutti.com All rights reserved.
//  Based upon an original work of Damien DeVille (DDPageControl - http://ddeville.me)
//

#import <UIKit/UIKit.h>

enum {
    DMPageControlDotStyle_OnFull_OffFull    = 0,    // ON/OFF FULL
    DMPageControlDotStyle_OnFull_OffEmpty   = 1,    // ON FULL, OFF EMPTY
    
    DMPageControlDotStyle_OnEmpty_OffFull   = 1,    // ON EMPTY, OFF FULL
    DMPageControlDotStyle_OnEmpty_OffEmpty  = 2     // ON/OFF EMPTY
}; typedef NSUInteger DMPageControlDotStyle;

@interface DMPageControl : UIControl { }

// Control settings
@property (nonatomic,assign) DMPageControlDotStyle  dotStyle;
@property (nonatomic,assign) NSInteger              numberOfPages;
@property (nonatomic,assign) NSInteger              currentPage;

@property (nonatomic,assign) BOOL                   hidesForSinglePage;
@property (nonatomic,assign) BOOL                   defersCurrentPageDisplay;

// Dot Style
@property (nonatomic,retain) UIColor*               onColor;
@property (nonatomic,retain) UIColor*               offColor;
@property (nonatomic,assign) CGFloat                indicatorDiameter;
@property (nonatomic,assign) CGFloat                indicatorSpace;

// Supported inits
- (id)initWithDotStyle:(DMPageControlDotStyle) style;
- (id)init;
- (id)initWithFrame:(CGRect)frame;

// Set/get icon for a single item
- (void) setImage:(UIImage *) icon forPageIndex:(NSInteger) index;
- (UIImage *) imageForPageIndex:(NSInteger) pageIndex;

- (void)updateCurrentPageDisplay;

@end

// Support UIImage Category (you can move it in a separate file too)

@interface UIImage (UIImageTint)
- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end