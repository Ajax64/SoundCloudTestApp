//
//  SoundDetailViewController.m
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "SoundDetailViewController.h"
#import "CommentCell.h"

@interface SoundDetailViewController ()

@end

@implementation SoundDetailViewController
@synthesize connectionsView;
@synthesize commentsDataSource;
@synthesize waveformView;
@synthesize tableView;
@synthesize trackNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIView lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //setup connections view
    self.connectionsView.tableView = self.tableView;
    self.connectionsView.waveformView = self.waveformView;
    
    //set delegate for handling errors
    self.commentsDataSource.delegate = self;
    
    //observe collection from the datasource (will update if request was successfull)
    [self.commentsDataSource addObserver:self
                               forKeyPath:@"elements"
                                  options:NSKeyValueObservingOptionNew
                                  context:nil];
    
    
    //load waveform
    if (self.trackInfo[@"waveform_url"] != [NSNull null]) {
        NSURL *wafeformImageURL = [NSURL URLWithString:self.trackInfo[@"waveform_url"]];
        
        //set a valid duration to the waveform (api returns duration in ms so divide by 1000 to get seconds)
        NSTimeInterval duration =  [self.trackInfo[@"duration"] floatValue] / 1000;
        self.waveformView.duration = duration;
        
        //set display orientaion to righ (default is up)
        self.waveformView.orientation = UIImageOrientationRight;
        [self.waveformView setWaveformURL:wafeformImageURL];
    }
    
    self.trackNameLabel.text = self.trackInfo[@"title"];
    
    //if the track is commentable - fire the request to get all comments
    BOOL commentable = (BOOL)self.trackInfo[@"commentable"];
    if(commentable)
        [self fireRequest];

}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setWaveformView:nil];
    [self setCommentsDataSource:nil];
    [self setTableView:nil];
    [self setConnectionsView:nil];
    [self setTrackNameLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * observe "elements" from the datasource - if the request within the datasource is successfull
 * elements will be updated
 */
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.commentsDataSource &&
       [keyPath isEqualToString:@"elements"]) {
        [self.tableView reloadData];
        [self.connectionsView setNeedsDisplay];
    }
}

#pragma mark - Request

/*
 * fires the request of the datasource with the tracknumber which was provided by the peresenting
 * viewcontroller
 */
- (void) fireRequest
{
    NSString *trackID = self.trackInfo[@"id"];
    [self.commentsDataSource requestCommentsForTrackWithID:trackID];
}

#pragma mark - UIScrollViewDelegate

/*
 * if the comments table was scrolled the connectionsView has to be redrwan
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.connectionsView setNeedsDisplay];
}

#pragma  mark - play & dimiss

- (IBAction)touchDismissButton:(id)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

/*
 * will try to open the soundcloud application with the current track
 * or the safari browser if the app was not installed
 */
- (IBAction)touchPlayButton:(id)sender
{
    //create url with soundcloud schema
    UIApplication *currentApplication = [UIApplication sharedApplication];
    NSString *trackURLPath = [NSString stringWithFormat: @"soundcloud:track:%@" , self.trackInfo[@"id"]];
    NSURL *trackURL = [NSURL URLWithString:trackURLPath];
    
    if ([currentApplication canOpenURL:trackURL]) { //try to open soudncloud app
        [currentApplication openURL:trackURL];
    } else if (self.trackInfo[@"permalink_url"]) { //soundcloud app not installend - open url with the systembrowser
        [currentApplication openURL:[NSURL URLWithString:self.trackInfo[@"permalink_url"]]];
    }
}


#pragma mark - DataSourceRequestDelegate & Error Handling

- (void) dataSource: (NSObject *) datasource requestFailedWithError:(NSError *) error
{
    //request of the datasource failed - display the error
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kError", nil)
                               message:[error localizedDescription]
                              delegate:self
                     cancelButtonTitle:NSLocalizedString(@"kAbbort", nil)
                     otherButtonTitles:NSLocalizedString(@"kRepeat", nil), nil];
    [alertView show];
}


//from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if repeat button was touched - repeat the request of the datasource
    if(buttonIndex == 1)
        [self fireRequest];
}

@end
