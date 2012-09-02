//
//  WaveformView.h
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//
// this class will handle the display of a soundwaveform

#import <UIKit/UIKit.h>


@interface SoundCloudWaveformView : UIView
{
    UIImageView     *_wafeFormOverlyView;
    UIImageView     *_imageView;
    NSURL           *_url;
}

// half = YES will draw just the upper half of the waveform
@property (nonatomic, getter = isHalf) BOOL half;

//standard UIImageOrientation to enable rotation of the waveform
@property (nonatomic) UIImageOrientation orientation;

//if the waveformURL is set - the loading of it will begin automatically
@property (nonatomic, copy) NSURL* waveformURL;

//will contain the final image of the waveform - for future purpose it can be overwritten by a custom image
@property (nonatomic, strong) UIImage* image;

//duration of the waveform in seconds
@property (nonatomic) NSTimeInterval duration;

//according to the orientation; will be true if the waveform is drawn horizontally
@property (nonatomic, readonly) BOOL isHorizontal;

//pixelposition despending on the orientation (x / y) for a timeinterval - duration has to be set
- (CGFloat)positionForTime:(NSTimeInterval) time;

@end
