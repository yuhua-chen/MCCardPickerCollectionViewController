//
//  MCCardPickerCollectionViewController.h
//  MCCardPickerCollectionViewController
//
//  Created by Michael Chen on 2015/3/4.
//  Copyright (c) 2015年 Michael Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCCardPickerCollectionViewFlowLayout.h"

@protocol MCCardPickerCollectionViewControllerDelegate;

@interface MCCardPickerCollectionViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MCCardPickerCollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIView *presentingView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, assign) id<MCCardPickerCollectionViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>delegate;

- (void)presentInViewController:(UIViewController *)viewController;
- (void)dismissFromParentViewController;

@end

@protocol MCCardPickerCollectionViewControllerDelegate <NSObject>

- (void)cardPickerCollectionViewController:(MCCardPickerCollectionViewController *)cardPickerCollectionViewController preparePresentingView:(UIView *)presentingView fromSelectedCell:(UICollectionViewCell *)cell;

@end