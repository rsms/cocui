// Load index.html in a regular window and display it
App.createWindow({
  uri: 'index.html',
	name: 'main',
  rect: { size: { width: 500, height: 400 } }
}).makeKeyAndOrderFront();

// Alternative minimal example of opening a window
/*App.createWindow('index.html').makeKeyAndOrderFront();
*/

// Example of a fullscreen window (quits after 4 seconds)
/*App.createWindow({ uri: 'index.html', fullscreen: true }).makeKeyAndOrderFront();
setTimeout(function(){ App.terminate() }, 4000);
*/

// Alternative example of a fullscreen window (exits fullscreen after 4 seconds)
/*var win = App.createWindow({uri: 'index.html'}); // add style:{borderless:true} to remove ui chrome
win.makeKeyAndOrderFront();
win.fullscreen = true;
setTimeout(function(){ win.fullscreen = false }, 4000);
*/

// Example of encoding and decoding JSON
/*var s = App.encodeJSON({uri: 'index.html', moset: {0:1,1:2,9:3,4:undefined,98:56}});
console.log(s);
var o = App.decodeJSON(s);
console.log(o.uri);
*/
