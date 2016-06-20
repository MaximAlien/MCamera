//
//  CameraViewController.m
//  Demo
//
//  Created by Maxim Makhun on 6/16/16.
//  Copyright © 2016 Maxim Makhun. All rights reserved.
//

@import AVFoundation;

#import <GPUImage.h>

#import "CameraViewController.h"
#import "CameraHoverView.h"
#import "CameraScrollView.m"
#import "UIImage+Helpers.h"

#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property(nonatomic, strong) AVCaptureDevice *captureDevice;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property(nonatomic, strong) UIImageView *capturedPhotoImageView;

@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) UIImage *croppedImage;

@property(nonatomic, strong) CameraScrollView *mainScrollView;
@property(nonatomic, strong) CameraHoverView *cameraHoverView;

@property(nonatomic, strong) UIButton *selectPhotoButton;
@property(nonatomic, strong) UIButton *dismissSelectedPhotoButton;
@property(nonatomic, strong) UIButton *cameraButton;
@property(nonatomic, strong) UIButton *switchFilterLeftButton;
@property(nonatomic, strong) UIButton *switchFilterRightButton;
@property(nonatomic, strong) UIButton *blurOutButton;

@property(nonatomic, strong) UIView *selectedImageView;

@property(nonatomic) NSUInteger currentFilter;

@property(nonatomic) BOOL isCapturingImage;

@end

@implementation CameraViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentFilter = 1;
    
    if ([self setupCaptureSession]) {
        [self setupCapturedPhotoImageView];
        [self setupCameraHoverView];
        [self setupCameraButton];
        [self setupFlashButton];
        [self setupFrontCameraButton];
        [self setupDismissButton];
        [self setupSelectPhotoButton];
        [self setupFilterSwitcherButtons];
        [self setupDismissSelectedPhotoButton];
        [self setupSelectFromPhotoLibraryButton];
        [self setupBlurOutButton];
        [self setupMainScrollView];
        [self setupSelectedImageView];
    } else {
        NSLog(@"Unable to setup valid capture session");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.captureSession stopRunning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Setting-up methods

- (void)setupSelectedImageView {
    self.selectedImageView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.selectedImageView setBackgroundColor:[UIColor blackColor]];
    [self.selectedImageView addSubview:self.mainScrollView];
}

- (void)setupMainScrollView {
    self.mainScrollView = [[CameraScrollView alloc] initWithFrame:self.view.frame];
    self.mainScrollView.alwaysBounceHorizontal = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.delegate = self;
    self.mainScrollView.minimumZoomScale = 1.0f;
    self.mainScrollView.maximumZoomScale = 4.0f;
    [self.mainScrollView addSubview:self.capturedPhotoImageView];
}

- (void)setupBlurOutButton {
    self.blurOutButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 87, 50)];
    [self.blurOutButton setImage:[UIImage imageNamed:@"blur_out_faces_icon"] forState:UIControlStateNormal];
    [self.blurOutButton setImage:[UIImage imageNamed:@"blur_out_faces_icon_selected"] forState:UIControlStateSelected];
    [self.blurOutButton addTarget:self action:@selector(blurOut:) forControlEvents:UIControlEventTouchUpInside];
    self.blurOutButton.hidden = YES;
    [self.view addSubview:self.blurOutButton];
}

- (void)setupSelectFromPhotoLibraryButton {
    UIButton *selectFromPhotoLibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 116, 50)];
    [selectFromPhotoLibraryButton setImage:[UIImage imageNamed:@"choose_from_photos_icon"] forState:UIControlStateNormal];
    [selectFromPhotoLibraryButton addTarget:self action:@selector(selectFromPhotoLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectFromPhotoLibraryButton];
}

- (void)setupDismissSelectedPhotoButton {
    self.dismissSelectedPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 80, 5, 75, 50)];
    [self.dismissSelectedPhotoButton setImage:[UIImage imageNamed:@"retake_photo_icon"] forState:UIControlStateNormal];
    [self.dismissSelectedPhotoButton addTarget:self action:@selector(dismissSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.dismissSelectedPhotoButton.hidden = YES;
    [self.view addSubview:self.dismissSelectedPhotoButton];
}

- (BOOL)setupCaptureSession {
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 0) {
        self.captureDevice = devices[0];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
        }
        
        self.captureStillImageOutput = [AVCaptureStillImageOutput new];
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.captureStillImageOutput setOutputSettings:settings];
        [self.captureSession addOutput:self.captureStillImageOutput];
        
        return YES;
    }
    
    return NO;
}

