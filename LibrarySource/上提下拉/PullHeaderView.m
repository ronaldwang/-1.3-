//
//	PullHeaderViewController.m
//	PullCycle
//
//	Created by Zachary Witte on 12/10/13.
//	Copyright (c) 2013 Zachary Witte. All rights reserved.
//

#import "PullHeaderView.h"
#import "Localisator.h"
#import "Util.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define HEIGHT 65.0f;

#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PullHeaderView (Private)
- (void)setState:(PullHeaderState)aState;
@end

@implementation PullHeaderView

@synthesize delegate=_delegate;

static int kObservingContentSizeChangesContext;

- (id)initWithScrollView:(UIScrollView*)sv arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subText:(NSString *)subText position:(PullHeaderPosition)position  {
	
	CGRect frame = [self makeFrameForScrollView:sv position:position];
	if((self = [super initWithFrame:frame])) {
//		CALayer *layer;
		_originalContentSize = sv.contentSize;
		_scrollView = sv;
		[_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
       
        if (position == PullHeaderBottom) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, self.frame.size.width, 20.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            label.textColor = textColor;
            label.text = subText;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _subTextLabel=label;
            _subTextLabel.hidden = YES;
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 25.0f)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            label.textColor = textColor;
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            _statusLabel=label;
                        
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view.frame = CGRectMake(25.0f, 28.0f, 20.0f, 20.0f);
            [self addSubview:view];
            _activityView = view;
            
            [self setState:PullHeaderNormal];
            [self updateSubtext];
        }
        _position = position;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    _statusLabel.textColor = [Util  shareInstance].themeColor;
	[self pullHeaderScrollViewDidChangeSize:_scrollView];
	[_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
}

- (void)viewDidDisappear:(BOOL)animated {
	[_scrollView removeObserver:self forKeyPath:@"contentSize" context:&kObservingContentSizeChangesContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kObservingContentSizeChangesContext) {
        UIScrollView *sv = object;
		[self pullHeaderScrollViewDidChangeSize:sv];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (CGRect)makeFrameForScrollView:(UIScrollView*)scollView position:(PullHeaderPosition)position {
	float y;
	if (position == PullHeaderTop) {
		y = 0.0f - HEIGHT;
	} else {
       
        if (scollView.contentSize.height <= IPHONE_HEIGHT) {
            y = IPHONE_HEIGHT;
        }else{
            y = scollView.contentSize.height + 20;
        }
	}
	float h = HEIGHT;
	CGRect frame = CGRectMake(0.0f, y, scollView.contentSize.width, h);
	return frame;
}

#pragma mark -
#pragma mark Setters

- (void)updateSubtext {
	if ([self.delegate respondsToSelector:@selector(pullHeaderSubtext:)]) {
		_subTextLabel.text = [self.delegate pullHeaderSubtext:self];
		[[NSUserDefaults standardUserDefaults] setObject:_subTextLabel.text forKey:@"PullHeaderView_subText"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		_subTextLabel.text = nil;
	}
}

- (void)setState:(PullHeaderState)aState{
	
	switch (aState) {
		case PullHeaderPulling:
            _statusLabel.text = LOCALIZATION(@"PullHeaderPulling");
                    break;
		case PullHeaderNormal:
            
            _statusLabel.text = LOCALIZATION(@"PullHeaderNormal");
			[_activityView stopAnimating];
                break;
		case PullHeaderLoading:
//			_statusLabel.text = LOCALIZATION(@"PullHeaderLoading");
			[_activityView startAnimating];
        
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)pullHeaderScrollViewDidScroll:(UIScrollView *)sv {
    
     _statusLabel.textColor = [Util  shareInstance].themeColor;
    
	if (_state == PullHeaderLoading) {
		CGFloat offset = MAX(sv.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		if (_position == PullHeaderTop) {
			sv.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		} else {
			sv.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
		}
	} else if (sv.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(pullHeaderSourceIsLoading:)]) {
			_loading = [_delegate pullHeaderSourceIsLoading:self];
		}
		
		if (_position == PullHeaderTop) {
			if (_state == PullHeaderPulling && sv.contentOffset.y > -65.0f && sv.contentOffset.y < 0.0f && !_loading) {
				[self setState:PullHeaderNormal];
			} else if (_state == PullHeaderNormal && sv.contentOffset.y < -65.0f && !_loading) {
				[self setState:PullHeaderPulling];
			}
		} else {
			float pos = sv.contentOffset.y+sv.frame.size.height - sv.contentSize.height;
			if (_state == PullHeaderPulling && pos > 0.0f && pos < 65.0f && !_loading) {
				[self setState:PullHeaderNormal];
			} else if (_state == PullHeaderNormal && pos > 65.0f && !_loading) {
				[self setState:PullHeaderPulling];
			}
		}

		if (sv.contentInset.top != 0) {
			sv.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		}
	}
}

- (void)pullHeaderScrollViewDidEndDragging:(UIScrollView *)sv {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(pullHeaderSourceIsLoading:)]) {
		_loading = [_delegate pullHeaderSourceIsLoading:self];
	}
	
	BOOL bounds = NO;
	if (_position == PullHeaderTop && sv.contentOffset.y <= - 65.0f) {
		bounds = YES;
	} else if (_position == PullHeaderBottom && sv.contentOffset.y+sv.frame.size.height - sv.contentSize.height >= 50.0f) {
		bounds = YES;
	}
	
	if (bounds && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(pullHeaderDidTrigger:)]) {
			[_delegate pullHeaderDidTrigger:self];
		}
		[self setState:PullHeaderLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		UIEdgeInsets insets;
		if (_position == PullHeaderTop) {
			insets = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			sv.contentInset = insets;
		} else {
			sv.contentSize = CGSizeMake(_originalContentSize.width, _originalContentSize.height+60.0f);
		}
		[UIView commitAnimations];
	}
	
}

- (void)pullHeaderScrollViewDataSourceDidFinishedLoading:(UIScrollView *)sv {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[sv setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[sv setContentSize:_originalContentSize];
	[UIView commitAnimations];
	[self setState:PullHeaderNormal];
	
}

- (void)pullHeaderScrollViewDidChangeSize:(UIScrollView*)sv {
	self.frame = [self makeFrameForScrollView:sv position:_position];
}


@end