//
//  CommentsListDataSource.m
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "CommentsListDataSource.h"
#import "CommentCell.h"
#import "SCUI.h"


@interface CommentsListDataSource (private)

@end

@implementation CommentsListDataSource 

- (id)init
{
    self = [super init];
    if (self) {
        _elements = [NSArray array];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_elements count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    commentCell.commentLabel.text = _elements[indexPath.row][@"body"];
    
    NSURL* userImageURL = nil;
    if (_elements[indexPath.row][@"user"][@"avatar_url"] != [NSNull null]) {
        userImageURL =  [NSURL URLWithString:_elements[indexPath.row][@"user"][@"avatar_url"]];
    } 
    if (userImageURL) {
        [commentCell.userImageView  setImageWithURL:userImageURL placeholderImage:nil];
    }
    
    if (_elements[indexPath.row][@"timestamp"] != [NSNull null]) {
        commentCell.timestamp = [_elements[indexPath.row][@"timestamp"] floatValue]  / 1000;
    } else {
        commentCell.timestamp = 0;
    }
   
    return commentCell;
}


#pragma mark - Request

- (void) requestCommentsForTrackWithID:(NSString *) trackID
{
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = nil;
        
        if (data)
            jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                           options:0
                                                             error:&jsonError];
        // request finished with no error and returned a json array
        if (!error && !jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            NSArray* comments = (NSArray*)jsonResponse;
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                          ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            //update the elements array and fire the corresponding kvo messages - on the main trhead!
            // otherwhise kvo won't work
            dispatch_async(dispatch_get_main_queue(), ^{
                [self willChangeValueForKey:@"elements"];
                _elements = [comments sortedArrayUsingDescriptors:sortDescriptors];;
                [self didChangeValueForKey:@"elements"];
            });
        } else { //request finished with an error - call the delegate method
            if( [self.delegate respondsToSelector:@selector(dataSource:requestFailedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!jsonError)
                        [self.delegate dataSource:self requestFailedWithError:error];
                    else
                        [self.delegate dataSource:self requestFailedWithError:jsonError];
                });
            }
        }
    };
    
    
    SCAccount *account = [SCSoundCloud account];
    NSString *resourceURL = [NSString stringWithFormat: @"https://api.soundcloud.com/tracks/%@/comments.json", trackID];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}


@end
