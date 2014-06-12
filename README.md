# AppbotX

AppbotX is an iOS client library and sample application for the [AppbotX](http://appbot.co/appbotx) service. It is currently in limited beta.

## Usage

To run the example project; clone the repo, and open "Sample Project.xcodeproj" from the Example folder.

Detailed usage documentation is coming, but please refer to the example for the time being.

## Requirements

The sample project includes a test key, but for you own application you will need an [Appbot](http://appbot.co) account and an API key.

## Installation

Appbotx will be available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile and run pod install.

    pod "AppbotX", :git => "https://github.com/appbotx/appbotx.git"

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

## License

AppbotX is available under the MIT license. See the LICENSE file for more info.

