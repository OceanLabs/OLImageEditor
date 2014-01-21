//
//  OLImageCropView.h
//  OLImageEditor
//
//  Created by Deon Botha on 21/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OLImageCropView;

@protocol OLImageCropViewDelegate <NSObject>
- (void)imageCropViewUserStartedCroppingImage:(OLImageCropView *)imageCropView;
@end

@interface OLImageCropView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter = hasUserCroppedImage) BOOL userCroppedImage;
@property (nonatomic, weak) id<OLImageCropViewDelegate> delegate;
@property (nonatomic, assign) CGAffineTransform cropTransform;
@end
