---
layout: post
title: "WinSer: node.js applications as windows services"
date: 2012-04-06 20:03
tags: 
 - node
 - javascript
---

[WinSer](http://jfromaniello.github.com/winser) is a new node.js module I have created to install node.js applications as windows services.

First you install the package:

{% highlight bash %}
$ npm install winser
{% endhighlight %}

It also works if you install it globally (-g option).

Then you can run it in your application folder:

{% highlight bash %}
$ winser -i
{% endhighlight %}

winser will take the application name from your package.json and use it as the windows service name. 
*You must run this command in an elevated console.*

Also you can add two scripts to your package.json:

{% highlight javascript %}
"scripts": {
    "install-windows-service": "node_modules\\.bin\\winser -i",
    "uninstall-windows-service": "node_modules\\.bin\\winser -r"
  }
{% endhighlight %}

and then when you want to install it in other machines you only run:

{% highlight bash %}
npm run-script install-windows-service
{% endhighlight %}

More about nssm
===============

Winser uses [nssm.exe](http://nssm.cc/) by Iain Patterson behind the scenes. From the nssm.exe page:

> nssm is a service helper which doesn't suck. srvany and other service helper programs suck because they don't handle failure of the application running as a service. If you use such a program you may see a service listed as started when in fact the application has died. nssm monitors the running service and will restart it if it dies. With nssm you know that if a service says it's running, it really is. Alternatively, if your application is well-behaved you can configure nssm to absolve all responsibility for restarting it and let Windows take care of recovery actions.

> nssm logs its progress to the system Event Log so you can get some idea of why an application isn't behaving as it should.

> nssm also features a graphical service installation and removal facility. Admittedly this does suck. I hate trying to make GUIs...

Credits
=======

I took the idea from this [post](http://blog.tatham.oddie.com.au/2011/03/16/node-js-on-windows/) of Tatham Oddie.