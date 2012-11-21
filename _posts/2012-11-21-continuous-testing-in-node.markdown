---
layout: post
title: "Continuous testing in node with supervisor"
date: 2012-11-21 12:12
tags:
- node
- tdd 
---

I have been using a little module from Isaac Schlueter named [Supervisor](https://github.com/isaacs/node-supervisor) for continuous testing.

Suppose you have a Makefile like this:

{% highlight text %}
REPORTER ?= spec

test: 
	@clear && reset
	./node_modules/.bin/mocha --reporter $(REPORTER)

.PHONY: all test clean
{% endhighlight %}


You can add another target as follows:

{% highlight text %}
watch: 
	./node_modules/.bin/supervisor -q -n exit -e 'node|js|json|config' -x make test
{% endhighlight %}

The parameters means:

-  q: quiet (supress debug messages)
-  n: no restart on exit
-  e: watch for changes in these extensions
-  x: the executable for this will be **make**
-  test: the name of the thing we want to execute with **make**

This works pretty well for me, [mocha](http://visionmedia.github.com/mocha/) has an option for continuous testing **-w** but it is very broken because it runs everything on the same node process.