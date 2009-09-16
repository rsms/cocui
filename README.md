# Cocui

COCoa User Interface mockup.

For rapidly building functional Cocoa applications using WebKit (HTML, CSS and JavaScript).

## Download

Latest releases from [http://hunch.se/cocui/](http://hunch.se/cocui/dist/)

Cocui will keep itself up to date using [Sparkle](http://sparkle.andymatuschak.org/) <small> and _requires Mac OS X 10.5 or later_.

## What awesome stuff can I do with this?

Everyone love bullet-points:

- Write your app like a regular HTML page with javascript
- Opening of files by associating your app with one or more file types
- Retains the WebKit debugger, profiler, console and inspector developer tools
- Unrestricted XHR (can load and interact with any resource on the web or local)
- NSApplication events propagated as native Javascript events in your document (i.e. "applicationWillBecomeActive", etc)
- Full control over window (resizing, minimizing, hiding, closing, etc through "App.window")
- Full control over NSApp (terminating, etc through "App.app")
- Access to NSUserDefaults (system-native application settings) through "App.defaults"
- Single namespace exposes the "bridge" between Cocoa and Javascript -- "App"
- Most of these things demonstrated in the demo app [resources/index.html](http://github.com/rsms/cocui/blob/master/resources/index.html)

The Javascript-to-Cocoa bridge enables access to most things, like your NSApplication and your NSWindow.

You can do stuff like this:

	<a href="javascript:Win.miniaturize()">Minimize application</a>

and

	var window = App.loadWindow({
	  uri: 'index.html',
	  rect: { size: { width: 500, height: 400 } }
	})
	window.makeKeyAndOrderFront();

Native drag and drop is [already supported by WebKit](http://developer.apple.com/mac/library/documentation/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/DragAndDrop.html#//apple_ref/doc/uid/30001233-BAJGJJAH).


## Development mode

Development mode enables a series of tools, aiding development:

- Interactive javascript console
- DOM and CSS inspector
- Javascript profiler
- Javascript debugger
- Resource tracker (aka "the timeline")
- HTML5 database manager
- Access to a streaming text log of messages both from your application (using console.log() etc) and from the runner core.
- Quick restarting (reloading) of your app w/o restarting the actual process

To enable development mode for a Cocui application, set the boolean defaults key "DevelopmentMode" to `true` for.

Example:

	$ defaults write my.cocui.app DevelopmentMode -bool yes

You need to restart the native app after changing this key. Afterwards, a new menu item will appear: "Develop".

When creating new application projects using the Cocui app, DevelopmentMode is already set for you.


## Creating a new project

You create a new app project by running the Cocui application. Choose a name and a UTI (and optionally a few other things, like icon and document types). Cocui will then create a new project for you and get you going. If you have TextMate or SubEthaEdit, your editor will launch together with your new application.
