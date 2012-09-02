//
//  SoundListDataSource.m
//  SoundCloudapplication
//
//  Created by Sony on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "SoundListDataSource.h"
#import "SCUI.h"
#import "TrackCell.h"

@interface SoundListDataSource (private)
@end

@implementation SoundListDataSource

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
    // section 1 is just a empty header to avoid the hiding of cells if the userinfo will bes displayed above
    if(section == 0)
        return 1;
    else
        return [_elements count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"headCell"];
    } else {
        TrackCell *trackCell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"];
        trackCell.titleLable.text = _elements[indexPath.row][@"title"];
        
        NSURL* titleImageURL = nil;
        NSLog(@"%@", _elements[indexPath.row]);
        if (_elements[indexPath.row][@"artwork_url"] != [NSNull null]) {
            titleImageURL =  [NSURL URLWithString:_elements[indexPath.row][@"artwork_url"]];
        } else if (_elements[indexPath.row][@"user"][@"avatar_url"] != [NSNull null]) {
            titleImageURL =  [NSURL URLWithString:_elements[indexPath.row][@"user"][@"avatar_url"]];
        }
        if (titleImageURL) {
            [trackCell.artistImageView  setImageWithURL:titleImageURL placeholderImage:nil];
        }
        
        if (_elements[indexPath.row][@"waveform_url"] != [NSNull null]) {
            NSString *bigWafeformURLString = _elements[indexPath.row][@"waveform_url"];
            NSString *smallWaveformURLString = [bigWafeformURLString stringByReplacingOccurrencesOfString:@"_m.png" withString:@"_s.png"];
            
            NSURL *wafeformImageURL = [NSURL URLWithString:smallWaveformURLString];
            [trackCell.waveformView setWaveformURL:wafeformImageURL];
        }
        
        if (_elements[indexPath.row][@"duration"] != [NSNull null]) {
            NSTimeInterval durationInterval = [(NSString *)_elements[indexPath.row][@"duration"] floatValue] / 1000;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:durationInterval];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if(durationInterval < 60)
                [dateFormatter setDateFormat:@"ss"];
            else if(durationInterval > 60)
                [dateFormatter setDateFormat:@"mm:ss"];
            else if(durationInterval >= 60 * 60)
                [dateFormatter setDateFormat:@"HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            trackCell.durationLabel.text = [dateFormatter stringFromDate:date];
        }
        
        if (_elements[indexPath.row][@"created_at"] != [NSNull null]) {
            NSDateFormatter *dateInputFormatter = [[NSDateFormatter alloc] init];
            [dateInputFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
            NSDate *creationDate = [dateInputFormatter dateFromString: _elements[indexPath.row][@"created_at"]];
            
            NSDateFormatter *dateOutputFormatter = [[NSDateFormatter alloc] init];
            dateOutputFormatter.dateStyle = NSDateFormatterMediumStyle;
            dateOutputFormatter.timeStyle = NSDateFormatterNoStyle;
            trackCell.creationDateLabel.text = [dateOutputFormatter stringFromDate:creationDate];
            
        }
        
        cell = trackCell;
    }
    return cell;
}

#pragma mark - Requests

- (void) refreshWithUserFavourites
{
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = nil;
        
        if (data)
            jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                           options:0
                                                             error:&jsonError];
        
        if (!error && !jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            NSArray* tracks = (NSArray*)jsonResponse;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self willChangeValueForKey:@"elements"];
                _elements = tracks;
                [self didChangeValueForKey:@"elements"];
            });
        } else {
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
    NSString *resourceURL = @"https://api.soundcloud.com/me/favorites.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}




@end
