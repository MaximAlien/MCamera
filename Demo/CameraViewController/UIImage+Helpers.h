//
//  UIImage+Helpers.h
//  Demo
//
//  Created by Maxim Makhun on 6/16/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import UIKit;
#import <GPUImage.h>

@interface UIImage (Helpers)

+ (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)dstSize;

+ (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop
                               toRect:(CGRect)rect
                          orientation:(UIImageOrientation)orientation;

+ (UIImage *)roundedRectImageFromImage:(UIImage *)image
                           withRadious:(CGFloat)radius;

+ (UIImage *)applyBlurOnImage:(UIImage *)imageToBlur
                   withRadius:(NSInteger)blurRadius;

+ (UIImage *)addImageToImage:(UIImage *)img
                  withImage2:(UIImage *)img2
                     andRect:(CGRect)cropRect
                        size:(CGSize)size;
@end
