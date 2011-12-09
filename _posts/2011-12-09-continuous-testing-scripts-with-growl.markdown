---
layout: post
title: "Continuous Testing scripts with Growl"
date: 2011-12-09 17:36
tags:
- powershell
- tdd
---

Few days ago I discover Growl in twitter thanks to [Will Green](http://twitter.com/hotgazpacho). Growl is an open source notification system for Mac OS X. Basically it runs in the background and show the notifications sent by other programs.

I was thinking to add something like this few month ago [to my continuous testing scripts for javascript](/2011/08/08/javascript-continuous-testing-with-qunit-phantomjs-and-powershell/) but I didn't know about this software and even less than there is a [version for windows](http://www.growlforwindows.com/gfw/default.aspx).

So, I start playing with an powershell script I found from an old post of [Joel Bennett](http://huddledmasses.org/more-growl-for-windows-from-powershell/) changed to work with latest version of Growl, and published in [PsGet](http://psget.net).

If you install Growl, you can use this script as follow:

{% highlight bash %}
#Install PsGet
#run this line only if you don't have PsGet.Net already installed in order.
(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

#Install Send-Growl
#run this line if you don't have Send-Growl yet 
Import-Module PsGet
Install-Module Send-Growl

#Register the application and add a notice type
Register-GrowlType MyApp NoticeType

#Send a message
Send-Growl MyApp NoticeType "A Title" "Some description" "http://a.link.callback.com"
{% endhighlight %}

And as a result, you will see something like this:

![2011-12-09_1750.png](http://joseoncodecom.ipage.com/wp-content/uploads/images/2011-12-09_1750.png)

I use this module in my continuous testing script, when I save a file, the tests suite is executed and it shows me the results as you can see in this mini screencast:

![screencast](http://joseoncodecom.ipage.com/wp-content/uploads/images/tdd-continuous-growl.gif)

If you want to see how test this or see my javascript continuous testing script looks in [my jmail project](https://github.com/jfromaniello/jmail/blob/master/Tools/qunit-runner/continuous.ps1).
