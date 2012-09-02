//
//  SCLoginHelper.h
//  SoundCloudapplication
//
//  Created by Sony on 02.09.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCLoginHelper : NSObject

+ (void) executeIfSCAccoundIsValide: (void (^)(void)) block loginOnDemandUsingViewController:(UIViewController *) viewController;
@end
