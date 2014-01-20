//
//  CropViewController.h
//  OLImageEditor
//
//  Created by Deon Botha on 19/01/2014.
//  Copyright (c) 2014 Deon Botha. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OLImageEditorImage;

@interface OLCropViewController : UIViewController
@property (nonatomic, strong) id<OLImageEditorImage> image;
@end
