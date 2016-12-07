//
//  GFShapeView.m
//  GFCodeScan
//
//  Created by 高飞 on 16/12/6.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "GFShapeView.h"
//画出四方形
@interface GFShapeView () {
    CAShapeLayer *_outline;
}

@end
@implementation GFShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _outline = [CAShapeLayer new];
        _outline.strokeColor = [[[UIColor blueColor] colorWithAlphaComponent:0.8] CGColor];
        _outline.lineWidth = 2.0;
        _outline.fillColor = [[UIColor clearColor] CGColor];
        [self.layer addSublayer:_outline];
    }
    return self;
}

- (void)setCorners:(NSArray *)corners
{
    if(corners != _corners) {
        _corners = corners;
        _outline.path = [[self createPathFromPoints:corners] CGPath];
    }
}

- (UIBezierPath *)createPathFromPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath new];
    // Start at the first corner
    [path moveToPoint:[[points firstObject] CGPointValue]];
    
    // Now draw lines around the corners
    for (NSUInteger i = 1; i < [points count]; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }
    
    // And join it back to the first corner
    [path addLineToPoint:[[points firstObject] CGPointValue]];
    
    return path;
}

@end
