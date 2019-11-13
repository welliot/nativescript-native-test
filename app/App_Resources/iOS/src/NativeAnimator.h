#import <Foundation/Foundation.h>

@interface NativeAnimator : NSObject

-(id)initWithView:(UIView*)view andParent:(UIView*)parent;
-(void)setup;

@end