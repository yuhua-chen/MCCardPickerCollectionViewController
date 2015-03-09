//
//  MCCardPickerCollectionViewLayout.h
//  MCCardPickerCollectionViewController
//
//  Created by Michael Chen on 2015/3/4.
//  Copyright (c) 2015年 Michael Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCCardPickerCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat flickVelocity;
@property (readonly) NSInteger currentIndex;
@end
