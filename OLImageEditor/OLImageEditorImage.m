//
//  OLImageEditorImage.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLImageEditorImage.h"
#import <SDWebImageManager.h>

@interface OLImageEditorImage ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id<SDWebImageOperation> inProgressDownload;
@property (nonatomic, assign) CGAffineTransform affineTransform;
@property (nonatomic, assign) BOOL hasTransformed;
@end

@implementation OLImageEditorImage

- (id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
        self.affineTransform = CGAffineTransformIdentity;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
        self.affineTransform = CGAffineTransformIdentity;
    }
    
    return self;
}

+ (OLImageEditorImage *)imageWithImage:(UIImage *)image {
    return [[OLImageEditorImage alloc] initWithImage:image];
}

+ (OLImageEditorImage *)imageWithURL:(NSURL *)url {
    return [[OLImageEditorImage alloc] initWithURL:url];
}

+ (void)getCoppedImageFromEditorImage:(id<OLImageEditorImage>)editorImage size:(CGSize)destSize progress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    NSLog(@"size: %f %f", destSize.width, destSize.height);
    [editorImage getImageWithProgress:progressHandler completion:^(UIImage *image) {
        // Create a graphics context the size of the bounding rectangle
        UIImage *cropboxGuideImage = [UIImage imageNamed:@"cropbox_guide"];
        CGSize cropboxGuideSize = CGSizeMake(cropboxGuideImage.scale * (cropboxGuideImage.size.width - 10), cropboxGuideImage.scale * (cropboxGuideImage.size.height - 10));
        NSAssert(cropboxGuideSize.width == cropboxGuideSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
        NSAssert(destSize.width == destSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
        
        CGFloat imgWidth = image.size.width * image.scale;
        CGFloat imgHeight = image.size.height * image.scale;
        
        // scale image to aspect fill initial crop box
        CGFloat cropboxScale = 1;
        if (imgWidth < imgHeight) {
            cropboxScale = cropboxGuideSize.width / imgWidth;
        } else {
            cropboxScale = cropboxGuideSize.height / imgHeight;
        }
        
        NSLog(@"imageSize: %fx%f, imageScale:%f coord scale: %f", imgWidth, imgHeight, image.scale, cropboxScale);
        // scale cropped image from cropbox size to dest size
        CGFloat destScale = destSize.width / cropboxGuideSize.width;
        CGFloat scale = cropboxScale * destScale;
        
        NSLog(@"Scale: %f cropboxScale: %f destScale: %f", scale, cropboxScale, destScale);
        
        // do the transforms and draw the image
        UIGraphicsBeginImageContextWithOptions(destSize, YES, 2.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(destSize.width / 2, destSize.height / 2));
        CGContextConcatCTM(context, CGAffineTransformMakeScale(destScale, destScale));
        CGContextConcatCTM(context, editorImage.transform);
        
        [image drawAtPoint:CGPointMake(-imgWidth / 2, -imgHeight / 2)];
        
        UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSLog(@"imageCopy Size: %f %f", imageCopy.size.width, imageCopy.size.height);
        
        CGImageRef img = CGImageCreateWithImageInRect(imageCopy.CGImage, CGRectMake(destSize.width / 2, destSize.height / 2, destSize.width, destSize.height));
        imageCopy = [UIImage imageWithCGImage:img];
        
        NSLog(@"imageCopy Size: %f %f", imageCopy.size.width, imageCopy.size.height);
        
        completionHandler(imageCopy);
        
//        NSLog(@"image scale: %f", image.scale);
//
//        CGImageRef source = image.CGImage;
//        CGContextRef context = CGBitmapContextCreate(NULL, destSize.width, destSize.height, CGImageGetBitsPerComponent(source), 0, CGImageGetColorSpace(source), CGImageGetBitmapInfo(source));
//        CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
//        CGContextSetFillColorWithColor(context,  [[UIColor redColor] CGColor]);
//        CGContextFillRect(context, CGRectMake(0, 0, destSize.width, destSize.height));
//        
//        CGAffineTransform uiCoords = CGAffineTransformMakeScale(destSize.width / cropboxGuideSize.width, destSize.height / cropboxGuideSize.height);
//        uiCoords = CGAffineTransformTranslate(uiCoords, cropboxGuideSize.width / 2.0, cropboxGuideSize.height / 2.0);
//        uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
//        CGContextConcatCTM(context, uiCoords);
//        
//        CGContextConcatCTM(context, editorImage.transform);
//        CGContextScaleCTM(context, 1.0, -1.0);
//        //CGContextConcatCTM(context, orientationTransform);
//        
//        CGContextDrawImage(context, CGRectMake(-image.size.width / 2.0, -image.size.height/2.0, image.size.width, image.size.height), source);
//        
//        CGImageRef resultRef = CGBitmapContextCreateImage(context);
//        CGContextRelease(context);
//        
//        completionHandler([UIImage imageWithCGImage:resultRef scale:1.0 orientation:UIImageOrientationUp]);
    }];
}

//+ (void)transform:(CGAffineTransform*)transform andSize:(CGSize *)size forOrientation:(UIImageOrientation)orientation
//{
//    *transform = CGAffineTransformIdentity;
//    BOOL transpose = NO;
//    
//    switch(orientation)
//    {
//        case UIImageOrientationUp:// EXIF 1
//        case UIImageOrientationUpMirrored:{ // EXIF 2
//        } break;
//        case UIImageOrientationDown: // EXIF 3
//        case UIImageOrientationDownMirrored: { // EXIF 4
//            *transform = CGAffineTransformMakeRotation(M_PI);
//        } break;
//        case UIImageOrientationLeftMirrored: // EXIF 5
//        case UIImageOrientationLeft: {// EXIF 6
//            *transform = CGAffineTransformMakeRotation(M_PI_2);
//            transpose = YES;
//        } break;
//        case UIImageOrientationRightMirrored: // EXIF 7
//        case UIImageOrientationRight: { // EXIF 8
//            *transform = CGAffineTransformMakeRotation(-M_PI_2);
//            transpose = YES;
//        } break;
//        default:
//            break;
//    }
//    
//    if(orientation == UIImageOrientationUpMirrored || orientation == UIImageOrientationDownMirrored ||
//       orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored) {
//        *transform = CGAffineTransformScale(*transform, -1, 1);
//    }
//    
//    if(transpose) {
//        *size = CGSizeMake(size->height, size->width);
//    }
//}

- (void)setTransform:(CGAffineTransform)transform {
    self.affineTransform = transform;
    self.transformed = YES;
}

- (CGAffineTransform)transform {
    return self.affineTransform;
}

- (void)setTransformed:(BOOL)transformed {
    self.hasTransformed = YES;
}

- (BOOL)transformed {
    return self.hasTransformed;
}

- (void)getImageWithProgress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    self.inProgressDownload = [[SDWebImageManager sharedManager] downloadWithURL:self.url
                                                                         options:0
                                                                        progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                if (progressHandler) progressHandler(receivedSize / (float) expectedSize);
                                                                            });
                                                                        }
                                                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               if (finished) {
                                                                                   self.inProgressDownload = nil;
                                                                                   self.image = image;
                                                                                   completionHandler(image);
                                                                               }
                                                                           });
                                                                       }];
}

- (void)unloadImage {
    if (self.url) {
        self.image = nil;
    }
}

- (void)cancelAnyLoading {
    [self.inProgressDownload cancel];
}

@end
