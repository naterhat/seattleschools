//
//  NTFilterViewController.m
//  seattle_schools
//
//  Created by Nate on 12/14/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTFilterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NTMath.h"
#import "NTTheme.h"
#import "NTFilterTransformView.h"
#import "seattle_schools-Swift.h"

static const CGFloat min = 100;
static const CGFloat max = 200;

@interface NTFilterViewController ()
{
    CGFloat _min;
    CGFloat _max;
    CGFloat _mid;
}
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NTSchoolFilter *filter;
@property (weak, nonatomic) IBOutlet UIButton *gradeHighButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeElementaryButton;
@property (weak, nonatomic) IBOutlet UIButton *typePrivateButton;
@property (weak, nonatomic) IBOutlet UIButton *typePublicButton;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIDynamicBehavior *snapBehavior;
@property (nonatomic) UIDynamicBehavior *dynamicBehavior;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint restPoint;
@property (nonatomic) FilterView *filterView;
@end

@implementation NTFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FilterView *view = [[[NSBundle mainBundle] loadNibNamed:@"FilterView" owner:self options:nil] lastObject];
    [view setFrame:self.view.bounds];
    [[((NTFilterTransformView *)self.view) contentView] addSubview:view];
    _filterView = view;
    for (UIView *view in  @[self.gradeHighButton, self.gradeMiddleButton, self.gradeElementaryButton, self.typePrivateButton, self.typePublicButton]) {
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapButton:)]];
    }

    // resize view
    CGFloat flagWidth = self.view.frame.size.width * [[NTTheme instance] flagWidthScale];
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height * 2;
    frame.origin.y = -frame.size.height + 200;
    frame.origin.x = (frame.size.width - flagWidth) * .5;
    frame.size.width = flagWidth;
    [self.view setFrame:frame];
    
    // Used for panning the view and stopping at a certain point.
    _min = -self.view.frame.size.height * .5 + min;
    _max = -self.view.frame.size.height * .5 + max;
    _mid = (_min + _max) * .5;
    _restPoint = CGPointMake(self.view.center.x, _min);
    
    _filter = [NTSchoolFilter new];
    
    // create snap behavior
    [self createSnap];
    
    // create dynamic behavior
    UIDynamicItemBehavior *dBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.view]];
    [dBehavior setAngularResistance:3.0f];
    _dynamicBehavior = dBehavior;
    
    // create animator and add behaviors
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view.superview];
    _animator = animator;
    [animator addBehavior:_snapBehavior];
    
    // add pan gesture recognizer
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)tapButton:(UITapGestureRecognizer *)tap
{
    [self selectButton:(id)tap.view];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.filterView setFrame:self.view.bounds];
}

- (void)createSnap
{
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.view snapToPoint:_restPoint];
    __weak typeof(self) weakself = self;
    _snapBehavior.action = ^{
        [weakself.delegate filterViewControllerUpdateFrame:weakself.view.frame];
    };
}

/**
 *  Setup filter before passing the filter to the calling the delegated method.
 */
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

- (void)updateFrame
{
    
}

- (UIView *)contentView
{
    return [((NTFilterTransformView *)self.view) contentView];
}

#pragma mark - Action

- (IBAction)selectButton:(UIButton *)button
{
    // since touch is in background, get main queue when need to
    //   rerender the button selection
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [button setSelected:!button.selected];
        
        // change selection for Public and Private buttons.
        //  Can't have both selection because selecting none will
        //   automatically include both public and private schools.
        if(button.selected) {
            if (button == self.typePrivateButton)
                [self.typePublicButton setSelected:NO];
            else if (button == self.typePublicButton)
                [self.typePrivateButton setSelected:NO];
        }
    });
    
    [self refreshFilter];
    
    [self.delegate filterViewControllerDidChangePredicate:self.filter];
}

#pragma mark - Pan Gesture Action

- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self.view.superview];
    CGRect frame;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.lastPoint = location;
            self.startPoint = location;
            [self.animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateChanged: {
            
            // rotate transform
            CGSize size = self.view.frame.size;
            CGPoint diff = CGPointDifference(location, CGPointMake(self.startPoint.x, self.startPoint.y - 600));
            CGFloat rotate = atan2f(diff.x, -diff.y);
            self.view.transform = CGAffineTransformMakeRotation(rotate);
            
            // dont use setFrame: as it disrupts the transform property
            // set position
            CGPoint moved = CGPointDifference(self.lastPoint, location);
            frame = CGRectMove(self.view.frame, moved);
            CGPoint point = CGPointAdd(CGPointMake(size.width * .5,size.height * .5), frame.origin);
            [self.view setCenter:point];
            
            _lastPoint = location;
            
            // send alert that frame is updated
            [self.delegate filterViewControllerUpdateFrame:self.view.frame];
        }break;
        case UIGestureRecognizerStateEnded:
            if (self.view.center.y < _mid || _restPoint.y == _max) {
                _restPoint.y = _min;
            } else {
                _restPoint.y = _max;
            }
            
            // recreate the snap behavior
            [self createSnap];
            
            // remove the 3D from layer
            self.view.transform = CGAffineTransformIdentity;
            
            // animate the layer back to the orginal position.
            [self.animator addBehavior:_snapBehavior];
            [self.animator addBehavior:_dynamicBehavior];
            break;
        default:
            break;
    }
}

@end
