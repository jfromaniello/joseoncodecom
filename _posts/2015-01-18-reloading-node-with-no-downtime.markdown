---
layout: post
title: "Reloading node with no downtime"
date: 2015-01-18 20:22
tags:
- node
---

I wrote a blog post about [Unix signals and Graceful shutdown in node.js applications](http://joseoncode.com/2014/07/21/graceful-shutdown-in-node-dot-js/) five months ago. In this article I will explain how to reload a node.js application with no downtime.

One of the things that I like about nginx is how it handles configuration changes [Controlling nginx](http://nginx.org/en/docs/control.html). The master process "reload the configuration" by creating new worker process when it receives the SIGHUP signal.

Node.js comes with a [cluster module](http://nodejs.org/api/cluster.html) that allows us to do very powerful things.

For this example I will use one worker but it can be extended to use as many workers as you want.

master.js:

```
var cluster = require('cluster');

console.log('started master with ' + process.pid);

//fork the first process
cluster.fork();

process.on('SIGHUP', function () {
  console.log('Reloading...');
  var new_worker = cluster.fork();
  new_worker.once('listening', function () {
    //stop all other workers
    for(var id in cluster.workers) {
      if (id === new_worker.id.toString()) continue;
      cluster.workers[id].kill('SIGTERM');
    }
  });
});
```

The master process start the first worker and then listen to the SIGHUP signal. Then when it receives a SIGHUP signal it fork a new worker and wait the worker until is [listening](http://nodejs.org/api/cluster.html#cluster_event_listening) on the IPC channel, once the worker process is listening it kill the other workers.

This works out of the box because the cluster module allows several worker process to listen on the same address.

server.js:

```
var cluster = require('cluster');

if (cluster.isMaster) {
  require('./master');
  return;
}

var express = require('express');
var http = require('http');
var app = express();

app.get('/', function (req, res) {
  res.send('ha fsdgfds gfds gfd!');
});

http.createServer(app).listen(8080, function () {
  console.log('http://localhost:8080');
});
```

This is the entry point for the application, it is a simple express application with the exception of the first part.

You can test this as follows:

![](https://s3.amazonaws.com/joseoncode.com/img/node_reload.png)

I've uploaded a more [complete example](https://github.com/jfromaniello/zero-downtime-node) to github.
