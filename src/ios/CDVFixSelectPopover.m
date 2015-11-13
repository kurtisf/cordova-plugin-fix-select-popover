//
//  UIViewController+FixSelectPopover.m
//
//  Created by Kurt Fickewirth on 11/11/15.
//
// Extends the UIViewController to fix a problem with the UIWebView presenting a popover for
// HTML select controls on iPad. There is a race condition with the popover and setting the selected item.
// Also, if it is opened and closed fast, another race condition occurs where the popover is nil.

#import "MainViewController.h"
#import <objc/runtime.h>

@implementation UIViewController(UIViewController_FixSelectPopover)

+(void)load {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(presentViewController:animated:completion:);
        SEL swizzledSelector = @selector(fixSelectPopover_presentViewController:animated:completion:);
        SEL defaultSelector = @selector(defaultfixSelectPopover_presentViewController:animated:completion:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method defaultMethod = class_getInstanceMethod(class, defaultSelector);
        
        // First try to add the our method as the original.  Returns YES if it didn't already exist and was added.
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        // If we added it, then replace our call with the original name.
        if (didAddMethod) {
            
            // There might not have been an original method, its optional on the delegate.
            if (originalMethod) {
                
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            }
            else {
                // There is no existing method, just swap in our default below.
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(defaultMethod),
                                    method_getTypeEncoding(defaultMethod));
            }
        } else {
            
            // The method was already there, swap methods.
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void) fixSelectPopover_presentViewController:(UIViewController *)viewControllerToPresent
                                       animated:(BOOL)flag
                                     completion:(void (^)(void))completion {
    
    UIPopoverPresentationController *popoverController = viewControllerToPresent.popoverPresentationController;
    
    // If the VC is a UITableViewController, then we are trying to show a popover on iPad.
    if (popoverController && [viewControllerToPresent isKindOfClass:[UITableViewController class]]) {
        // If there is no popover variable, we are going to crash when it tries to set the selected entry.
        // This can be reproduced when using the next and previous arrows repeatedly on the keyboard to trigger the popover.
        if(![viewControllerToPresent valueForKey:@"popover"]) {
            return;
        }
        else {
            // Dispatch on the main thread to fix a race condition with UI rendering the popover.
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self fixSelectPopover_presentViewController:viewControllerToPresent animated:flag completion:completion];
                           });
        }
    }
    else {
        // Not a TableViewController, just go ahead and present.
        [self fixSelectPopover_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

- (void) defaultfixSelectPopover_presentViewController:(UIViewController *)viewControllerToPresent
                                              animated:(BOOL)flag
                                            completion:(void (^)(void))completion {
    
}
@end
