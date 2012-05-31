---
layout: post
title: "node.js and the beauty of working on a platform that embraces opensource"
date: 2012-05-31 08:06
tags:
- node
- javascript 
---

In will show in this article one of the most beautiful things of working in node.js and how it node.js embraces opensource the right way.

I have been working full time in a project using node.js for [Tellago Studios](http://www.tellagostudios.com/), I have read a lot of posts about node.js being cancer, why don't using node.js, why javascripts callbacks sucks for async workflows and so on, and even if I agree with some things at some point there are things in node.js done right, things to applaud and things to learn from it. This article is about something to applaud and learn from it.  

# tl;dr

When working with node.js you can swap a dependency or a sub-dependency with a link to your fork-branch in a git repository. Make sure you understand the [[1] algorithm for loading modules](http://nodejs.org/docs/latest/api/modules.html#modules_all_together) and [[2] npm install](http://npmjs.org/doc/install.html)

# A bug story

Lets say you are working on your project and you are using a third party opensource module named Foo, your package.json will looks like:

{% highlight javascript %}
{
  "name": "myproject",
  "version": "0.0.1",
  "dependencies": {
    "foo" : "*"
  },
}
{% endhighlight %}


The star * here means *any version*. 

If you look at the your project folder you will see a tree like this:

{% highlight text %}
myproject/
    server.js
    package.json
    node_modules/
        foo/
            package.json
            node_modules/
            bar/
                package.json
                node_modules/
                    another/
{% endhighlight %}

Now suppose that you find a bug, you fire up [[3] node-inspector](https://github.com/dannycoates/node-inspector) and you start digging in your modules, then you figure out that the problem is in the module "bar". 

Now, the flow will be something like this:

1. Clone the module Bar (which of course is opensource of course as the bast majority of node.js modules) in another folder. If you don't know where the Bar module repository is hosted, don't worry, look at its package.json the url will be there for sure.
2. Fix the issue and try things as crazy. Write tests!
3. Commit, revert, commit, branch blah
4. Push to your fork of the project
5. Do a pull request to the project owner[s]

So far this is are the standards steps you will take in any platform, even in .net. Because node.js developers take so **serious** this opensource business it is very likely that your pull request will be at least reviewed or discussed the same day. 

**But what if not?**

You still have a bug to solve in your project, and no one in your team or company want to wait for you or other people to:

1. merge your fix
2. publish to npm a fix of Bar
3. publish a new version of Foo pointing to the fixed Bar.

# Node community understand open source

As crazy as it might sound, we can easily do this in OUR package.json: 

{% highlight javascript %}
{
  "name": "myproject",
  "version": "0.0.1",
  "dependencies": {
    "bar": "git://github.com/youruser/bar.git#my-branch-to-the-ugly-bug"
    "foo" : "*"
  },
}
{% endhighlight %}

run **npm install** and you are done. Your project and most important, your local instance of the package Foo is using the fork of your Bar. Your team will be able to work with and everyone is happy. We can even omit the pull request if I find is something useful only in my project or something that should not be on the main repository of bar.

We can also release our project as opensource and no one is going to be affected.

Whats the price for a feature like this in a programming language / platform?

# How does it works?

There are few things involved in this.

The first thing is the ability of **npm** to install things from a git repository as explained in [[2] npm install](http://npmjs.org/doc/install.html) the package could be:

    a) a folder containing a program described by a package.json file
    b) a gzipped tarball containing (a)
    c) a url that resolves to (b)
    d) a <name>@<version> that is published on the registry with (c)
    e) a <name>@<tag> that points to (d)
    f) a <name> that has a "latest" tag satisfying (e)
    g) a <git remote url> that resolves to (b)


The second things is how the module system (i.e. the require function) works as explained in [[1] Node.js: Modules - All together](http://nodejs.org/docs/latest/api/modules.html#modules_all_together) , specifically this part:

    NODE_MODULES_PATHS(START)
    1. let PARTS = path split(START)
    2. let ROOT = index of first instance of "node_modules" in PARTS, or 0
    3. let I = count of PARTS - 1
    4. let DIRS = []
    5. while I > ROOT,
       a. if PARTS[I] = "node_modules" CONTINUE
       c. DIR = path join(PARTS[0 .. I] + "node_modules")
       b. DIRS = DIRS + DIR
       c. let I = I - 1
    6. return DIRS

It means that when trying to solve the module Bar from Foo, this thing will start with a path like this:
    
    node_modules/foo/node_modules

and as is explained there, first it will look for Bar in the first node_modules folder.

And last but not least is the fact that the node.js community understand how opensource works. All modules in node.js are opensource, and almost all modules in node are in git and in github. It is easy to understand modules because all modules have almost the same file structure package.json, lib/bin folders, etc. This means there is a way to do it and most people is following that way.

I have the pleasure to assist to jsConf in Argentina and listen to [[4] Isaac Z. Schlueter](http://blog.izs.me/) current *curator* of node.js and creator of npm and it is not surprising that the technical thing explained here is in the same line that the principles he encourage. Unfortunately the talk is not online (yet? saw it was being recorded) neither his slides but I found slides from another very similar talk [[5] TacoConf Anarchism](http://blog.izs.me/post/23048895912/tacoconf-anarchism)


[[1] Node.js: Modules - All together](http://nodejs.org/docs/latest/api/modules.html#modules_all_together)
[[2] npm install](http://npmjs.org/doc/install.html)
[[3] node-inspector](https://github.com/dannycoates/node-inspector) 
[[4] Isaac Z. Schlueter](http://blog.izs.me/)
[[5] TacoConf Anarchism](http://blog.izs.me/post/23048895912/tacoconf-anarchism)