- (void)setupCapturedPhotoImageView {
    self.capturedPhotoImageView = [UIImageView new];
    self.capturedPhotoImageView.frame = self.view.frame;
    self.capturedPhotoImageView.backgroundColor = [UIColor clearColor];
    self.capturedPhotoImageView.userInteractionEnabled = YES;
    self.capturedPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.capturedPhotoImageView.clipsToBounds = YES;
}

- (void)setupCameraHoverView {
    self.cameraHoverView = [[CameraHoverView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.cameraHoverView.opaque = NO;
    self.cameraHoverView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.cameraHoverView];
}

- (void)setupCameraButton {
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2 - 40, CGRectGetHeight(self.view.bounds) - 80, 80, 80)];
    [self.cameraButton setImage:[UIImage imageNamed:@"take_photo_icon"] forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setTintColor:[UIColor blueColor]];
    [self.cameraButton.layer setCornerRadius:20.0];
    [self.view addSubview:self.cameraButton];
}

- (void)setupFlashButton {
    UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectMake(5, CGRectGetHeight(self.view.bounds) - 65, 94, 50)];
    [flashButton setImage:[UIImage imageNamed:@"automatic_flash_disabled"] forState:UIControlStateNormal];
    [flashButton setImage:[UIImage imageNamed:@"automatic_flash_enabled"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashButton];
}

- (void)setupFrontCameraButton {
    UIButton *frontCameraButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 80, CGRectGetHeight(self.view.bounds) - 65, 80, 50)];
    [frontCameraButton setImage:[UIImage imageNamed:@"back_camera_icon"] forState:UIControlStateNormal];
    [frontCameraButton addTarget:self action:@selector(showFrontCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:frontCameraButton];
}

- (void)setupDismissButton {
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 55, 5, 50, 50)];
    [dismissButton setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
}

- (void)setupSelectPhotoButton {
    self.selectPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2 - 40, CGRectGetHeight(self.view.bounds) - 80, 80, 80)];
    [self.selectPhotoButton setImage:[UIImage imageNamed:@"accept_photo_icon"] forState:UIControlStateNormal];
    [self.selectPhotoButton addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectPhotoButton setTintColor:[UIColor blueColor]];
    self.selectPhotoButton.layer.cornerRadius = 20.0f;
    self.selectPhotoButton.hidden = YES;
    [self.view addSubview:self.selectPhotoButton];
}

- (void)setupFilterSwitcherButtons {
    self.switchFilterLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height - 80, 70, 70)];
    [self.switchFilterLeftButton setImage:[UIImage imageNamed:@"leftarrow"] forState:UIControlStateNormal];
    [self.switchFilterLeftButton addTarget:self action:@selector(swipeLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchFilterLeftButton setTintColor:[UIColor blueColor]];
    self.switchFilterLeftButton.hidden = YES;
    [self.view addSubview:self.switchFilterLeftButton];
    
    self.switchFilterRightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, self.view.bounds.size.height - 80, 70, 70)];
    [self.switchFilterRightButton setImage:[UIImage imageNamed:@"rightarrow"] forState:UIControlStateNormal];
    [self.switchFilterRightButton addTarget:self action:@selector(swipeRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchFilterRightButton setTintColor:[UIColor blueColor]];
    self.switchFilterRightButton.hidden = YES;
    [self.view addSubview:self.switchFilterRightButton];
}

- (void)swipeRight:(UITapGestureRecognizer *)recognizer {
    if (self.currentFilter == 1) {
        self.currentFilter = 7;
    }
    
    if (self.currentFilter == 0) {
        self.currentFilter = 6;
    }
    
    if (self.currentFilter > 1) {
        self.currentFilter--;
        [self changeFilterByIndex:self.selectedImage];
    }
}

- (void)swipeLeft:(UITapGestureRecognizer *)recognizer {
    if (self.currentFilter == 6) {
        self.currentFilter = 0;
    }
    
    if (self.currentFilter <= 5) {
        self.currentFilter++;
        
        [self changeFilterByIndex:self.selectedImage];
        
        if (self.currentFilter == 6) {
            self.currentFilter = 0;
        }
    }
}

