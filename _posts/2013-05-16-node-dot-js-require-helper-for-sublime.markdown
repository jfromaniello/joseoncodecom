---
layout: post
title: "node.js require helper for sublime"
date: 2013-05-16 10:20
tags: 
- node
---

I published some time ago a plugin for Sublime that makes my life easier when working in node.js. It allows me to introduce ```require``` calls by searching for the files in the current folder.

I press ```⌘⇧m```, then I search the file/module I want to require and it automatically calculates the relative path. Also I can use it to introduce require to native modules, or the modules I've installed on my node_modules folder.

Here is a short video: 

[! ](http://joseoncodecom.ipage.com/wp-content/uploads/images/require-helper.gif)

You can install it with the Sublime Package Control, source code is [here](https://github.com/jfromaniello/sublime-node-require).