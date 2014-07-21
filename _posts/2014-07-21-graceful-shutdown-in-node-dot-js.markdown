---
layout: post
title: "Graceful shutdown in node.js"
date: 2014-07-21 08:42
tags:
- node
---

According to [wikipedia - Unix Signal](http://en.wikipedia.org/wiki/Unix_signal):

> Signals are a limited form of inter-process communication used in Unix, Unix-like, and other POSIX-compliant operating systems. A signal is an asynchronous notification sent to a process or to a specific thread within the same process in order to notify it of an event that occurred.

There are a bunch of generic signals, but I will focus on two:

-  `SIGTERM` is used to cause a program termination. It is a way to __politely__ ask a program to terminate. The program can either handle this signal, clean up resources and then exit, or it can ignore the signal.
-  `SIGKILL` is used to cause inmediate termination. Unlike SIGTERM it can't be handled or ignored by the process.

Wherever and however you are deploying your node.js application it is very likely that the system in charge of running your app use these two signals:

-  [Upstart](http://upstart.ubuntu.com/cookbook/#stopping-a-job): When stoping a service, by default it sends SIGTERM and waits 5 seconds, if the process is still running, it sends SIGKILL.
-  [supervisord](http://supervisord.org/configuration.html): When stoping a service, by default it sends SIGTERM and waits 10 seconds, if the process is still running, it sends SIGKILL.
-  [runit](http://supervisord.org/configuration.html): When stoping a service, by default it sends SIGTERM and waits 10 seconds, if the process is still running, it sends SIGKILL.
-  [Heroku dynos shutdown](https://devcenter.heroku.com/articles/dynos#graceful-shutdown-with-sigterm): as described in this link heroku send SIGTERM, waits the process to exit for 10 seconds and if the process is still running it sends SIGKILL.
-  [Docker](https://docs.docker.com/reference/commandline/cli/#stop): If you run your node app in a docker container, when running `docker stop` command the main process inside the container will receive SIGTERM, and after a grace period (10 seconds by default), SIGKILL.

So, let's try a with this simple node application:

```
var http = require('http');

var server = http.createServer(function (req, res) {
  setTimeout(function () { //simulate a long request
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World\n');
  }, 4000);
}).listen(9090, function (err) {
  console.log('listening http://localhost:9090/');
  console.log('pid is ' + process.pid)
});
```

As you can see response are delayed 4 seconds. The node documentation [here](http://nodejs.org/api/process.html#process_signal_events) says:

> SIGTERM and SIGINT have default handlers on non-Windows platforms that resets the terminal mode before exiting with code 128 + signal number. If one of these signals has a listener installed, its default behaviour will be removed (node will no longer exit).

It is not clear from here what's the default behavior, I send SIGTERM in the middle of a request the request will fail as you can see here:

```
» curl http://localhost:9090 &
» kill 23703
[2] 23832
curl: (52) Empty reply from server
```

Fortunately, the http server has a [`close` method](http://nodejs.org/api/http.html#http_server_close_callback) that stops the server for receiving new connections and calls the callback once it finished handling all requests. This method comes from the NET module, so is pretty handy for any type of tcp connections.

Now, if I modify the example to something like this:

```
var http = require('http');

var server = http.createServer(function (req, res) {
  setTimeout(function () { //simulate a long request
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World\n');
  }, 4000);
}).listen(9090, function (err) {
  console.log('listening http://localhost:9090/');
  console.log('pid is ' + process.pid);
});

process.on('SIGTERM', function () {
  server.close(function () {
    process.exit(0);
  });
});
```

And then I use the same commands as above:

```
» curl http://localhost:9090 &
» kill 23703
Hello World
[1]  + 24730 done       curl http://localhost:9090
```

You will notice that the program doesn't exit until it finished processing and serving the last request. More interesting is the fact that after the SIGTERM signal it doesn't handle more requests:

```
» curl http://localhost:9090 &
[1] 25072

» kill 25070

» curl http://localhost:9090 &
[2] 25097

curl: (7) Failed connect to localhost:9090; Connection refused
[2]  + 25097 exit 7     curl http://localhost:9090

» Hello World
[1]  + 25072 done       curl http://localhost:9090
```

Some examples in blogs and stackoverflow uses a timeout on SIGTERM in the case that server.close takes longer than expected. As mentioned above this is unnecesary because every process manager will send a SIGKILL if the SIGTERM takes too much time.