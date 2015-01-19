//
//  CropViewController.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLCropViewController.h"
#import "OLImageEditorViewController.h"
#import "OLImageEditorImage.h"
#import "OLImageCropView.h"
#import <DACircularProgress/DACircularProgressView.h>

@interface OLCropViewController () <OLImageCropViewDelegate>
@property (nonatomic, strong) OLImageCropView *cropView;
@property (nonatomic, strong) DACircularProgressView *progressView;
@property (nonatomic, strong) UIBarButtonItem *applyButton;
@property (assign, nonatomic) CGSize cropboxGuideSize;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;

@property (strong, nonatomic) UIImageView *cropboxGuideImageViewHighQuality;
@end

@implementation OLCropViewController

- (void)viewDidLoad {
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    self.cropView = [[OLImageCropView alloc] initWithFrame:self.view.bounds cropBoxSize:self.cropboxGuideSize];
    self.cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:self.cropView];
    self.cropView.delegate = self;
    
    
    if (self.cropboxGuideSize.width != 0 && self.cropboxGuideSize.height != 0){
        UIImage *cropboxImageToBeShown = [UIImage imageNamed:@"cropbox_guide"];
        CGFloat cropboxScale = self.cropboxGuideSize.width / cropboxImageToBeShown.size.width;
        cropboxScale = 1 - cropboxScale;
        CGFloat scale = 0.8 * ([UIScreen mainScreen].bounds.size.width / self.cropboxGuideSize.width);
        if (self.cropboxGuideSize.width != 0 && self.cropboxGuideSize.height != 0){
            UIGraphicsBeginImageContext(CGSizeMake((self.cropboxGuideSize.width - 10 *cropboxScale) * scale, (self.cropboxGuideSize.height - 10 *cropboxScale) * scale));
            [cropboxImageToBeShown drawInRect:CGRectMake(0, 0, (self.cropboxGuideSize.width - 10 *cropboxScale) * scale, (self.cropboxGuideSize.height - 10 *cropboxScale) * scale)];
            cropboxImageToBeShown = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        self.cropboxGuideImageViewHighQuality = [[UIImageView alloc] initWithImage:cropboxImageToBeShown];
        [contentView addSubview:self.cropboxGuideImageViewHighQuality];
        self.cropboxGuideImageViewHighQuality.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancelClicked)];
    self.navigationItem.leftBarButtonItem.tag = 200;

    self.applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonApplyClicked)];
    self.navigationItem.rightBarButtonItem = self.applyButton;
    self.applyButton.tintColor = [UIColor colorWithRed:255 / 255.0f green:204 / 255.0f blue:0 alpha:1];
    self.applyButton.enabled = NO;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (!self.hidesDeleteButton) {
        self.deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDeleteClicked)];
        self.deleteButton.tag = 100;
        self.deleteButton.tintColor = [UIColor colorWithRed:203 / 255.0f green:55 / 255.0f blue:37 / 255.0f alpha:1];
        self.toolbarItems = @[flexibleSpace, self.deleteButton];
    }
    
    CGRect f = self.view.bounds;
    f.size.width = 40;
    f.size.height = 40;
    f.origin.x = (self.view.bounds.size.width - f.size.width) / 2;
    f.origin.y = (self.view.bounds.size.height - f.size.height) / 2;
    self.progressView = [[DACircularProgressView alloc] initWithFrame:f];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [contentView addSubview:self.progressView];
    
    [self.image getImageWithProgress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    } completion:^(UIImage *image) {
        self.image.transformFactor = self.cropboxGuideSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            self.cropView.image = image;
            self.cropView.cropTransform = self.image.transform;
//            self.cropView.cropAspectRatio = 1;
//            self.cropView.keepingCropAspectRatio = YES;
        });
    }];
}

-(void)setCropboxGuideImageToSize:(CGSize)size{
    self.cropboxGuideSize = size;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hidesDeleteButton) {
        self.toolbarItems = @[];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)onButtonDeleteClicked {
    OLImageEditorViewController *parent = (OLImageEditorViewController *) self.parentViewController;
    if ([parent.delegate respondsToSelector:@selector(imageEditor:userDidDeleteImage:)]) {
        [parent.delegate imageEditor:parent userDidDeleteImage:self.image];
    }
}

- (void)onButtonCancelClicked {
    OLImageEditorViewController *parent = (OLImageEditorViewController *) self.parentViewController;
    if ([parent.delegate respondsToSelector:@selector(imageEditorUserDidCancel:)]) {
        [parent.delegate imageEditorUserDidCancel:parent];
    } else {
        [parent dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onButtonApplyClicked {
    self.image.transform = self.cropView.cropTransform;
    OLImageEditorViewController *parent = (OLImageEditorViewController *) self.parentViewController;
    if ([parent.delegate respondsToSelector:@selector(imageEditor:userDidSuccessfullyCropImage:)]) {
        [parent.delegate imageEditor:parent userDidSuccessfullyCropImage:self.image];
    } else {
        [parent dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - OLImageCropViewDelegate methods

- (void)imageCropViewUserStartedCroppingImage:(OLImageCropView *)imageCropView {
    self.applyButton.enabled = YES;
}

@end
