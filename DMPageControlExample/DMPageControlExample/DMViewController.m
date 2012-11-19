//
//  DMViewController.m
//  DMPageControlExample
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 11/19/12.
//  Copyright (c) 2012 http://www.danielemargutti.com. All rights reserved.
//

#import "DMViewController.h"
#import "DMPageControl.h"

#define ARC4RANDOM_MAX	0x100000000

@interface DMViewController () {
    IBOutlet    UIScrollView *  scrollView ;
    IBOutlet    DMPageControl*  pageControl;
}

@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUInteger numberOfPages = 6;    
    pageControl = [[DMPageControl alloc] init] ;
    [pageControl setBackgroundColor:[UIColor clearColor]];
	[pageControl setCenter: CGPointMake(self.view.center.x, self.view.bounds.size.height-20.0f)] ;
	[pageControl setNumberOfPages: numberOfPages] ;
	[pageControl setCurrentPage: 0] ;
	[pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
	[pageControl setDefersCurrentPageDisplay: YES] ;
	[pageControl setDotStyle: DMPageControlDotStyle_OnFull_OffFull] ;
    
    UIColor *onColor = [UIColor colorWithWhite: 0.9f alpha: 1.0f];
    UIColor *offColor = [UIColor colorWithWhite: 0.7f alpha: 1.0f];
    
	[pageControl setOnColor: onColor] ;
	[pageControl setOffColor: offColor] ;

    [pageControl setImage:[UIImage imageNamed:@"193-location-arrow"] forPageIndex:0];
    [pageControl setImage:[UIImage imageNamed:@"11-clock"] forPageIndex:1];
 
    
    [self.view addSubview:pageControl];
    
    
    [scrollView setPagingEnabled: YES] ;
	[scrollView setContentSize: CGSizeMake(scrollView.bounds.size.width * numberOfPages, scrollView.bounds.size.height)] ;
    
    UILabel *pageLabel ;
	CGRect pageFrame ;
	UIColor *color ;
	for (int i = 0 ; i < numberOfPages ; i++)
	{
		// determine the frame of the current page
		pageFrame = CGRectMake(i * scrollView.bounds.size.width, 0.0f, scrollView.bounds.size.width, scrollView.bounds.size.height) ;
		
		// create a page as a simple UILabel
		pageLabel = [[UILabel alloc] initWithFrame: pageFrame] ;
		
		// add it to the scroll view
		[scrollView addSubview: pageLabel] ;
		
		// determine and set its (random) background color
		color = [UIColor colorWithRed: (CGFloat)arc4random()/ARC4RANDOM_MAX green: (CGFloat)arc4random()/ARC4RANDOM_MAX blue: (CGFloat)arc4random()/ARC4RANDOM_MAX alpha: 1.0f] ;
		[pageLabel setBackgroundColor: color] ;
		
		// set some label properties
		[pageLabel setFont: [UIFont boldSystemFontOfSize: 200.0f]] ;
		[pageLabel setTextAlignment: UITextAlignmentCenter] ;
		[pageLabel setTextColor: [UIColor darkTextColor]] ;
		
		// set the label's text as the letter corresponding to the current page index
		[pageLabel setText: [NSString stringWithFormat: @"%d", i+1]] ;
	}
}



#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (pageControl.currentPage != nearestNumber)
	{
		pageControl.currentPage = nearestNumber ;
		
		// if we are dragging, we want to update the page control directly during the drag
		if (scrollView.dragging)
			[pageControl updateCurrentPageDisplay] ;
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[pageControl updateCurrentPageDisplay] ;
}




- (void)pageControlClicked:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
