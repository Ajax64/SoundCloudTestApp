//
//  SoundListViewController.h
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundListDataSource.h"

@interface SoundListViewController : UIViewController <UITableViewDelegate, DataSourceRequestDelegate>

@property (strong, nonatomic) IBOutlet SoundListDataSource *soundListDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *userInfoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudGlowImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

- (IBAction)touchLogoutButton:(id)sender;
- (IBAction)touchLoginButton:(id)sender;

@end
