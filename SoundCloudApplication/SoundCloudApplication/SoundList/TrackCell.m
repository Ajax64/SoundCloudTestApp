//
//  TrackCell.m
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "TrackCell.h"

@implementation TrackCell

@synthesize titleLable;
@synthesize artistImageView;
@synthesize durationLabel;
@synthesize creationDateLabel;
@synthesize waveformView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    self.waveformView.image = nil;
    self.artistImageView.image = nil;
}
@end
