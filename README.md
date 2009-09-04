# Cocui

COCoa User Interface mockup.

For mocking up functional Cocoa applications using WebKit (HTML and JavaScript).

(Currently considered an experiment)

## What awesome stuff can I do?

The Javascript-to-Cocoa bridge enables access to most things, like your NSApplication and your NSWindow.

The demo app [resources/index.html](http://github.com/rsms/cocui/blob/master/resources/index.html) runs a sequence of functions with 1 second delay (for demonstrational purposes). It shows how to manipulate the window frame (and while doing so also use native animation), shadow, miniaturize/deminiaturize, change window title and more.

You can do stuff like this:

	<a href="javascript:ev.window.miniaturize()">Minimize application</a>
