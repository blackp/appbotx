# AppbotX

AppbotX is an iOS client library and sample application for the [AppbotX](http://appbot.co/appbotx) service. It is currently in [limited beta](https://appbot.co/appbotx).

## Requirements

The sample project includes a test key, but for you own application you will need an [Appbot](http://appbot.co) account and an API key.

## Installation

Appbotx will be available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile and run pod install.

    pod "AppbotX", :git => "https://github.com/appbotx/appbotx.git"
    
Alternatively you can just [download the latest release](https://github.com/appbotx/appbotx/releases) and add it to your project.

Then initialize with your API key in your AppDelegate

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
    	[[ABXApiClient instance] setApiKey:@"API_KEY"];
    	return YES;
	}

And import ABX.h into your precompiled header. Alternatively you can just include it within the files you require.

	#ifdef __OBJC__
    	#import <UIKit/UIKit.h>
    	#import <Foundation/Foundation.h>

    	#import "ABX.h"
	#endif

## Usage

To run the example project; clone the repo, and open "Sample Project.xcodeproj" from the Example folder.

### FAQ

### Default UI
To show the default UI simply call the showFromController helper method on ABXFAQsViewController.

	[ABXFAQsViewController showFromController:self hideContactButton:NO contactMetaData:nil];

* **controller** - required - the controller to be presented from.
* **hideContactButton** - YES/NO - if the contact button should be shown the the top right.
* **metaData** - optional - extra meta data you would like to attach if the contact is shown, only use types supported by NSJSONSerialization, e.g. NSString, NSNumber etc.

#### Push On Your Own UINavigationController

	ABXFAQsViewController *controller = [[ABXFAQsViewController alloc] init];
	// Optinally set hideContactButton & contactMetaData
	[self.navigationController pushViewController:controller animated:YES];
	
#### Fetch Manually

	    [ABXFaq fetch:^(NSArray *faqs, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        switch (responseCode) {
            case ABXResponseCodeSuccess: {
            	// Success, use faqs
            }
                break;
                
            default: {
            	// Failure       
            }
                break;
        }
    }];	

* **faqs** array of ABXFaq objects.
* **responseCode** - response code, ABXResponseCodeSuccess for success, see enum for errors.
* **httpCode** - the http code, 200 for success etc.
* **error** - the error, nil if success.

### Feedback

#### Default UI

To show the default UI simply call the showFromController helper method on ABXFeedbackViewController.

	[ABXFeedbackViewController showFromController:self placeholder:@"default hint" email:nil metaData:@{ @"Sample" : @YES } image:nil];

* **controller** - required - the controller to be presented from.
* **placeholder** - optional - the default hint text shown, nil to use the default.
* **email** - optional - the default email address to use, if you have this otherwise nil.
* **metaData** - optional - extra meta data you would like to attach, only use types supported by NSJSONSerialization, e.g. NSString, NSNumber etc.
* **image** - optional - an image, such as a screenshot to be attached by default.

#### Push On Your Own UINavigationController

	ABXFeedbackViewController *controller = [[ABXFeedbackViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];

### Versions

Documentation coming soon, check the example.

### Notifications

Documentation coming soon, check the example.
	
## Communication

* If you found a bug, [open an issue](https://github.com/appbotx/appbotx/issues).
* If you have a feature request, [open an issue](https://github.com/appbotx/appbotx/issues).
* If you want to contribute, [submit a pull request](https://github.com/appbotx/appbotx/pulls).	

## License

AppbotX is available under the MIT license. See the LICENSE file for more info.

