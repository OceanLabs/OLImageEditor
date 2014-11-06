//
//  OLImageEditorImage.h
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^OLImageEditorImageGetImageCompletionHandler)(UIImage *image);
typedef void (^OLImageEditorImageGetImageProgressHandler)(float progress);

@protocol OLImageEditorImage <NSObject>
@required
@property (nonatomic, assign) CGAffineTransform transform;
@property (assign, nonatomic) CGSize transformFactor;
- (void)getImageWithProgress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler;
@optional
- (void)unloadImage;
- (void)cancelAnyLoading;
@end

@interface OLImageEditorImage : NSObject <OLImageEditorImage>

+ (OLImageEditorImage *)imageWithImage:(UIImage *)image;
+ (OLImageEditorImage *)imageWithURL:(NSURL *)url;

+ (void)croppedImageWithEditorImage:(id<OLImageEditorImage>)image size:(CGSize)size progress:(OLImageEditorImageGetImageProgressHandler)progressHandler completion:(OLImageEditorImageGetImageCompletionHandler)completionHandler;
+ (UIImage *)croppedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform size:(CGSize)size;
+ (UIImage *)croppedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform size:(CGSize)destSize initialCropboxSize:(CGSize)initialCropboxSize;

@end
