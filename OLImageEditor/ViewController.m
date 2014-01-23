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
@property (nonatomic, strong) OLImageEditorImage *image1, *image2;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.image1 = [OLImageEditorImage imageWithURL:[NSURL URLWithString:@"http://www.deargrumpycat.com/wp-content/uploads/2013/02/Grumpy-Cat1.jpg"]];
    self.image2 = [OLImageEditorImage imageWithURL:[NSURL URLWithString:@"https://distilleryimage10.s3.amazonaws.com/8ef7854a658711e3944b126a49f9c5ea_8.jpg"]];
}

- (IBAction)onButtonLaunchEditorClicked:(id)sender {
    OLImageEditorViewController *editor = [[OLImageEditorViewController alloc] init];
    editor.delegate = self;
    editor.image = self.image1;
    [self presentViewController:editor animated:YES completion:NULL];
}

- (IBAction)onButtonLaunchEditorClicked2:(id)sender {
    OLImageEditorViewController *editor = [[OLImageEditorViewController alloc] init];
    editor.delegate = self;
    editor.image = self.image2;
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
    [OLImageEditorImage getCoppedImageFromEditorImage:image size:CGSizeMake(656, 656/*self.imageView.frame.size.width * 2, self.imageView.frame.size.height * 2*/) progress:nil completion:^(UIImage *image) {
        self.imageView.image = image;
        
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
        
    }];
}

@end
