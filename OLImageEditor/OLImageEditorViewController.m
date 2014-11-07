//
//  ImageEditorViewController.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLImageEditorViewController.h"
#import "OLCropViewController.h"

@interface OLImageEditorViewController ()
@property (nonatomic, strong) OLCropViewController *cropVC;
@end

@implementation OLImageEditorViewController

- (id)init {
    OLCropViewController *cropVC = [[OLCropViewController alloc] init];
    if (self = [super initWithRootViewController:cropVC]) {
        self.cropVC = cropVC;
    }
    return self;
}

- (void)setImage:(id<OLImageEditorImage>)image {
    self.cropVC.image = image;
}

- (id<OLImageEditorImage>)image {
    return self.cropVC.image;
}

-(void)setCropboxGuideImageToSize:(CGSize)size{
    [self.cropVC setCropboxGuideImageToSize:size];
}

- (void)viewDidLoad {
    self.navigationBarHidden = NO;
    self.toolbarHidden = NO;
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbarHidden = NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}


@end
