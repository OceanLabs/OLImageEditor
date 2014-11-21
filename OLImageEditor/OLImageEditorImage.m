//
//  OLImageEditorImage.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLImageEditorImage.h"
#import <SDWebImageManager.h>
#import <tgmath.h>

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

+ (void)transform:(CGAffineTransform *)transform andSize:(CGSize *)size forOrientation:(UIImageOrientation)orientation {
    *transform = CGAffineTransformIdentity;
    BOOL transpose = NO;
    
    switch(orientation)
    {
        case UIImageOrientationUp:// EXIF 1
        case UIImageOrientationUpMirrored:{ // EXIF 2
        } break;
        case UIImageOrientationDown: // EXIF 3
        case UIImageOrientationDownMirrored: { // EXIF 4
            *transform = CGAffineTransformMakeRotation(M_PI);
        } break;
        case UIImageOrientationLeftMirrored: // EXIF 5
        case UIImageOrientationLeft: {// EXIF 6
            *transform = CGAffineTransformMakeRotation(M_PI_2);
            transpose = YES;
        } break;
        case UIImageOrientationRightMirrored: // EXIF 7
        case UIImageOrientationRight: { // EXIF 8
            *transform = CGAffineTransformMakeRotation(-M_PI_2);
            transpose = YES;
        } break;
        default:
            break;
    }
    
    if(orientation == UIImageOrientationUpMirrored || orientation == UIImageOrientationDownMirrored ||
       orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored) {
        *transform = CGAffineTransformScale(*transform, -1, 1);
    }
    
    if(transpose) {
        *size = CGSizeMake(size->height, size->width);
    }
}

+ (void)croppedImageWithEditorImage:(id<OLImageEditorImage>)editorImage size:(CGSize)destSize progress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    [editorImage getImageWithProgress:progressHandler completion:^(UIImage *image) {
        CGAffineTransform tr = editorImage.transform;
        CGSize initialCropboxSize;
        if ([editorImage respondsToSelector:@selector(transformFactor)]){
            initialCropboxSize = editorImage.transformFactor;
        }
        UIImage *croppedImage = [self croppedImageWithImage:image transform:tr size:destSize initialCropboxSize:initialCropboxSize];
        completionHandler(croppedImage);
    }];
}

+ (UIImage *)croppedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform size:(CGSize)destSize{
    return [self croppedImageWithImage:image transform:transform size:destSize initialCropboxSize:CGSizeMake(0, 0)];
}

+ (UIImage *)croppedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform size:(CGSize)destSize initialCropboxSize:(CGSize)initialCropboxSize{
    CGSize sourceImageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    CGAffineTransform orientationTransform = CGAffineTransformIdentity;
    [self transform:&orientationTransform andSize:&sourceImageSize forOrientation:image.imageOrientation];
    
    // Create a graphics context the size of the bounding rectangle
    UIImage *cropboxGuideImage = [UIImage imageNamed:@"cropbox_guide"];
    if (initialCropboxSize.width != 0 && initialCropboxSize.height != 0){
        UIGraphicsBeginImageContext(initialCropboxSize);
        [cropboxGuideImage drawInRect:CGRectMake(0, 0, initialCropboxSize.width, initialCropboxSize.height)];
        cropboxGuideImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    UIGraphicsBeginImageContext(destSize);
    [cropboxGuideImage drawInRect:CGRectMake(-destSize.width / 2, -destSize.height / 2, destSize.width, destSize.height)];
    cropboxGuideImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    CGSize cropboxGuideSize = CGSizeMake(cropboxGuideImage.scale * (cropboxGuideImage.size.width), cropboxGuideImage.scale * (cropboxGuideImage.size.height));
    //    NSAssert(cropboxGuideSize.width == cropboxGuideSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
    //    NSAssert(destSize.width == destSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
    
    // do the transforms and draw the image
    UIGraphicsBeginImageContextWithOptions(destSize, /*opaque: */ YES, /*scale: */ 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform t = CGAffineTransformMakeScale(destSize.width / cropboxGuideSize.width, destSize.height / cropboxGuideSize.height);
    t = CGAffineTransformTranslate(t, cropboxGuideSize.width / 2, cropboxGuideSize.height / 2);
    CGContextConcatCTM(context, t);
    
    // The transform matrix applied to the image is in points and so we need to convert it to pixels. Multiply by the screen scale to do
    // this.
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGContextConcatCTM(context, CGAffineTransformMakeScale(screenScale, screenScale));
    CGContextConcatCTM(context, transform);
    CGContextConcatCTM(context, CGAffineTransformMakeScale(1 / screenScale, - 1 / screenScale));
    
    CGContextConcatCTM(context, orientationTransform);
    
    // scale image to aspect fill initial crop box
    CGFloat imgWidth = sourceImageSize.width;
    CGFloat imgHeight = sourceImageSize.height;
    CGFloat imageToCropboxScale = 1;
    CGFloat xScale = 1;
    CGFloat yScale = 1;
    
    xScale = cropboxGuideSize.width / imgWidth;
    yScale = cropboxGuideSize.height / imgHeight;
    imageToCropboxScale = fmax(xScale, yScale);
    
    imgWidth *= imageToCropboxScale;
    imgHeight *= imageToCropboxScale;
    CGContextDrawImage(context, CGRectMake(-imgWidth / 2, -imgHeight / 2, imgWidth, imgHeight), image.CGImage);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (void)setTransform:(CGAffineTransform)transform {
    self.affineTransform = transform;
}

- (CGAffineTransform)transform {
    return self.affineTransform;
}

- (void)getImageWithProgress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    if (self.image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(self.image);
        });
    } else {
        self.inProgressDownload = [[SDWebImageManager sharedManager] downloadWithURL:self.url
                                                                             options:0
                                                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
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
