//
//  ConnectionsView.h
//  SoundCloudapplication
//
//  Created by Sony on 27.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//
// this class will handle the display of the connection arrows from a commentcell to a waveform view

#import <UIKit/UIKit.h>
#import "SoundCloudWaveformView.h"

@interface ConnectionsView : UIView

@property (nonatomic, weak) SoundCloudWaveformView *waveformView;
@property (nonatomic, weak) UITableView *tableView;

@end
