//
//  BJImageCropper.m
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BJImageCropper.h"
#import "BarrettMacros.h"
#import <QuartzCore/QuartzCore.h>


@implementation BJImageCropper
@dynamic crop;
@dynamic image;
@synthesize imageView;

- (UIImage*)image {
    return imageView.image;
}

- (void)setImage:(UIImage *)image {
    imageView.image = image;
}

- (void)constrainCropToImage {
    CGRect frame = cropView.frame;
    
    if (CGOriginX(cropView.frame) < 0) {
        frame.origin.x = 0;
    }
    
    if (CGWidth(cropView.frame) > CGWidth(cropView.superview.frame)) {
        frame.size.width = CGWidth(cropView.superview.frame);
    }
    
    if (CGOriginX(cropView.frame) + CGWidth(cropView.frame) > CGWidth(cropView.superview.frame)) {
        frame.origin.x = CGWidth(cropView.superview.frame) - CGWidth(cropView.frame);
    }
    
    if (CGOriginY(cropView.frame) < 0) {
        frame.origin.y = 0;
    }
    
    if (CGHeight(cropView.frame) > CGHeight(cropView.superview.frame)) {
        frame.size.height = CGHeight(cropView.superview.frame);
    }
    
    if (CGOriginY(cropView.frame) + CGHeight(cropView.frame) > CGHeight(cropView.superview.frame)) {
        frame.origin.y = CGHeight(cropView.superview.frame) - CGHeight(cropView.frame);
    }
    
    cropView.frame = frame;
}

- (void)updateBounds {
    [self constrainCropToImage];
    
    CGRect frame = cropView.frame;
    CGFloat x = CGOriginX(frame);
    CGFloat y = CGOriginY(frame);
    CGFloat width = CGWidth(frame);
    CGFloat height = CGHeight(frame);
    
    CGFloat selfWidth = CGWidth(self.imageView.frame);
    CGFloat selfHeight = CGHeight(self.imageView.frame);
    
    topView.frame = CGRectMake(x, 0, width, y);
    bottomView.frame = CGRectMake(x, y + height, width, selfHeight - y - height);
    leftView.frame = CGRectMake(0, y, x, height);
    rightView.frame = CGRectMake(x + width, y, selfWidth - x - width, height);
    
    topLeftView.frame = CGRectMake(0, 0, x, y);
    topRightView.frame = CGRectMake(x + width, 0, selfWidth - x - width, y);
    bottomLeftView.frame = CGRectMake(0, y + height, x, selfHeight - y - height);
    bottomRightView.frame = CGRectMake(x + width, y + height, selfWidth - x - width, selfHeight - y - height);
    
    [self didChangeValueForKey:@"crop"];    
}

- (CGRect)crop {
    CGRect frame = cropView.frame;
    
    if (frame.origin.x <= 0)
        frame.origin.x = 0;

    if (frame.origin.y <= 0)
        frame.origin.y = 0;

    
    return frame;
}

- (void)setCrop:(CGRect)crop {
    cropView.frame = crop;
    [self updateBounds];
}

- (UIView*)makeEdgeView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    
    [self.imageView addSubview:view];
    
    return view;
}

- (UIView*)makeCornerView {
    UIView *view = [self makeEdgeView];
    view.alpha = 0.75;
    
    return view;
}

