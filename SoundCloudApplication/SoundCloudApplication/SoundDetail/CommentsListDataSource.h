//
//  CommentsListDataSource.h
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSourceRequestDelegate.h"

@interface CommentsListDataSource : NSObject <UITableViewDataSource>
{
    NSUInteger  _requestRetries;
}
@property (nonatomic, readonly) NSArray* elements;
@property (nonatomic, readonly) BOOL isModified;
@property (nonatomic, weak) id<DataSourceRequestDelegate> delegate;

/*
 * will fire the request to get the comments of a track with a specific id
 * @parameter trackID - id of the track
 */
- (void) requestCommentsForTrackWithID:(NSString *) trackID;

@end
