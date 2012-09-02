//
//  SoundListViewController.m
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "SoundListViewController.h"
#import "SoundDetailViewController.h"
#import "SCUI.h"
#import "SCLoginHelper.h"

@interface SoundListViewController (private)
- (void) updateWithUserInformation:(NSDictionary *) userInfo;
- (void) requestUserInformation;
@end

@implementation SoundListViewController
@synthesize soundListDataSource;
@synthesize tableView;
@synthesize userImageView;
@synthesize userNameLabel;
@synthesize userLocationLabel;
@synthesize userInfoContainerView;
@synthesize cloudImageView;
@synthesize cloudGlowImageView;
@synthesize loginButton;
@synthesize logoutButton;


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
    [self.loginButton setTitle:NSLocalizedString(@"kLogin", nil) forState:UIControlStateNormal];
    [self.logoutButton setTitle:NSLocalizedString(@"kLogout", nil) forState:UIControlStateNormal];
    
    self.soundListDataSource.delegate = self;
    
    //hide the table and userinformation
    self.userInfoContainerView.alpha = 0.0;
    self.tableView.alpha = 0.0f;
    
    //initital loading animation
    self.cloudGlowImageView.alpha = 0.0f;

    //pulsating cloud animation - seen during the loading process
    [UIView animateWithDuration:1.2
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseOut
                     animations:^{
                         self.cloudGlowImageView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    //add observer for the elements of the datasource - elements will be updated if the request of the datasoruce was successfull
	[self.soundListDataSource addObserver:self
                                        forKeyPath:@"elements"
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];
    
    //fire requests
    SCAccount *account = [SCSoundCloud account];
    if(!account) {
        self.loginButton.hidden = NO;
    }
    [SCLoginHelper executeIfSCAccoundIsValide:^{
        self.loginButton.hidden = YES;
        [self.soundListDataSource refreshWithUserFavourites];
        [self requestUserInformation];
    } loginOnDemandUsingViewController:self];
    
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setSoundListDataSource:nil];
    [self setTableView:nil];
    [self setUserImageView:nil];
    [self setUserNameLabel:nil];
    [self setUserLocationLabel:nil];
    [self setUserInfoContainerView:nil];
    [self setCloudImageView:nil];
    [self setCloudGlowImageView:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - request and ui update

/*
 * will start the request for the user information
 */
- (void) requestUserInformation
{
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = nil;
        
        if (data)
            jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                           options:0
                                                             error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
            NSDictionary* userInfo = (NSDictionary*)jsonResponse;
            
            [self performSelectorOnMainThread:@selector(updateWithUserInformation:)
                                   withObject:userInfo
                                waitUntilDone:NO];
        } else {
            //on error repeat the user information request
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestUserInformation];
            });
        }
    };
    
    SCAccount *account = [SCSoundCloud account];
    NSString *resourceURL = @"https://api.soundcloud.com/me.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}

/*
 * updates the ui with the user information
 */
- (void) updateWithUserInformation:(NSDictionary *) userInfo
{
    if(userInfo[@"avatar_url"] != [NSNull null] ) {
        NSURL *avatarImageURL = [NSURL URLWithString:userInfo[@"avatar_url"]];
        [self.userImageView setImageWithURL:avatarImageURL placeholderImage:nil];
    }
    
    if(userInfo[@"full_name"] != [NSNull null] )
        self.userNameLabel.text = userInfo[@"full_name"];
    
    if(userInfo[@"city"] != [NSNull null] ) {
        self.userLocationLabel.text = userInfo[@"city"];
    }
    
    self.userInfoContainerView.frame = CGRectMake(self.userInfoContainerView.frame.origin.x, -self.userInfoContainerView.frame.size.height, self.userInfoContainerView.frame.size.width, self.userInfoContainerView.frame.size.height);
    self.userInfoContainerView.alpha = 0.0f;
    [UIView animateWithDuration:0.6f animations:^{
        self.userInfoContainerView.alpha = 1.0f;
        self.userInfoContainerView.frame = CGRectMake(self.userInfoContainerView.frame.origin.x, 0, self.userInfoContainerView.frame.size.width, self.userInfoContainerView.frame.size.height);
    }];
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.soundListDataSource &&
       [keyPath isEqualToString:@"elements"]) {
        [UIView animateWithDuration:1.8f
                              delay:0.6f
                            options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.cloudGlowImageView.alpha = 0.0f;
                             self.cloudImageView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             [self.tableView reloadData];
                             [UIView animateWithDuration:0.6 animations:^{
                                 self.tableView.alpha = 1.0f;
                             }];
                         }];
        
    }
}

#pragma mark - Segue

/*
 * will be called if a tableviewcell was selected (wirded in the storyboard)
 * initializes the detailviewcontroller with the track information
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SoundDetailViewController class]]) {
        SoundDetailViewController *detailViewController = (SoundDetailViewController *) segue.destinationViewController;
        NSDictionary *trackInfo = self.soundListDataSource.elements[self.tableView.indexPathForSelectedRow.row];
        detailViewController.trackInfo = trackInfo;
        
    }
}


#pragma mark - DataSourceRequestDelegate & Error Handling

/*
 * will be called if the request of the datasource failed
 */
- (void) dataSource: (NSObject *) datasource requestFailedWithError:(NSError *) error
{
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kError", nil)
                                                       message:[error localizedDescription]
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"kAbbort", nil)
                                             otherButtonTitles: NSLocalizedString(@"kRepeat", nil), nil];
    [alertView show];
}


//from UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //repeat button
    if(buttonIndex == 1)
        [self.soundListDataSource refreshWithUserFavourites];
}


- (IBAction)touchLogoutButton:(id)sender
{
    //hide userinfo and table
    self.userInfoContainerView.alpha = 0.0;
    self.tableView.alpha = 0.0f;
    self.loginButton.hidden = NO;
    //logout
    [SCSoundCloud removeAccess];
    //login with new authentification
    [self touchLoginButton:nil];
}

- (IBAction)touchLoginButton:(id)sender
{
    //fire requests and display athetification if needed
    [SCLoginHelper executeIfSCAccoundIsValide:^{
        self.loginButton.hidden = YES;
        [self.soundListDataSource refreshWithUserFavourites];
        [self requestUserInformation];
    } loginOnDemandUsingViewController:self];
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
