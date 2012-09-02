//
//  SCLoginHelper.m
//  SoundCloudapplication
//
//  Created by Alexander Ney on 02.09.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "SCLoginHelper.h"
#import "SCUI.h"

@implementation SCLoginHelper

+ (void) executeIfSCAccoundIsValide: (void (^)(void)) block loginOnDemandUsingViewController:(UIViewController *) viewController
{
 
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        
        SCLoginViewControllerComletionHandler handler = ^(NSError *error) {
            if (error) {
                UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kError", nil)
                                                                   message:[error localizedDescription]
                                                                  delegate:nil
                                                         cancelButtonTitle:NSLocalizedString(@"kAbbort", nil)
                                                         otherButtonTitles:nil];
                [alertView show];
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
                
            }
        };
        
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
            SCLoginViewController *loginViewController;
            
            loginViewController = [SCLoginViewController
                                   loginViewControllerWithPreparedURL:preparedURL
                                   completionHandler:handler];
            loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController presentModalViewController:loginViewController animated:YES];
            });
        }];
    } else {
        block();
    }
    
}
@end
