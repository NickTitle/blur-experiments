//
//  BlurSwitchViewController.m
//  blur-test-1
//
//  Created by Nick Esposito on 3/7/13.
//  Copyright (c) 2013 SWELL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BlurSwitchViewController.h"

@interface BlurSwitchViewController ()

@end

@implementation BlurSwitchViewController

@synthesize blurView;

BOOL isBlurred;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    blurView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    [blurView setContentMode:UIViewContentModeScaleAspectFill];
    [blurView setImage:[UIImage imageNamed:@"test.jpg"]];
    [self.view addSubview:blurView];
    
    UIButton *blurButton1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [blurButton1 setFrame:CGRectMake(20, self.view.bounds.size.height-124, self.view.bounds.size.width-40, 44)];
    [blurButton1 addTarget:self action:@selector(changeBlur1) forControlEvents:UIControlEventTouchUpInside];
    [blurButton1 setTitle:@"Raster Blur" forState:UIControlStateNormal];
    [self.view addSubview:blurButton1];
    
    UIButton *blurButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [blurButton2 setFrame:CGRectMake(20, self.view.bounds.size.height-64, self.view.bounds.size.width-40, 44)];
    [blurButton2 addTarget:self action:@selector(changeBlur2) forControlEvents:UIControlEventTouchUpInside];
    [blurButton2 setTitle:@"CGImage Blur" forState:UIControlStateNormal];
    [self.view addSubview:blurButton2];
    
    
    
}

-(void)changeBlur1{
    CALayer *layer = [blurView layer];
    if (!isBlurred) {
        [layer setRasterizationScale:0.3];
        [layer setShouldRasterize:YES];
        isBlurred = 1;
    }
    else {
        [layer setShouldRasterize:NO];
        isBlurred = 0;
    }
}

-(void)changeBlur2{
    CGImageRef iRef = [blurView.image CGImage];
    if (!isBlurred) {
        [self blur:iRef radius:20];
        isBlurred = 1;
    }
    else {
        [self blur:iRef radius:1];
        isBlurred = 0;
    }
}


- (CGImageRef)blur:(CGImageRef)base radius:(int)radius {
    CGContextRef ctx;
    CGImageRef imageRef = base;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width *4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int red = 0;
    int green = 0;
    int blue = 0;
    for (int widthIndex = radius; widthIndex < width - radius; widthIndex++) {
        for (int heightIndex = radius; heightIndex < height - radius; heightIndex++) {
            red = 0;
            green = 0;
            blue = 0;
            for (int radiusY = -radius; radiusY <= radius; ++radiusY) {
                for (int radiusX = -radius; radiusX <= radius; ++radiusX) {
                    
                    int xIndex = widthIndex + radiusX;
                    int yIndex = heightIndex + radiusY;
                    
                    int index = ((yIndex * width) + xIndex) * 4;
                    red += rawData[index];
                    green += rawData[index + 1];
                    blue += rawData[index + 2];
                }
            }
            
            int currentIndex = ((heightIndex * width) + widthIndex) * 4;
            
            int divisor = (radius * 2) + 1;
            divisor *= divisor;
            
            int finalRed = red / divisor;
            int finalGreen = green / divisor;
            int finalBlue = blue / divisor;
            
            rawData[currentIndex] = (char)finalRed;
            rawData[currentIndex + 1] = (char)finalGreen;
            rawData[currentIndex + 2] = (char)finalBlue;
        }
    }
    
    
    ctx = CGBitmapContextCreate(rawData,
                                CGImageGetWidth( imageRef ),
                                CGImageGetHeight( imageRef ),
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast ); 
    
    imageRef = CGBitmapContextCreateImage (ctx);
    
    CGContextRelease(ctx);  
    
    free(rawData);
    return imageRef;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
