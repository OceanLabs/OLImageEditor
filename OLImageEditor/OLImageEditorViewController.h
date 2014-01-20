//
//  ImageEditorViewController.h
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OLImageEditorImage;
@class OLImageEditorViewController;

@protocol OLImageEditorViewControllerDelegate <NSObject>
@optional
- (void)imageEditorUserDidCancel:(OLImageEditorViewController *)imageEditorVC;
- (void)imageEditorUserDidDelete:(OLImageEditorViewController *)imageEditorVC;
- (void)imageEditor:(OLImageEditorViewController *)editor userDidSuccessfullyCropImage:(id<OLImageEditorImage>)image;
@required
@end

@interface OLImageEditorViewController : UINavigationController
@property (nonatomic, strong) id<OLImageEditorImage> image;
@property (nonatomic, weak) id<OLImageEditorViewControllerDelegate, UINavigationControllerDelegate> delegate;
@end