- (void)changeFilterByIndex:(UIImage *)image {
    GPUImageFilter *filter;
    
    if (self.currentFilter == 1) {
        filter = [GPUImageFilter new];
    } else if (self.currentFilter == 2) {
        filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"EarlyBird"];
    } else if (self.currentFilter == 3) {
        filter = [GPUImageGrayscaleFilter new];
    } else if (self.currentFilter == 4) {
        filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Nashville"];
    } else if (self.currentFilter == 5) {
        filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"Valencia"];
    } else if (self.currentFilter == 6) {
        filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"X-PRO II"];
    }
    
    self.capturedPhotoImageView.image = [filter imageByFilteringImage:image];
}

- (void)applyBlur:(NSSet *)touches {
    if (self.blurOutButton.selected) {
        UIImage *croppedImg = nil;
        
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.mainScrollView];
        
        double widthRatio = self.capturedPhotoImageView.image.size.width / self.capturedPhotoImageView.frame.size.width;
        double heightRatio = self.capturedPhotoImageView.image.size.height / self.capturedPhotoImageView.frame.size.height;
        
        currentPoint.x *= widthRatio;
        currentPoint.y *= heightRatio;
        
        double circleSizeW = 50 * widthRatio * self.mainScrollView.zoomScale;
        double circleSizeH = 50 * heightRatio * self.mainScrollView.zoomScale;
        
        currentPoint.x = (currentPoint.x - circleSizeW / 2 < 0) ? 0 : currentPoint.x - circleSizeW / 2;
        currentPoint.y = (currentPoint.y - circleSizeH / 2 < 0) ? 0 : currentPoint.y - circleSizeH / 2;
        
        CGRect cropRect = CGRectMake(currentPoint.x, currentPoint.y, circleSizeW, circleSizeW);
        
        croppedImg = [UIImage croppIngimageByImageName:self.capturedPhotoImageView.image toRect:cropRect orientation:self.capturedPhotoImageView.image.imageOrientation];
        croppedImg = [UIImage applyBlurOnImage:croppedImg withRadius:5];
        croppedImg = [UIImage roundedRectImageFromImage:croppedImg withRadious:5];
        
        UIImage *tempImg = [UIImage addImageToImage:self.capturedPhotoImageView.image withImage2:croppedImg andRect:cropRect size:self.capturedPhotoImageView.image.size];
        
        if (tempImg) {
            self.capturedPhotoImageView.image = tempImg;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self applyBlur:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self applyBlur:touches];
}

- (void)capturePhoto:(id)sender {
    self.capturedPhotoImageView.frame = self.view.frame;
    
    self.mainScrollView.frame = CGRectMake(1,
                                           SCREEN_HEIGHT - SCREEN_WIDTH - SCREEN_WIDTH / 2.5,
                                           SCREEN_WIDTH,
                                           SCREEN_WIDTH);
    
    self.isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in self.captureStillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
            
            if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
                UIImage *flippedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
                self.selectedImage = flippedImage;
            }
            else {
                self.selectedImage = capturedImage;
            }
            
            self.isCapturingImage = NO;
            
            self.switchFilterLeftButton.hidden = NO;
            self.switchFilterRightButton.hidden = NO;
            
            [self.view addSubview:self.selectedImageView];
            
            [self changeFilterByIndex:self.selectedImage];
            
            self.mainScrollView.contentSize = self.capturedPhotoImageView.bounds.size;
            
            [self.view bringSubviewToFront:self.cameraHoverView];
            [self.view bringSubviewToFront:self.selectPhotoButton];
            [self.view bringSubviewToFront:self.blurOutButton];
            [self.view bringSubviewToFront:self.dismissSelectedPhotoButton];
            [self.view bringSubviewToFront:self.switchFilterLeftButton];
            [self.view bringSubviewToFront:self.switchFilterRightButton];
            
            self.dismissSelectedPhotoButton.hidden = NO;
            self.selectPhotoButton.hidden = NO;
            self.blurOutButton.hidden = NO;
            
            self.cameraHoverView.userInteractionEnabled = NO;
            
            self.mainScrollView.showsHorizontalScrollIndicator = NO;
            self.mainScrollView.showsVerticalScrollIndicator = NO;
            
            [self.mainScrollView scrollRectToVisible:self.mainScrollView.frame animated:NO];
            
            self.capturedPhotoImageView.image = self.selectedImage;
            
            imageData = nil;
        }
    }];
}

