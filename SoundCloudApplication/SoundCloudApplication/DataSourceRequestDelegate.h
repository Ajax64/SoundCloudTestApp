//
//  DataSourceRequestDelegate.h
//  SoundCloudapplication
//
//  Created by Alexander Ney on 02.09.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataSourceRequestDelegate <NSObject>
- (void) dataSource: (NSObject *) datasource requestFailedWithError:(NSError *) error;
@end
