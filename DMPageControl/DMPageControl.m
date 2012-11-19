//
//  DMPageControl.m
//  An high customizable alternative to UIPageControl
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 17/11/12.
//  Copyright (c) 2012 http://www.danielemargutti.com All rights reserved.
//  Based upon an original work of Damien DeVille (DDPageControl - http://ddeville.me)
//

#import "DMPageControl.h"

#define kDefaultIndicatorDiameter   7.0f
#define kDefaultIndicatorSpace      12.0f


@interface DMPageControl() {
    NSMutableArray*     imagesArray;
}

@end

@implementation DMPageControl

@synthesize dotStyle;
@synthesize numberOfPages,currentPage,hidesForSinglePage,defersCurrentPageDisplay;
@synthesize onColor,offColor,indicatorDiameter,indicatorSpace;

- (id)initWithDotStyle:(DMPageControlDotStyle) style {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.dotStyle = style;
    }
    return self;
}

- (id)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialProperties];
    }
    return self;
}

- (void) awakeFromNib {
    [self setupInitialProperties];
}

- (void) setupInitialProperties {
    self.dotStyle = DMPageControlDotStyle_OnFull_OffFull;
    self.offColor = nil;
    self.onColor = nil;
    self.indicatorDiameter = kDefaultIndicatorDiameter;
    self.indicatorSpace = kDefaultIndicatorSpace;
    self.onColor = [UIColor colorWithWhite: 1.0f alpha: 1.0f];
    self.offColor = [UIColor colorWithWhite: 0.7f alpha: 0.5f];
}

- (void)setCurrentPage:(NSInteger)pageNumber {
	// no need to update in that case
	if (currentPage == pageNumber)
		return ;
	
	// determine if the page number is in the available range
	currentPage = MIN(MAX(0, pageNumber), numberOfPages - 1) ;
	
	// in case we do not defer the page update, we redraw the view
	if (self.defersCurrentPageDisplay == NO) [self setNeedsDisplay] ;
}

- (void) setNumberOfPages:(NSInteger)newNumberOfPages {
    numberOfPages = newNumberOfPages;
    
    imagesArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    for (NSInteger k = 0; k < numberOfPages; ++k) [imagesArray addObject:[NSNull null]];
    
    currentPage = MIN(MAX(0,currentPage),numberOfPages-1);
    self.bounds = self.bounds;
    [self setNeedsDisplay];
    
    [self setHidden: (newNumberOfPages < 2 && hidesForSinglePage)];
}

- (void) setHidesForSinglePage:(BOOL)hide {
    hidesForSinglePage = hide;
    [self setHidden: (self.numberOfPages < 2 && hidesForSinglePage)];
}

- (void) setDefersCurrentPageDisplay:(BOOL)defers {
    defersCurrentPageDisplay = defers;
}

- (void) setDotStyle:(DMPageControlDotStyle)style {
    dotStyle = style;
    [self setNeedsDisplay];
}

- (void) setOnColor:(UIColor *)color {
    onColor = color;
    [self setNeedsDisplay];
}

- (void) setOffColor:(UIColor *)color {
    offColor = color;
    [self setNeedsDisplay];
}

- (void) setIndicatorSpace:(CGFloat)space {
    indicatorSpace = space;
    self.bounds = self.bounds;
    [self setNeedsDisplay];
}

- (void) setFrame:(CGRect)aFrame {
    aFrame.size = [self sizeForNumberOfPages: numberOfPages];
    super.frame = aFrame;
}

- (void) setBounds:(CGRect)aBounds {
    aBounds.size = [self sizeForNumberOfPages:numberOfPages];
    super.bounds = aBounds;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
	return CGSizeMake(pageCount * self.indicatorDiameter + (pageCount - 1) * self.indicatorSpace + 44.0f,
                      MAX(44.0f, self.indicatorDiameter + 4.0f)) ;
}

- (void)updateCurrentPageDisplay {
	if (self.defersCurrentPageDisplay == NO) // ignores this method if the value of defersPageIndicatorUpdate is NO
		return ;
	[self setNeedsDisplay] ;
}

- (void) setImage:(UIImage *) icon forPageIndex:(NSInteger) index {
    if (index >= self.numberOfPages) return;
    [imagesArray replaceObjectAtIndex:index withObject:(icon == nil ? [NSNull class] : icon)];
    [self setNeedsDisplay];
}

