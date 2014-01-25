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

+ (void)croppedImageWithEditorImage:(id<OLImageEditorImage>)editorImage size:(CGSize)destSize progress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    [editorImage getImageWithProgress:progressHandler completion:^(UIImage *image) {
        completionHandler([self croppedImageWithImage:image transform:editorImage.transform size:destSize]);
    }];
}

+ (UIImage *)croppedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform size:(CGSize)destSize {
    // Create a graphics context the size of the bounding rectangle
    UIImage *cropboxGuideImage = [UIImage imageNamed:@"cropbox_guide"];
    CGSize cropboxGuideSize = CGSizeMake(cropboxGuideImage.scale * (cropboxGuideImage.size.width - 10), cropboxGuideImage.scale * (cropboxGuideImage.size.height - 10));
    NSAssert(cropboxGuideSize.width == cropboxGuideSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
    NSAssert(destSize.width == destSize.height, @"oops only support 1:1 aspect ratio at the moment given we show be showing a square crop box");
    
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
    
    // scale image to aspect fill initial crop box
    CGFloat imgWidth = image.size.width * image.scale;
    CGFloat imgHeight = image.size.height * image.scale;
    CGFloat imageToCropboxScale = 1;
    if (imgWidth < imgHeight) {
        imageToCropboxScale = cropboxGuideSize.width / imgWidth;
    } else {
        imageToCropboxScale = cropboxGuideSize.height / imgHeight;
    }
    
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
