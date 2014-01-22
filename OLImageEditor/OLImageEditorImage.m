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
    [editorImage getImageWithProgress:progressHandler completion:^(UIImage *image) {
        // Create a graphics context the size of the bounding rectangle
        UIImage *cropboxGuideImage = [UIImage imageNamed:@"cropbox_guide"];
        CGSize cropboxGuideSize = CGSizeMake(cropboxGuideImage.size.width - 10, cropboxGuideImage.size.height - 10);
        NSAssert(cropboxGuideSize.width == cropboxGuideSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
        NSAssert(destSize.width == destSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
        
        CGFloat imgWidth = image.size.width * image.scale;
        CGFloat imgHeight = image.size.height * image.scale;
        
        // scale image to aspect fill initial crop box
        CGFloat scale = 1;
        if (imgWidth < imgHeight) {
            scale = cropboxGuideSize.width / imgWidth;
        } else {
            scale = cropboxGuideSize.height / imgHeight;
        }
        
        // scale cropped image from cropbox size to dest size
        scale *= destSize.width / cropboxGuideSize.width;

        // do the transforms and draw the image
        UIGraphicsBeginImageContext(destSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(destSize.width / 2, destSize.height / 2));
        CGContextConcatCTM(context, CGAffineTransformMakeScale(scale, scale));
        CGContextConcatCTM(context, editorImage.transform);
        
        [image drawAtPoint:CGPointMake(-imgWidth / 2, -imgHeight / 2)];
        UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        completionHandler(imageCopy);
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
}

- (CGAffineTransform)transform {
    return self.affineTransform;
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
