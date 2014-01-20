//
//  OLImageEditorImage.m
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLImageEditorImage.h"
#import <SDWebImageDownloader.h>

@interface OLImageEditorImage ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id<SDWebImageOperation> inProgressDownload;
@end

@implementation OLImageEditorImage

- (id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
    }
    
    return self;
}

+ (OLImageEditorImage *)imageWithImage:(UIImage *)image {
    return [[OLImageEditorImage alloc] initWithImage:image];
}

+ (OLImageEditorImage *)imageWithURL:(NSURL *)url {
    return [[OLImageEditorImage alloc] initWithURL:url];
}

- (void)getImageWithProgress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler {
    if (self.image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(self.image);
        });
    } else {
        self.inProgressDownload = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:self.url
                                                              options:0
                                                             progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                                 progressHandler(receivedSize / (float) expectedSize);
                                                             }
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                if (finished) {
                                                                    self.inProgressDownload = nil;
                                                                    self.image = image;
                                                                    completionHandler(image);
                                                                }
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
