//
//  NTFilterViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFilterViewController.h"
#import "NTMath.h"

static const CGFloat min = 150;
static const CGFloat max = 300;
static const CGFloat leeway = 100;

@interface NTFilterViewController ()
{
    CGFloat _min;
    CGFloat _max;
    CGFloat _mid;
}
@property (nonatomic) NSMutableArray *filters;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NTSchoolFilter *filter;
@property (weak, nonatomic) IBOutlet UIButton *gradeHighButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeElementaryButton;
@property (weak, nonatomic) IBOutlet UIButton *typePrivateButton;
@property (weak, nonatomic) IBOutlet UIButton *typePublicButton;
@end

@implementation NTFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _min = -self.view.frame.size.height + min;
    _max = -self.view.frame.size.height + max;
    _mid = (_min + _max) / 2;
    
    _filters = [NSMutableArray array];
    _filter = [NTSchoolFilter new];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // cancel any animation movement and continue position from last stop frame.
    if( [self.view.layer animationForKey:@"position"] ) {
        CGPoint animatePosition = [self.view.layer.presentationLayer position];
        [self.view.layer removeAnimationForKey:@"position"]; // remove anim
        [self.view.layer setPosition:animatePosition];
    }
    
    // get touch location
    CGPoint location = [touches.anyObject locationInView:self.view.superview];
    self.lastPoint = location;
    
    NSLog(@"begin: %@", NSStringFromCGPoint(location));
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // get touch location
    CGPoint location = [touches.anyObject locationInView:self.view.superview];
    
    NSLog(@"begin: %@", NSStringFromCGPoint(location));
    
    // restrict view controller movement
    CGFloat y = location.y - self.lastPoint.y;
    CGRect frame = CGRectMove(self.view.frame, CGPointMake(0, y));
    if( frame.origin.y > _max + leeway) {
        frame.origin.y = _max + leeway;
    }
    self.view.frame = frame;
    
    
    self.lastPoint = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [touches.anyObject locationInView:self.view.superview];
    
    // bound frame
    CGRect frame = self.view.frame;
    if ( frame.origin.y < _mid ) {
        frame.origin.y = _min;
    } else {
        frame.origin.y = _max;
    }
    
    // retrieve position
    CGPoint position;
    position.x =  frame.origin.x + frame.size.width/2;
    position.y =  frame.origin.y + frame.size.height/2;
    
    // animate position
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setToValue:[NSValue valueWithCGPoint:position]];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDuration:.3f];
    [self.view.layer addAnimation:animation forKey:@"position"];
    
    
    NSLog(@"begin: %@", NSStringFromCGPoint(location));
}

- (void)refreshFilter
{
    NTSchoolType type;
    NTSchoolGrade grade = NTSchoolGradeAll;
    
    if (self.typePrivateButton.selected) type = NTSchoolTypePrivate;
    else if (self.typePublicButton.selected) type = NTSchoolTypePublic;
    else type = NTSchoolTypeAll;
    
    if (self.gradeElementaryButton.selected) grade = grade | NTSchoolGradeElementary;
    if (self.gradeMiddleButton.selected) grade = grade | NTSchoolGradeMiddle;
    if (self.gradeHighButton.selected) grade = grade | NTSchoolGradeHigh;
    
    [self.filter setType:type];
    [self.filter setGrade:grade];
}


#pragma mark - Action

- (IBAction)selectButton:(UIButton *)button
{
    [button setSelected:!button.selected];
    
    if(button.selected) {
        if(button == self.typePrivateButton)
            [self.typePublicButton setSelected:NO];
        else
            [self.typePrivateButton setSelected:NO];
    }
    
    [self refreshFilter];
    
    [self.delegate filterViewControllerDidChangePredicate:self.filter];
}



@end
