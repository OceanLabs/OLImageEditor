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
#import <DACircularProgress/DACircularProgressView.h>
#import <PECropView.h>

@interface OLCropViewController ()
@property (nonatomic, strong) PECropView *cropView;
@property (nonatomic, strong) DACircularProgressView *progressView;
@end

@implementation OLCropViewController

- (void)viewDidLoad {
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    self.cropView = [[PECropView alloc] initWithFrame:self.view.bounds];
    [contentView addSubview:self.cropView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonCancelClicked)];

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onButtonApplyClicked)];
    self.navigationItem.rightBarButtonItem = applyButton;
    applyButton.tintColor = [UIColor colorWithRed:255 / 255.0f green:204 / 255.0f blue:0 alpha:1];
    applyButton.enabled = NO;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonDeleteClicked)];
    deleteButton.tintColor = [UIColor colorWithRed:203 / 255.0f green:55 / 255.0f blue:37 / 255.0f alpha:1];
    self.toolbarItems = @[flexibleSpace, deleteButton];
    
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
        self.progressView.progress = progress;
    } completion:^(UIImage *image) {
        self.progressView.hidden = YES;
        self.cropView.image = image;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.cropView.cropAspectRatio = 1;
//    self.cropView.keepingCropAspectRatio = YES;
}

- (void)onButtonDeleteClicked {
    OLImageEditorViewController *parent = (OLImageEditorViewController *) self.parentViewController;
    if ([parent.delegate respondsToSelector:@selector(imageEditorUserDidDelete:)]) {
        [parent.delegate imageEditorUserDidDelete:parent];
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
    
}

@end
