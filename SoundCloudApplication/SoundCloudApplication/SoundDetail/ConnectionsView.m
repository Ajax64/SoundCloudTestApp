//
//  ConnectionsView.m
//  SoundCloudapplication
//
//  Created by Alexander Ney on 27.08.12.
//  Copyright (c) 2012 Alexander Ney. All rights reserved.
//

#import "ConnectionsView.h"
#import "CommentCell.h"

#define GOLDEN_RATIO 0.681f

@implementation ConnectionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    
    if(self.tableView && self.waveformView) {
        //draw an arrow / connection for every visible cell
        NSArray* visibleCells = self.tableView.visibleCells;
        for (CommentCell *cell in visibleCells) {
            
            //translate the positions to the connectionsview
            CGRect cellPosition = [self.tableView convertRect:cell.frame toView:self];
            CGFloat trackPosition = [self.waveformView positionForTime:cell.timestamp];
            CGPoint pointInWaveformView = CGPointMake(self.waveformView.frame.size.width * GOLDEN_RATIO, trackPosition);
            CGPoint pointInSuperView = [self.waveformView convertPoint:pointInWaveformView toView:self];
            CGFloat padding = cell.frame.size.height * (GOLDEN_RATIO / 4);
            
            // calculate the alpha value - arrows will disappear / be more transparent as they move
            // more to the beginning / end of the tableview
            // arrows in the middle will have te same alpha vlaue as the containerview of the commentcell
            CGFloat alpha = 0.0f;
            CGFloat cellMiddleY = cellPosition.origin.y + cellPosition.size.height / 2;
            CGFloat tableMiddleY = self.tableView.frame.size.height / 2;
            
            if(cellMiddleY < tableMiddleY)
                alpha = (cellMiddleY / tableMiddleY);
            else
                alpha = 1.0f - ((cellMiddleY -tableMiddleY) / tableMiddleY);
            
            CGColorRef sourceColor = cell.containerView.backgroundColor.CGColor;
            const CGFloat* sourceColorComponents = CGColorGetComponents(sourceColor);
            alpha = MIN(alpha*(alpha/2) + alpha, CGColorGetAlpha(sourceColor));
            
            //draw the arrow (in fact a rectangle)
            //use the same color as the containerview in the commentcell
            CGContextMoveToPoint(context, pointInSuperView.x, pointInSuperView.y);
            CGContextAddLineToPoint(context, cellPosition.origin.x, cellPosition.origin.y + padding);
            CGContextAddLineToPoint(context, cellPosition.origin.x, cellPosition.origin.y + cell.frame.size.height - padding);
            CGContextAddLineToPoint(context, pointInSuperView.x, pointInSuperView.y);
            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:sourceColorComponents[0]
                                                                     green:sourceColorComponents[1]
                                                                      blue:sourceColorComponents[2]
                                                                     alpha:alpha] CGColor]);
            CGContextFillPath(context);
        
            //draw a line above the waveform view to indicate the comment position
            CGRect waveformRectInSuperview = [self.waveformView convertRect:self.waveformView.frame toView:self];
            CGContextSetStrokeColorWithColor(context,[[UIColor colorWithRed:sourceColorComponents[0]
                                                 green:sourceColorComponents[1]
                                                  blue:sourceColorComponents[2]
                                                 alpha:alpha * (GOLDEN_RATIO/2)] CGColor]);
            
            CGContextMoveToPoint(context, waveformRectInSuperview.origin.x, pointInSuperView.y);
            CGContextAddLineToPoint(context, waveformRectInSuperview.size.width, pointInSuperView.y);
            
            
            CGContextStrokePath(context);
        }
        
        

    }
}


@end
