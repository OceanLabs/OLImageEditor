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
    self.image2 = [OLImageEditorImage imageWithURL:[NSURL URLWithString:@"http://co.oceanlabs.psprintstudio.s3.amazonaws.com/border.png"]];
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
    
    [OLImageEditorImage croppedImageWithEditorImage:image size:CGSizeMake(1111, 1111) progress:nil completion:^(UIImage *image) {
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"squares.jpeg"]];
        [data writeToFile:filePath atomically:YES];
        NSLog(@"Wrote squares to: %@", filePath);
    }];

    [OLImageEditorImage croppedImageWithEditorImage:image size:CGSizeMake(1111, 1111) progress:nil completion:^(UIImage *image) {
        NSLog(@"got image with size: %fx%f scale:%f", image.size.width, image.size.height, image.scale);
        self.imageView.image = image;
    }];
    
    
    [OLImageEditorImage croppedImageWithEditorImage:image size:CGSizeMake(656, 656) progress:nil completion:^(UIImage *image) {
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"polaroids_mini.jpeg"]];
        [data writeToFile:filePath atomically:YES];
        NSLog(@"Wrote polaroids mini to: %@", filePath);
    }];
}

@end
