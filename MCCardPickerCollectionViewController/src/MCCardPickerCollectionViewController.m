//
//  MCCardPickerCollectionViewController.m
//  MCCardPickerCollectionViewController
//
//  Created by Michael Chen on 2015/3/4.
//  Copyright (c) 2015年 Michael Chen. All rights reserved.
//

#import "MCCardPickerCollectionViewController.h"

static CGFloat const kMCCardPickerCollectionViewBottomInset = 4;
static CGFloat const kPanTriggerFadeOutDistance = 200.0;
static CGFloat const kPanTriggerExpandDistance = 50.0;

@interface MCCardPickerCollectionViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

- (CGSize)cardSize;
- (CGFloat)cardScaleRatio;
- (CGRect)collectionViewFrame;
- (UICollectionViewCell *)selectedCell;
@end

@implementation MCCardPickerCollectionViewController

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.bottomInset = kMCCardPickerCollectionViewBottomInset;

		self.layout = [[MCCardPickerCollectionViewFlowLayout alloc] init];
		self.layout.minimumLineSpacing = 10;
		self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		self.layout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 20);
		self.layout.itemSize = self.cardSize;
	}
	return self;
}

- (void)loadView
{
	[super loadView];

	self.view.backgroundColor = [UIColor blackColor];

	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 40)];
	[self.view addSubview:self.headerView];

	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 25)];
	titleLabel.text = @"Pick One!";
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	[self.headerView addSubview:titleLabel];

	self.collectionView = [[UICollectionView alloc] initWithFrame:self.collectionViewFrame collectionViewLayout:self.layout];
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.collectionView.clipsToBounds = NO;
	self.collectionView.scrollEnabled = YES;
	self.collectionView.showsVerticalScrollIndicator = NO;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.collectionView];

	self.presentingView = [[UIView alloc] initWithFrame:self.view.frame];
	self.presentingView.alpha = 0;
	[self.view addSubview:self.presentingView];

	self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
	self.dismissButton.frame = CGRectMake(10, 30, 60, 30);
	[self.dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
	[self.dismissButton setTitle:@"X" forState:UIControlStateNormal];
	[self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.view addSubview:self.dismissButton];

	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hanldePan:)];
	pan.delegate = self;
	[self.collectionView addGestureRecognizer:pan];
}

#pragma mark - Actions

- (void)dismiss:(id)sender
{
	[UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.view.frame = CGRectOffset(self.view.frame, 0, CGRectGetHeight(self.view.frame));
	} completion:^(BOOL finished) {
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	}];
}

- (void)closeCell:(id)sender
{
	[self restoreCellLayout:self.selectedCell isAnimated:YES];
	[self dismissButtonSwitchToCloseCell:NO];
}

- (void)hanldePan:(UIPanGestureRecognizer *)gesture
{
	typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
		UIPanGestureRecognizerDirectionUndefined,
		UIPanGestureRecognizerDirectionUp,
		UIPanGestureRecognizerDirectionDown
	};

	static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan: {
			if (direction == UIPanGestureRecognizerDirectionUndefined) {
				CGPoint velocity = [gesture velocityInView:gesture.view];
				if (velocity.y > 0) {
					direction = UIPanGestureRecognizerDirectionDown;
				} else {
					direction = UIPanGestureRecognizerDirectionUp;
					[self.delegate cardPickerCollectionViewController:self preparePresentingView:self.presentingView fromSelectedCell:self.selectedCell];
				}
			}

			break;
		}

		case UIGestureRecognizerStateChanged: {
			CGPoint point = [gesture translationInView:self.view];
			if (direction == UIPanGestureRecognizerDirectionDown) {
				if (point.y<0) {
					[self restoreLayout:NO];
				}
				else {
					CGFloat alpha = 1 - fabs(point.y/kPanTriggerFadeOutDistance);
					self.headerView.alpha = alpha;
					self.dismissButton.alpha = alpha;
					self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:alpha];

					CGRect frame = self.collectionView.frame;
					frame.origin.y = self.collectionViewFrame.origin.y + MAX(point.y, 0);
					self.collectionView.frame = frame;
				}
			}
			else if (direction == UIPanGestureRecognizerDirectionUp) {
				UICollectionViewCell *cell = self.selectedCell;
				if (point.y>0) {
					[self restoreCellLayout:cell isAnimated:NO];
				}
				else {
					CGFloat delta = MIN(1, fabs(point.y/kPanTriggerExpandDistance));
					[self expandPresentingViewWithCell:cell andScaleDelta:delta];
				}
			}

			break;
		}

		case UIGestureRecognizerStateEnded: {
			if (direction == UIPanGestureRecognizerDirectionDown) {
				BOOL shouldDismiss = CGRectGetMinY(self.collectionView.frame) > kPanTriggerFadeOutDistance;
				if (shouldDismiss) {
					[self fadeOut];
				}
				else {
					[self restoreLayout:YES];
				}
			}
			else if (direction == UIPanGestureRecognizerDirectionUp) {
				CGFloat xScale = self.presentingView.transform.a;
				CGFloat halfScale = self.cardScaleRatio + (1-self.cardScaleRatio)/2;
				if (xScale < halfScale) {
					[self restoreCellLayout:self.selectedCell isAnimated:YES];
					[self dismissButtonSwitchToCloseCell:NO];
				}
				else {
					[self expandPresentingViewWithCell:self.selectedCell andScaleDelta:1];
					[self dismissButtonSwitchToCloseCell:YES];
				}
			}

			direction = UIPanGestureRecognizerDirectionUndefined;
			break;
		}

		default:
			break;
	}
}

