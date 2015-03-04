//
//  MCSampleCardCollectionViewCell.h
//  MCCardPickerCollectionViewController
//
//  Created by Michael Chen on 2015/3/4.
//  Copyright (c) 2015年 Michael Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCSampleCardCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, assign) CGFloat cardRadius;
@property (nonatomic, strong) UIImage *blurImage;
@end
