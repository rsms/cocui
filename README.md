# Cocui

COCoa User Interface mockup.

For rapidly building functional Cocoa applications using WebKit (HTML, CSS and JavaScript).

## What awesome stuff can I do?

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
- Most of these things demonstrated in the demo app (resources/index.html)

The Javascript-to-Cocoa bridge enables access to most things, like your NSApplication and your NSWindow.

The demo app [resources/index.html](http://github.com/rsms/cocui/blob/master/resources/index.html) runs a sequence of functions with 1 second delay (for demonstrational purposes). It shows how to manipulate the window frame (and while doing so also use native animation), shadow, miniaturize/deminiaturize, change window title and more.

You can do stuff like this:

	<a href="javascript:App.window.miniaturize()">Minimize application</a>

Native drag and drop is [already supported by WebKit](http://developer.apple.com/mac/library/documentation/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/DragAndDrop.html#//apple_ref/doc/uid/30001233-BAJGJJAH).


## Development mode

Development mode enables a series of tools, aiding development:

- The Webkit interactive javascript console
- DOM and CSS inspector
- Resource tracker (aka "the timeline")
- Javascript profiler
- HTML5 database manager
- Access to a streaming text log of messages both from your application (using console.log() etc) and from the runner core.
- Quick restarting (reloading) of your app w/o restarting the actual process

To enable development mode, set or change the boolean defaults key "DevelopmentMode" to `true` for your app.

Enable for the demo app:

	$ defaults write se.notion.Cocui DevelopmentMode -bool yes