#pragma mark - Public Methods

- (void)presentInViewController:(UIViewController *)viewController
{
	UIView *parentView = viewController.view;
	self.view.frame = CGRectOffset(parentView.frame, 0, CGRectGetHeight(parentView.frame));
	[UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[parentView addSubview:self.view];
		self.view.frame = parentView.frame;
	} completion:^(BOOL finished) {
		[viewController addChildViewController:self];
	}];
}

- (void)dismissFromParentViewController
{
	[self dismiss:nil];
}

#pragma mark - Private Methods

- (void)fadeOut
{
	[UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.collectionView.frame = CGRectOffset(self.collectionView.frame, 0, CGRectGetHeight(self.view.frame));
		self.headerView.alpha = 0;
		self.dismissButton.alpha = 0;
		self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
	} completion:^(BOOL finished) {
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
		[self restoreLayout:NO];
	}];
}

- (void)restoreLayout:(BOOL)animated
{
	NSTimeInterval duration = animated ? 0.25 : 0;
	[UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.collectionView.frame = [self collectionViewFrame];
		self.headerView.alpha = 1;
		self.dismissButton.alpha = 1;
		self.view.backgroundColor = [UIColor blackColor];
	} completion:NULL];
}

- (void)restoreCellLayout:(UICollectionViewCell *)cell isAnimated:(BOOL)animated
{
	NSTimeInterval duration = animated ? 0.25 : 0;
	[UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		cell.transform = CGAffineTransformMakeScale(1, 1);
		cell.alpha = 1;
		self.presentingView.alpha = 0;
		self.presentingView.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:NULL];
}

- (void)expandPresentingViewWithCell:(UICollectionViewCell *)cell andScaleDelta:(CGFloat )delta
{
	CGFloat scale = 1 + delta * 0.18;
	cell.transform = CGAffineTransformMakeScale(scale,scale);
	cell.alpha = 1 - delta * 2;
	self.presentingView.alpha = delta * 2;

	scale = self.cardScaleRatio + delta * (1 - self.cardScaleRatio);
	CGFloat topOffset = self.collectionViewFrame.origin.y * self.cardScaleRatio;
	CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, topOffset - topOffset * delta);
	CGAffineTransform s = CGAffineTransformMakeScale(scale, scale);
	self.presentingView.transform = CGAffineTransformConcat(s, t);
}

- (void)dismissButtonSwitchToCloseCell:(BOOL)isToCell
{
	if (isToCell) {
		[self.dismissButton removeTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
		[self.dismissButton addTarget:self action:@selector(closeCell:) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[self.dismissButton removeTarget:self action:@selector(closeCell:) forControlEvents:UIControlEventTouchUpInside];
		[self.dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
	}
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView == self.collectionView) {
		return;
	}

	if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		CGFloat y = scrollView.contentOffset.y;
		if (y<0) {
			CGFloat delta = 1 - MIN(1, fabs(y/kPanTriggerExpandDistance));
			[self expandPresentingViewWithCell:self.selectedCell andScaleDelta:delta];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (scrollView == self.collectionView) {
		return;
	}

	CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.panGestureRecognizer.view];
	if (velocity.y>0 && scrollView.contentOffset.y <=0) {
		[self restoreCellLayout:self.selectedCell isAnimated:YES];
		[self dismissButtonSwitchToCloseCell:NO];
	}
	else {
		[self expandPresentingViewWithCell:self.selectedCell andScaleDelta:1];
	}

}

#pragma mark - UIGestureRecongizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
	CGPoint velocity = [panGestureRecognizer velocityInView:self.collectionView];
	BOOL isVerticalPan = fabs(velocity.y) > fabs(velocity.x);
	BOOL isScrolling = self.collectionView.isDragging || self.collectionView.isDecelerating;
	return isVerticalPan && !isScrolling;
}

#pragma mark - Properties

- (void)setDelegate:(id<MCCardPickerCollectionViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>)delegate
{
	_delegate = delegate;
	self.collectionView.delegate = delegate;
	self.collectionView.dataSource = delegate;
}

- (CGFloat)cardScaleRatio
{
	return self.cardSize.width / self.view.frame.size.width;
}

- (CGSize)cardSize
{
	CGRect frame = self.view.bounds;
	frame.size.width -= self.layout.sectionInset.left + self.layout.sectionInset.right;
	frame.size.height = CGRectGetHeight(self.collectionViewFrame) - self.layout.sectionInset.top;
	return frame.size;
}

- (CGRect)collectionViewFrame
{
	CGRect frame = CGRectZero;
	frame.origin.y = CGRectGetMaxY(self.headerView.frame);
	frame.size.width = CGRectGetWidth(self.view.frame);
	frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y + self.bottomInset;
	return frame;
}

- (UICollectionViewCell *)selectedCell
{
	return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.layout.currentIndex inSection:0]];
}
@end
