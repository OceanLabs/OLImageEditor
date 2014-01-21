//
//  ViewController.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "ViewController.h"
#import "OLImageEditorViewController.h"
#import "OLImageEditorImage.h"


@interface ViewController () <OLImageEditorViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) OLImageEditorImage *image;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.image = [OLImageEditorImage imageWithURL:[NSURL URLWithString:@"http://www.deargrumpycat.com/wp-content/uploads/2013/02/Grumpy-Cat1.jpg"]];
}

- (IBAction)onButtonLaunchEditorClicked:(id)sender {
    OLImageEditorViewController *editor = [[OLImageEditorViewController alloc] init];
    editor.delegate = self;
    editor.image = self.image;
    NSLog(@"%f,%f", self.image.transform.tx, self.image.transform.ty);
    [self presentViewController:editor animated:YES completion:NULL];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - OLImageEditorViewControllerDelegate methods 

- (void)imageEditorUserDidDelete:(OLImageEditorViewController *)imageEditorVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditor:(OLImageEditorViewController *)editor userDidSuccessfullyCropImage:(id<OLImageEditorImage>)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    [OLImageEditorImage getCoppedImageFromEditorImage:image size:CGSizeMake(256, 256) progress:nil completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
