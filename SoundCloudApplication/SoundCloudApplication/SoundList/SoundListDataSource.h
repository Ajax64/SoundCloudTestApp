//
//  SoundListDataSource.h
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSourceRequestDelegate.h"

@interface SoundListDataSource : NSObject <UITableViewDataSource>


@property (nonatomic, readonly) NSArray* elements;
@property (nonatomic, readonly) BOOL isModified;
@property (nonatomic, weak) id<DataSourceRequestDelegate> delegate;

- (void) refreshWithUserFavourites;

@end