- (void)switchFlash:(id)sender {
    if (self.captureDevice.isFlashAvailable) {
        if (self.captureDevice.flashActive) {
            if ([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
                [sender setTintColor:[UIColor grayColor]];
                [sender setSelected:NO];
            }
        } else {
            if ([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
                [sender setTintColor:[UIColor blueColor]];
                [sender setSelected:YES];
            }
        }
        
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)showFrontCamera:(id)sender {
    AVCaptureDevice *backCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    AVCaptureDevice *frontCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
    
    if (!self.isCapturingImage) {
        if (self.captureDevice == backCaptureDevice) {
            self.captureDevice = frontCaptureDevice;
        } else if (self.captureDevice == frontCaptureDevice) {
            self.captureDevice = backCaptureDevice;
        }
        
        [self switchCaptureDevice];
    }
}

- (void)switchCaptureDevice {
    [self.captureSession beginConfiguration];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    
    for (AVCaptureInput *oldInput in self.captureSession.inputs) {
        [self.captureSession removeInput:oldInput];
    }
    
    [self.captureSession addInput:newInput];
    [self.captureSession commitConfiguration];
}

- (void)blurOut:(id)sender {
    if (self.blurOutButton.selected) {
        self.blurOutButton.selected = NO;
        
        self.switchFilterLeftButton.hidden = NO;
        self.switchFilterRightButton.hidden = NO;
        
        self.mainScrollView.userInteractionEnabled = YES;
    } else {
        self.blurOutButton.selected = YES;
        
        self.switchFilterLeftButton.hidden = YES;
        self.switchFilterRightButton.hidden = YES;
        
        self.mainScrollView.userInteractionEnabled = NO;
    }
}

- (void)selectFromPhotoLibrary:(id)sender {
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)photoSelected:(id)sender {
    
}

- (void)dismissSelectedPhoto:(id)sender {
    [self.selectedImageView removeFromSuperview];
    
    self.dismissSelectedPhotoButton.hidden = YES;
    self.selectPhotoButton.hidden = YES;
    self.blurOutButton.hidden = YES;
    
    self.switchFilterLeftButton.hidden = YES;
    self.switchFilterRightButton.hidden = YES;
    
    self.blurOutButton.selected = NO;
    
    self.mainScrollView.userInteractionEnabled = YES;
    self.mainScrollView.zoomScale = 1.0f;
    
    [self.view insertSubview:self.cameraHoverView belowSubview:self.cameraButton];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.mainScrollView.frame = CGRectMake(1.0f,
                                           SCREEN_HEIGHT - SCREEN_WIDTH - SCREEN_WIDTH / 2.5f,
                                           SCREEN_WIDTH,
                                           SCREEN_WIDTH);
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGFloat coef1 = originalImage.size.width / self.mainScrollView.frame.size.width;
    CGFloat coef2 = originalImage.size.height / self.mainScrollView.frame.size.height;
    
    UIImage *resizedImage = [UIImage scaleImage:originalImage toSize:CGSizeMake(originalImage.size.width / coef1,
                                                                                originalImage.size.height / coef2)];
    self.selectedImage = resizedImage;
    
    self.capturedPhotoImageView.image = self.selectedImage;
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.switchFilterLeftButton.hidden = NO;
        self.switchFilterRightButton.hidden = NO;
        
        [self.view addSubview:self.selectedImageView];
        
        [self changeFilterByIndex:self.selectedImage];
        
        self.capturedPhotoImageView.frame = CGRectMake(0,
                                                       0,
                                                       SCREEN_WIDTH,
                                                       SCREEN_WIDTH);
        
        self.mainScrollView.contentSize = self.capturedPhotoImageView.frame.size;
        
        [self.view bringSubviewToFront:self.cameraHoverView];
        [self.view bringSubviewToFront:self.selectPhotoButton];
        [self.view bringSubviewToFront:self.dismissSelectedPhotoButton];
        [self.view bringSubviewToFront:self.blurOutButton];
        [self.view bringSubviewToFront:self.switchFilterLeftButton];
        [self.view bringSubviewToFront:self.switchFilterRightButton];
        
        self.selectPhotoButton.hidden = NO;
        self.blurOutButton.hidden = NO;
        
        self.cameraHoverView.userInteractionEnabled = NO;
        
        self.mainScrollView.showsHorizontalScrollIndicator = NO;
        self.mainScrollView.showsVerticalScrollIndicator = NO;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