- (void)setup {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    cropView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, CGWidth(self.imageView.frame) - 200, CGHeight(self.imageView.frame) - 200)];
    cropView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cropView.layer.borderWidth = 2.0;
    cropView.backgroundColor = [UIColor clearColor];
    cropView.alpha = 0.4;
    
    [self.imageView addSubview:cropView];

    topView = [self makeEdgeView];
    bottomView = [self makeEdgeView];
    leftView = [self makeEdgeView];
    rightView = [self makeEdgeView];
    topLeftView = [self makeCornerView];
    topRightView = [self makeCornerView];
    bottomLeftView = [self makeCornerView];
    bottomRightView = [self makeCornerView];
   
    
    [self updateBounds];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithImage:(UIImage*)newImage {
    self = [super init];
    if (self) {
        imageView = [[UIImageView alloc] initWithImage:newImage];
        self.frame = CGRectInset(imageView.frame, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE);
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    switch ([allTouches count]) {
        case 1: {            
            isPanning = NO;
            CGFloat insetAmount = IMAGE_CROPPER_INSIDE_STILL_EDGE;
            
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];
            if (CGRectContainsPoint(CGRectInset(cropView.frame, insetAmount, insetAmount), touch)) {
                isPanning = YES;
                panTouch = touch;
                return;
            }
            
            CGRect frame = cropView.frame;
            CGFloat x = touch.x;
            CGFloat y = touch.y;
            
            currentDragView = nil;
            
            // We start dragging if we're within the rect + the inset amount
            // If we're definitively in the rect we actually start moving right to the point
         
            if (CGRectContainsPoint(CGRectInset(topLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topLeftView;
                
                if (CGRectContainsPoint(topLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topRightView;
                
                if (CGRectContainsPoint(topRightView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomLeftView;
                
                if (CGRectContainsPoint(bottomLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomRightView;
                
                if (CGRectContainsPoint(bottomRightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topView.frame, 0, -insetAmount), touch)) {
                currentDragView = topView;
                
                if (CGRectContainsPoint(topView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomView.frame, 0, -insetAmount), touch)) {
                currentDragView = bottomView;
                
                if (CGRectContainsPoint(bottomView.frame, touch)) {
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(leftView.frame, -insetAmount, 0), touch)) {
                currentDragView = leftView;
                
                if (CGRectContainsPoint(leftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(rightView.frame, -insetAmount, 0), touch)) {
                currentDragView = rightView;
                
                if (CGRectContainsPoint(rightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            
            cropView.frame = frame;
            
            [self updateBounds];
            
            break;
        }
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];

            if (isPanning) {
                CGPoint touchCurrent = [[allTouches anyObject] locationInView:self.imageView];
                CGFloat x = touchCurrent.x - panTouch.x;
                CGFloat y = touchCurrent.y - panTouch.y;
                
                cropView.center = CGPointMake(cropView.center.x + x, cropView.center.y + y);
                                
                panTouch = touchCurrent;
            }
            else if ((CGRectContainsPoint(self.imageView.bounds, touch))) {
                CGRect frame = cropView.frame;
                CGFloat x = touch.x;
                CGFloat y = touch.y;
                
                if (currentDragView == topView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
                else if (currentDragView == bottomView) {
                    currentDragView = bottomView;
                    frame.size.height = y - CGOriginY(frame);
                }
                else if (currentDragView == leftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
                else if (currentDragView == rightView) {
                    currentDragView = rightView;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == topLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
                else if (currentDragView == topRightView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == bottomLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
                else if ( currentDragView == bottomRightView) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
                
                cropView.frame = frame;                
            }
        } break;
        case 2: {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
            
            if (isPanning) {
                CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];
                
                if (scaleDistance != 0) {
                    CGFloat scale = 1.0f + ((distance-scaleDistance)/scaleDistance);
                    
                    CGPoint originalCenter = cropView.center;
                    CGSize originalSize = cropView.frame.size;
                    
                    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);

                    if (newSize.width >= 50 && newSize.height >= 50 && newSize.width <= CGWidth(cropView.superview.frame) && newSize.height <= CGHeight(cropView.superview.frame)) {
                        cropView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
                        cropView.center = originalCenter;
                    }
                }
                
                scaleDistance = distance;
            }
            else if (
                     currentDragView == topLeftView ||
                     currentDragView == topRightView ||
                     currentDragView == bottomLeftView ||
                     currentDragView == bottomRightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat y = MIN(touch1.y, touch2.y);
                
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                cropView.frame = CGRectMake(x, y, width, height);
            }
            else if (
                     currentDragView == topView ||
                     currentDragView == bottomView
                     ) {
                CGFloat y = MIN(touch1.y, touch2.y);
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                cropView.frame = CGRectMake(CGOriginX(cropView.frame), y, CGWidth(cropView.frame), height);
            
            }
            else if (
                     currentDragView == leftView ||
                     currentDragView == rightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                
                cropView.frame = CGRectMake(x, CGOriginY(cropView.frame), width, CGHeight(cropView.frame));
            }
        } break;
    }
    
    [self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    scaleDistance = 0;
}

@end