//
//  CommentCell.h
//  SoundCloudapplication
//
//  Created by Alexander Ney on 26.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic) NSTimeInterval timestamp;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