- (UIImage *) imageForPageIndex:(NSInteger) pageIndex {
    if (pageIndex >= self.numberOfPages || [imagesArray objectAtIndex:pageIndex] == [NSNull null]) return nil;
    return [imagesArray objectAtIndex:pageIndex];
}

- (BOOL) isOpaque {
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// get the touch location
	UITouch *theTouch = [touches anyObject] ;
	CGPoint touchLocation = [theTouch locationInView: self] ;
	
	// check whether the touch is in the right or left hand-side of the control
    NSInteger newPage;
	if (touchLocation.x < (self.bounds.size.width / 2))
		newPage = MAX(self.currentPage - 1, 0) ;
	else
		newPage = MIN(self.currentPage + 1, numberOfPages - 1) ;
	
    self.currentPage = newPage;
    
	[self sendActionsForControlEvents: UIControlEventValueChanged] ;
}

- (void) drawRect:(CGRect)rect {    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGRect currentBounds = self.bounds;

    CGFloat itemWidth = self.numberOfPages * self.indicatorDiameter + MAX(0,self.numberOfPages-1) * self.indicatorSpace;
    CGPoint itemLocation = CGPointMake( CGRectGetMidX(currentBounds)-itemWidth / 2.0f,
                                        CGRectGetMidY(currentBounds)-self.indicatorDiameter / 2.0f);
    
    
    for (NSInteger i = 0; i < numberOfPages; i++) {
        CGRect itemRect = CGRectMake(itemLocation.x, itemLocation.y, self.indicatorDiameter, self.indicatorDiameter);
        BOOL isSelectedItem = (i == self.currentPage);
        
        UIImage *itemImage = [[self imageForPageIndex:i] imageTintedWithColor:(isSelectedItem ? self.onColor : self.offColor)];
        if (itemImage == nil) // we want to use classic dot's indicators
            [self drawDotIndicatorInContext:context
                                   withRect:itemRect
                         isCurrentSelection:isSelectedItem];
        else // we want to use images as indicator for this item
            [itemImage drawInRect:CGRectInset(itemRect, -1.5f, -1.5f)]; // a little bigger than dots
        
        itemLocation.x += (self.indicatorDiameter + self.indicatorSpace);
    }
    CGContextRestoreGState(context);
}

- (void) drawDotIndicatorInContext:(CGContextRef) contextRef withRect:(CGRect) itemRect isCurrentSelection:(BOOL) isSelected {
    if (isSelected) {
        if (self.dotStyle == DMPageControlDotStyle_OnFull_OffFull || self.dotStyle == DMPageControlDotStyle_OnFull_OffEmpty) {
            CGContextSetFillColorWithColor(contextRef, self.onColor.CGColor) ;
            CGContextFillEllipseInRect(contextRef, CGRectInset(itemRect, -0.5f, -0.5f)) ;
        } else {
            CGContextSetStrokeColorWithColor(contextRef, self.onColor.CGColor) ;
            CGContextStrokeEllipseInRect(contextRef, itemRect) ;
        }
    } else {
        if (self.dotStyle == DMPageControlDotStyle_OnEmpty_OffEmpty || self.dotStyle == DMPageControlDotStyle_OnFull_OffEmpty) {
            CGContextSetStrokeColorWithColor(contextRef, self.offColor.CGColor) ;
            CGContextStrokeEllipseInRect(contextRef, itemRect) ;
        } else {
            CGContextSetFillColorWithColor(contextRef, self.offColor.CGColor) ;
            CGContextFillEllipseInRect(contextRef, CGRectInset(itemRect, -0.5f, -0.5f)) ;
        }
    }
}
@end


@implementation UIImage (UIImageTint)

- (UIImage *)imageTintedWithColor:(UIColor *)color {
	return [self imageTintedWithColor:color fraction:0.0];
}

- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction {
	if (color) {
		UIImage *image;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
			UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0);
		}
#else
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
			UIGraphicsBeginImageContext([self size]);
		}
#endif
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		[color set];
		UIRectFill(rect);
        
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		if (fraction > 0.0)
			[self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	return self;
}

@end

