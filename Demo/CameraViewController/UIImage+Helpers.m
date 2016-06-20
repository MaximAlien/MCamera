//
//  UIImage+Helpers.m
//  Demo
//
//  Created by Maxim Makhun on 6/16/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

#import "UIImage+Helpers.h"

@implementation UIImage (Helpers)

+ (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)size {
    CGImageRef imageRef = image.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize srcSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
    CGFloat scaleRatio = size.width / srcSize.width;
    UIImageOrientation orientation = image.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            size = CGSizeMake(size.height, size.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imageRef);
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop
                               toRect:(CGRect)rect
                          orientation:(UIImageOrientation)orientation {
    CGAffineTransform rectTransform;
    
    switch (imageToCrop.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -imageToCrop.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -imageToCrop.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -imageToCrop.size.width, -imageToCrop.size.height);
            break;
        case UIImageOrientationLeftMirrored:
            rectTransform = CGAffineTransformTranslate(rectTransform, imageToCrop.size.width, 0);
            rectTransform = CGAffineTransformRotate(rectTransform, M_PI_2);
            break;
        case UIImageOrientationRightMirrored:
            rectTransform = CGAffineTransformTranslate(rectTransform, 0, imageToCrop.size.height);
            rectTransform = CGAffineTransformRotate(rectTransform, -M_PI_2);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    rectTransform = CGAffineTransformScale(rectTransform, imageToCrop.scale, imageToCrop.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:imageToCrop.scale orientation:orientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

+ (UIImage *)roundedRectImageFromImage:(UIImage *)image
                           withRadious:(CGFloat)radius {
    if (radius == 0.0f) {
        return image;
    }
    
    if (image != nil) {
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        CGRect rect = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        const CGFloat scale = window.screen.scale;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, radius, radius);
        
        CGFloat rectWidth = CGRectGetWidth(rect) / radius;
        CGFloat rectHeight = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, rectWidth, rectHeight / 2.0f);
        CGContextAddArcToPoint(context, rectWidth, rectHeight, rectWidth / 2.0f, rectHeight, radius);
        CGContextAddArcToPoint(context, 0.0f, rectHeight, 0.0f, rectHeight / 2.0f, radius);
        CGContextAddArcToPoint(context, 0.0f, 0.0f, rectWidth / 2.0f, 0.0f, radius);
        CGContextAddArcToPoint(context, rectWidth, 0.0f, rectWidth, rectHeight / 2.0f, radius);
        CGContextRestoreGState(context);
        CGContextClosePath(context);
        CGContextClip(context);
        
        [image drawInRect:CGRectMake(0.0f, 0.0f, imageWidth, imageHeight)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    return nil;
}

+ (UIImage *)applyBlurOnImage:(UIImage *)imageToBlur
                   withRadius:(NSInteger)blurRadius {
    GPUImageGaussianBlurFilter *blurFilter = [GPUImageGaussianBlurFilter new];
    blurFilter.blurRadiusInPixels = blurRadius;
    
    if (imageToBlur) {
        return [blurFilter imageByFilteringImage:imageToBlur];
    }
    
    return nil;
}

+ (UIImage *)addImageToImage:(UIImage *)img
                  withImage2:(UIImage *)img2
                     andRect:(CGRect)cropRect
                        size:(CGSize)size {
    if (img2) {
        UIGraphicsBeginImageContext(size);
        
        CGPoint pointImg1 = CGPointMake(0, 0);
        [img drawAtPoint:pointImg1];
        
        CGPoint pointImg2 = cropRect.origin;
        [img2 drawAtPoint:pointImg2];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return result;
    }
    
    return nil;
}

+ (UIImage *)scaleImage:(UIImage *)image
                 toSize:(CGSize)size {
    CGSize scaledSize = size;
    float scaleFactor = 1.0f;
    
    if (image.size.width > image.size.height) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = size.width;
        scaledSize.height = size.height / scaleFactor;
    } else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = size.height;
        scaledSize.width = size.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0f);
    CGRect scaledImageRect = CGRectMake(0.0f, 0.0f, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
