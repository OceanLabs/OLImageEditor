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

+ (void)getCoppedImageFromEditorImage:(id<OLImageEditorImage>)image size:(CGSize)size progress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    transform = CGAffineTransformTranslate(transform, boundingRect.size.width/2, boundingRect.size.height/2);
//    transform = CGAffineTransformRotate(transform, angle);
//    transform = CGAffineTransformScale(transform, 1.0, -1.0);
//    
//    CGContextConcatCTM(context, transform);
    
    [image getImageWithProgress:progressHandler completion:^(UIImage *image) {
        // Create a graphics context the size of the bounding rectangle
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Draw the image into the context
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        
        // Get an image from the context
        completionHandler([UIImage imageWithCGImage:CGBitmapContextCreateImage(context)]);
    }];
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
