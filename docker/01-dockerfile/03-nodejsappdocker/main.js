var http=require('http');
var os = require('os');

var server = http.createServer(function(request,response){
response.writeHead(200,{"Content-Type":"text/plain"});
var client = request.connection.remoteAddress;
response.write("Request received from: "+client);
response.write("\nHello from node: "+os.hostname());
response.end("\nversion 2 change\n");
});

server.listen(8000);
console.log("server started on  "+os.hostname()+":8000");
