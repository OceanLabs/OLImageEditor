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
#import <CTAssetsPickerController.h>

@interface ViewController () <OLImageEditorViewControllerDelegate, UINavigationControllerDelegate, CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) OLImageEditorImage *image1, *image2;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) ALAsset *asset;
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
    
    UIImageOrientation orientation = UIImageOrientationUp;
    NSNumber* orientationValue = [self.asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil) {
        orientation = [orientationValue intValue];
    }

    UIImage *i = [UIImage imageWithCGImage:[self.asset.defaultRepresentation fullResolutionImage] scale:self.asset.defaultRepresentation.scale orientation:orientation];

    OLImageEditorImage *ei = [OLImageEditorImage imageWithImage:i];
    ei.transform = image.transform;
    
    [OLImageEditorImage croppedImageWithEditorImage:ei size:CGSizeMake(1111, 1111) progress:nil completion:^(UIImage *image) {
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"squares.jpeg"]];
        [data writeToFile:filePath atomically:YES];
        NSLog(@"Wrote squares to: %@", filePath);
        
        self.imageView.image = image;
    }];
}

- (IBAction)onButtonPickerClicked:(id)sender {
    CTAssetsPickerController *vc = [[CTAssetsPickerController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - CTAssetsPickerControllerDelegate methods

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        self.asset = assets[0];
        // Retrieve the image orientation from the ALAsset
//        UIImageOrientation orientation = UIImageOrientationUp;
//        NSNumber* orientationValue = [self.asset valueForProperty:@"ALAssetPropertyOrientation"];
//        if (orientationValue != nil) {
//            orientation = [orientationValue intValue];
//        }
        
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [self.asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        UIImage* image = [UIImage imageWithCGImage:[self.asset.defaultRepresentation fullScreenImage]];
        
        OLImageEditorViewController *editor = [[OLImageEditorViewController alloc] init];
        editor.delegate = self;
        editor.image = [OLImageEditorImage imageWithImage:image];
        [self presentViewController:editor animated:YES completion:NULL];
        
        

    }];
}


@end
