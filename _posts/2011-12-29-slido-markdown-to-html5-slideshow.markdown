---
layout: post
title: "Slido: markdown to html5 slideshow"
date: 2011-12-29 09:57
tags: 
- nodejs
---

[Slido](http://slido.herokuapp.com) is an experiment I did in [node.js](http://nodejs.org/) based on Google's [Html5 Rocks](http://slides.html5rocks.com/) and inspired by [Ruby S9 project](http://slideshow.rubyforge.org/).

Basically you write your presentation in markdown right in the page, and you get an html5 presentation that looks like a [ppt](http://en.wikipedia.org/wiki/Microsoft_PowerPoint) but is better. You can edit it has many times as you want.

If you save the presentation while you are authenticated (only facebook for now), you can share the link to view the presentation but no one can edit it except you. 

I did some improvements to Google's javascript client-side code, for instance now it works properly on IE9 (without the fancy CSS3 animations) and I also added a very hot new theme; "Windows Metro". This is an example of my [CodeCamp presentation](http://slido.herokuapp.com/slide/4e92efdd02e4c50100000001?defaultTheme=metro#slide-landing-slide) (spanish).

The code is opensource and it is [here](https://github.com/jfromaniello/slido). Any feedback is welcome, don't hesitate to send me a pull request and I will push to the heroku app.