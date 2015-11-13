# cordova-plugin-fix-select-popover
This is a simple Cordova plugin to fix crashes on iPad when a user opens a HTML select control.  The UIWebView does not always correclty handle the popover on iPad under certain scenarios.  It uses a swizzle to extend UIViewControler's presentViewController method.

Here are a few examples of the crashes we've found:


Fatal Exception: NSRangeException
-[UITableView _contentOffsetForScrollingToRowAtIndexPath:atScrollPosition:]: row (4) beyond bounds (0) for section (0).


Fatal Exception: NSGenericException
UIPopoverPresentationController (<UIPopoverPresentationController: 0x15d0eda0>) should have a non-nil sourceView or barButtonItem set before the presentation occurs.


## Install ##

You can add the plugin to your Cordova project from this repository:

	cordova plugin add https://github.com/kurtisf/cordova-plugin-fix-select-popover


## Setup ##

None!  Just add the plugin and that’s it!
The code is in an iOS Category which swizzle's itself in.
