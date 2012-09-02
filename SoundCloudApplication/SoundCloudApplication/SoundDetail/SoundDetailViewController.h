//
//  SoundDetailViewController.h
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundCloudWaveformView.h"
#import "CommentsListDataSource.h"
#import "ConnectionsView.h"

@interface SoundDetailViewController : UIViewController <UITableViewDelegate, DataSourceRequestDelegate, UIAlertViewDelegate>

//dictionary created from the jsonresponse - contains all information of a track
@property (nonatomic, strong) NSDictionary* trackInfo;

@property (weak, nonatomic) IBOutlet ConnectionsView *connectionsView;
@property (strong, nonatomic) IBOutlet CommentsListDataSource *commentsDataSource;
@property (weak, nonatomic) IBOutlet SoundCloudWaveformView *waveformView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;

- (IBAction)touchDismissButton:(id)sender;
- (IBAction)touchPlayButton:(id)sender;

@end
