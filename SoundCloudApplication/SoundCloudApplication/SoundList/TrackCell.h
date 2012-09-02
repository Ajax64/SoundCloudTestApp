//
//  TrackCell.h
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundCloudWaveformView.h"

@interface TrackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet SoundCloudWaveformView *waveformView;

@end
