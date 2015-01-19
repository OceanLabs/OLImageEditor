//
//  OLImageCropView.m
//  OLImageEditor
//
//  Created by Deon Botha on 21/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import "OLImageCropView.h"

static const CGFloat kCropboxGuideBorder = 5;

@interface DarkOverlayView : UIView
- (id)initWithCropboxGuideImageView:(UIImageView *)cropboxGuideImageView;
@property (nonatomic, strong) UIImageView *cropboxGuideImageView;
@end

@interface OLImageCropView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat lastRotation, lastScale;

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIImageView *cropboxGuideImageView;
@property (nonatomic, strong) DarkOverlayView *overlayView;
@end

@implementation OLImageCropView

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame cropBoxSize:CGSizeMake(0, 0)];
}

- (id)initWithFrame:(CGRect)frame cropBoxSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:16 / 255.0 green:16 / 255.0 blue:16 / 255.0 alpha:1];
        UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        UIRotationGestureRecognizer *rotateGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        
        pinchGR.delegate = self;
        panGR.delegate = self;
        rotateGR.delegate = self;
        
        [self addGestureRecognizer:pinchGR];
        [self addGestureRecognizer:panGR];
        [self addGestureRecognizer:rotateGR];
        
        self.cropTransform = CGAffineTransformIdentity;
        self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        //self.userImageView.clipsToBounds = YES;
        
        UIImage *cropboxImage = [UIImage imageNamed:@"cropbox_guide"];
        if (size.width != 0 && size.height != 0){
            UIGraphicsBeginImageContext(size);
            [cropboxImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
            cropboxImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        self.cropboxGuideImageView = [[UIImageView alloc] initWithImage:cropboxImage];
        
        
        self.cropboxGuideImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.overlayView = [[DarkOverlayView alloc] initWithCropboxGuideImageView:self.cropboxGuideImageView];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.userImageView];
        [self addSubview:self.overlayView];
        [self addSubview:self.cropboxGuideImageView];
        
        CGFloat scale = 0.8 * ([UIScreen mainScreen].bounds.size.width / cropboxImage.size.width);
        self.transform = CGAffineTransformMakeScale(scale, scale);
        
        self.cropboxGuideImageView.hidden = YES;
    }
    return self;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self.overlayView setNeedsDisplay];
//}

- (void)notifyOfCropStartingIfNecessary {
    if (!self.userCroppedImage) {
        [self.delegate imageCropViewUserStartedCroppingImage:self];
        self.userCroppedImage = YES;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.userImageView.image = image;
    [self aspectFillCropboxGuideWithImage];
}

- (void)setCropTransform:(CGAffineTransform)cropTransform {
    _cropTransform = cropTransform;
    self.userImageView.transform = cropTransform;
}

- (void)aspectFillCropboxGuideWithImage {
    if (self.image == nil) {
        return;
    }
    
    // aspect fill image within cropbox frame
    CGFloat cbwidth= self.cropboxGuideImageView.frame.size.width - 2 * kCropboxGuideBorder;
    CGFloat cbheight= self.cropboxGuideImageView.frame.size.height - 2 * kCropboxGuideBorder;
    CGFloat xoff = kCropboxGuideBorder + self.cropboxGuideImageView.frame.origin.x;
    CGFloat yoff = kCropboxGuideBorder + self.cropboxGuideImageView.frame.origin.y;
    self.userImageView.frame = CGRectMake(xoff, yoff, cbwidth, cbheight);
    NSLog(@"ImageViewSize: %fx%f", self.userImageView.frame.size.width, self.userImageView.frame.size.height);
    self.userImageView.transform = self.cropTransform;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    CGFloat scale = recognizer.scale;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = scale;
    }
    
    CGFloat deltaScale = 1 + (scale - self.lastScale);
    self.lastScale = scale;
    
    self.cropTransform = CGAffineTransformConcat(self.cropTransform, CGAffineTransformMakeScale(deltaScale, deltaScale));
    [self notifyOfCropStartingIfNecessary];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint p = [recognizer translationInView:recognizer.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = p;
    }
    
    CGFloat tx = p.x - self.lastPoint.x;
    CGFloat ty = p.y - self.lastPoint.y;
    self.cropTransform = CGAffineTransformConcat(self.cropTransform, CGAffineTransformMakeTranslation(tx, ty));
    self.lastPoint = p;
    [self notifyOfCropStartingIfNecessary];
}

- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastRotation = recognizer.rotation;
    }
    
    CGFloat deltaRotation = recognizer.rotation - self.lastRotation;
    self.lastRotation = recognizer.rotation;
    self.cropTransform = CGAffineTransformConcat(CGAffineTransformMakeRotation(deltaRotation), self.cropTransform);
    [self notifyOfCropStartingIfNecessary];
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

@implementation DarkOverlayView
- (id)initWithCropboxGuideImageView:(UIImageView *)cropboxGuideImageView {
    if (self = [super init]) {
        self.cropboxGuideImageView = cropboxGuideImageView;
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect f = self.cropboxGuideImageView.frame;
    CGRect left = CGRectMake(0, 0, f.origin.x + kCropboxGuideBorder, rect.size.height);
    CGRect right = CGRectMake(CGRectGetMaxX(f) - kCropboxGuideBorder, 0, rect.size.width - (CGRectGetMaxX(f) - kCropboxGuideBorder), rect.size.height);
    CGRect top = CGRectMake(f.origin.x + kCropboxGuideBorder, 0, f.size.width - 2 * kCropboxGuideBorder, f.origin.y + kCropboxGuideBorder);
    CGRect bottom = CGRectMake(f.origin.x + kCropboxGuideBorder, CGRectGetMaxY(f) - kCropboxGuideBorder, f.size.width - 2 * kCropboxGuideBorder, rect.size.height - (CGRectGetMaxY(f) - kCropboxGuideBorder));
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f].CGColor);
    CGContextFillRect(context, left);
    CGContextFillRect(context, right);
    CGContextFillRect(context, top);
    CGContextFillRect(context, bottom);
}

@end
