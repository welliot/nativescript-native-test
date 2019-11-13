#import "NativeAnimator.h"

typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateThumbnail,
    PlayerStateFullscreen,
};

@interface NativeAnimator ()

@property (weak, nonatomic) UIView *parentView;
@property (weak, nonatomic) UIView *playerView;
@property (nonatomic) UIViewPropertyAnimator *playerViewAnimator;
@property (nonatomic) CGRect originalPlayerViewFrame;
@property (nonatomic) PlayerState playerState;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UIView* b;

@end

@implementation NativeAnimator

-(id)initWithView:(UIView*)view andParent:(UIView*)parent {
    self = [super init];
    if (self) {
        self.playerView = view;
        self.parentView = parent;
    }

    return self;
}

-(void)setup {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.parentView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.parentView.superview];

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self panningBegan];
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.parentView];
        [self panningEndedWithTranslation:translation velocity:velocity];
    }
    else
    {
        CGPoint translation = [recognizer translationInView:self.parentView.superview];
        [self panningChangedWithTranslation:translation];
    }
}

- (void)panningBegan
{
    if (self.playerViewAnimator.isRunning)
    {
        return;
    }

    CGRect targetFrame;

    switch (self.playerState) {
        case PlayerStateThumbnail:
            self.originalPlayerViewFrame = self.playerView.frame;
            targetFrame = self.parentView.frame;
            break;
        case PlayerStateFullscreen:
            targetFrame = self.originalPlayerViewFrame;
    }

    self.playerViewAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.5 dampingRatio:0.8 animations:^{
        self.playerView.frame = targetFrame;
    }];
}

- (void)panningChangedWithTranslation:(CGPoint)translation
{
    if (self.playerViewAnimator.isRunning)
    {
        return;
    }

    CGFloat translatedY = self.parentView.center.y + translation.y;

    CGFloat progress;
    switch (self.playerState) {
        case PlayerStateThumbnail:
            progress = 1 - (translatedY / self.parentView.center.y);
            break;
        case PlayerStateFullscreen:
            progress = (translatedY / self.parentView.center.y) - 1;
    }

    progress = MAX(0.001, MIN(0.999, progress));

    self.playerViewAnimator.fractionComplete = progress;
}

- (void)panningEndedWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity
{
    self.panGestureRecognizer.enabled = NO;

    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    __weak NativeAnimator *weakSelf = self;

    switch (self.playerState) {
        case PlayerStateThumbnail:
            if (translation.y <= -screenHeight / 3 || velocity.y <= -100)
            {
                self.playerViewAnimator.reversed = NO;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    weakSelf.playerState = PlayerStateFullscreen;
                    weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
            else
            {
                self.playerViewAnimator.reversed = YES;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    weakSelf.playerState = PlayerStateThumbnail;
                    weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
            break;
        case PlayerStateFullscreen:
            if (translation.y >= screenHeight / 3 || velocity.y >= 100)
            {
                self.playerViewAnimator.reversed = NO;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    weakSelf.playerState = PlayerStateThumbnail;
                    weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
            else
            {
                self.playerViewAnimator.reversed = YES;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    weakSelf.playerState = PlayerStateFullscreen;
                    weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
    }

    CGVector velocityVector = CGVectorMake(velocity.x / 100, velocity.y / 100);
    UISpringTimingParameters *springParameters = [[UISpringTimingParameters alloc] initWithDampingRatio:0.8 initialVelocity:velocityVector];

    [self.playerViewAnimator continueAnimationWithTimingParameters:springParameters durationFactor:1.0];
}

@end