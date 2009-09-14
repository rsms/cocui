// test JSON
/*var s = App.encodeJSON({uri: 'index.html', moset: {0:1,1:2,9:3,4:undefined,98:56}});
console.log(s);
var o = App.decodeJSON(s);
console.log(o.uri);
*/

// Load index.html in a window and display the window
App.loadWindow({
  uri: 'index.html',
  rect: { size: { width: 500, height: 400 } }
}).makeKeyAndOrderFront();
