---
layout: post
title: "PsGet.Net the repository for reusable powershell modules"
date: 2011-12-08 23:02
tags: 
- powershell
---

I love internet. Few MINUTES after I published one of my previous posts [Sharing powershell scrtips easily](/2011/11/24/sharing-powershell-modules-easily/) I received a comment from [Mike Chaliy](http://twitter.com/#!/chaliy) ;

> Hello, if you do not mind I added PsWatch to PsGet ;). Now if somebody have psget installed, Install-Module pswatch will do job.

Of course I didn't mind! In fact I love to discover things in this way. 

This is something really needed in the powershell echosystem; a centralized place to share reusable things.

[PsGet](http://psget.net/) is a powershell pure-module you can easily install it with one line:

{% highlight bash %}
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
{% endhighlight %}

And then you have to import the module as any other powershell module before using it:

{% highlight bash %}
    Import-Module PsGet
{% endhighlight %}

and then you can start using it. There is only one important command for now which is Install-Module. For instance if you want to install my PsWatch script, you do:

{% highlight bash %}
    Install-Module PsWatch
{% endhighlight %}

and you are done!

![2011-12-09_0004.png](http://joseoncodecom.ipage.com/wp-content/uploads/images/2011-12-09_0004.png)

Another interesting thing about PsGet is that you don't need to publish something to the repository in order to install it. You can use the modifiers -ModuleName to set the name of the module, and -ModuleUrl to provide an url where the module content is served as plain text:

{% highlight bash %}
    Install-Module -ModuleUrl https://mydomain.com/mymodule.psm1 -ModuleName my-module
{% endhighlight %}

If you want to take a look to the scripts already published you can look [here](http://psget.net/directory/).

Things to improve
=================

One of the things that needs more work I think is to descentralize the directory. Right now the only way to publish something is to fork Mike repository, edit the directory.xml file and push-request him. 

But so far is looking really good, well done Mike!