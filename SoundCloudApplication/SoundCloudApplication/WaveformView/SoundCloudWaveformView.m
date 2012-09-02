//
//  WaveformView.m
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "SoundCloudWaveformView.h"
#import "NSString+SHA1.h"

//defines of the two colors of the waveform image
#define STARTCOLOR [UIColor colorWithRed:10.0f / 255.0f green:220.0f / 255.0f blue:80.0f / 255.0f alpha:1.0f]
#define ENDCOLOR [UIColor colorWithRed:0.0f green:87.0f / 255.0f blue:160.0f / 255.0f alpha:1.0f]

//a cahce for the images - will be valid for any object of that class
static NSCache *_imageCache;

@interface SoundCloudWaveformView (private)
- (void) loadWaveformURL:(NSURL *)waveformURL;
@end

@implementation SoundCloudWaveformView

+ (void) initialize
{
    //create the cache for the images
    _imageCache = [[NSCache alloc] init];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // defaults
        _orientation = UIImageOrientationUp;
        _half = NO;
        
        //ad an imageview for displaying the waveform
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_imageView];
    }
    return self;
}

- (void) setOrientation:(UIImageOrientation)orientation
{
    _orientation = orientation;
    [self setNeedsLayout];
}

- (void) setHalf:(BOOL)half
{
    _half = half;
    [self setNeedsLayout];
}

/*
 * will display the waveform with an animation
 * @parameter image of the waveform
 */
-(void) setImage:(UIImage *)image
{
    _imageView.image = image;
    _imageView.alpha = 0;
 
    if (self.isHorizontal) {
        _imageView.frame = CGRectMake(_imageView.frame.origin.x, self.frame.size.height, _imageView.frame.size.width, 0);
        
        [UIView animateWithDuration:1.0 animations:^{
            _imageView.alpha = 1.0f;
            _imageView.frame = CGRectMake(_imageView.frame.origin.x, 0, _imageView.frame.size.width, self.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:1.0f
                              delay:0.3f
                            options:0
                         animations: ^{
                             _imageView.alpha = 1.0f;
                         } completion:^(BOOL finished){
                             
                         }
         ];
    }
}

-(UIImage *) image
{
    return _imageView.image;
}

/*
 * will set the waveformURL and start the loading / processing of a waveform
 */
- (void) setWaveformURL:(NSURL *)waveformURL
{
    _url = waveformURL;
    [self performSelectorInBackground:@selector(loadWaveformURL:) withObject:waveformURL];
}

/*
 * loading process of the waveform to be called in the background
 */
- (void) loadWaveformURL:(NSURL *)waveformURL
{
    //create a unique key for the waveform image to cache
    NSString *imageName = [NSString stringWithFormat:@"%@%i",[[waveformURL absoluteString] sha1_digest],_half];
    
    UIImage *cachedImage = [_imageCache objectForKey:imageName];
    if(cachedImage) { //if image was chaced - set it
        [self performSelectorOnMainThread:@selector(setImage:) withObject:cachedImage waitUntilDone:YES];
        return;
    }
    //image was not cahced...
    
    //set acitivityindicator in the statusbar
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    //load original wavaform image from the url
    UIImage *sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: waveformURL]];
    
    //use core image to boost the exposure
    //to replace the orignal color which is "light grey" with white
    //so we can use the wavefrom as a imagemask
    CIImage *beginImage = [CIImage imageWithCGImage:[sourceImage CGImage]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO],
                             kCIContextUseSoftwareRenderer,
                             nil];
    CIContext *context = [CIContext contextWithOptions:options];
    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputEV", [NSNumber numberWithFloat:1.0], nil];
    CIImage *outputImage = [filter outputImage];
    
    
    CGImageRef cgWaveFormImageCorrected = [context createCGImage:outputImage fromRect:[outputImage extent]];

    //create mask image - crop to uper half if half == YES
    CGImageRef imageSourceMask = CGImageCreateWithImageInRect(cgWaveFormImageCorrected, CGRectMake(0, 0, CGImageGetWidth(cgWaveFormImageCorrected), CGImageGetHeight(cgWaveFormImageCorrected) / (_half?2.0f:1.0f) ));
    
    CGImageRelease(cgWaveFormImageCorrected);

    
    //create gradient image
    // Initialise
    UIGraphicsBeginImageContextWithOptions(sourceImage.size, YES, 1);
    
    //Gradient colors
    CGColorRef startColor = [STARTCOLOR CGColor];
    CGColorRef endColor = [ENDCOLOR CGColor];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0, 1.0};
    NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointMake(0, 0), CGPointMake(CGImageGetWidth(imageSourceMask), 0), 0 );
    
    UIImage *imageGradient = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    
        
    //create mask and mak the sourceimage
    CGImageRef sourceGradientImage = [imageGradient CGImage];
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(imageSourceMask),
                                        CGImageGetHeight(imageSourceMask),
                                        CGImageGetBitsPerComponent(imageSourceMask),
                                        CGImageGetBitsPerPixel(imageSourceMask),
                                        CGImageGetBytesPerRow(imageSourceMask),
                                        CGImageGetDataProvider(imageSourceMask), NULL, false);
    
    
    CGImageRef maskedImageRef = CGImageCreateWithMask(sourceGradientImage, mask);
    
    //create uiimage from the masked image with the proper orientation
    UIImage *image = [[UIImage alloc] initWithCGImage:maskedImageRef scale:(CGFloat)1.0 orientation:self.orientation];
    
    CGImageRelease(imageSourceMask);
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    app.networkActivityIndicatorVisible = NO;
    
    //cache the image
    [_imageCache setObject:image forKey:imageName];
    
    //_url != waveformURL if during the loading/processing of the image another image was set loading!
    // in this case prevent updating the waveformimage
    if(_url == waveformURL)
        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
}

- (BOOL) isHorizontal
{
   return _orientation == UIImageOrientationUp || _orientation ==  UIImageOrientationUpMirrored || _orientation == UIImageOrientationDown || _orientation == UIImageOrientationDownMirrored;
}

- (CGFloat)positionForTime:(NSTimeInterval) time
{
    //check the bounds
    if(time == 0 || _duration == 0)
        return 0;
    else if (time > _duration)
        return _duration;
    
    CGFloat positionFactor = time / _duration;
    
    //returns the pixelposition depending on the image orientation
    if(self.isHorizontal)
        return self.frame.size.width * positionFactor;
    else
        return self.frame.size.height * positionFactor;
}


@end
