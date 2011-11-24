---
layout: post
title: "Sharing Powershell modules easily"
date: 2011-11-24 11:21
tags: 
- powershell
---

Few weeks ago while I was writing the [PsWatch](http://joseoncode.com/2011/11/16/pswatch-monitoring-file-changes-in-directory/) module I was looking for an easy way to share the module with other people and on the other hand an easy way to install the module. 

In this article I will describe how I did it for PsWatch using [github](http://github.com).

What is a powershell module?
============================

Powershell 2 introduced a model where you can write "extensions" to powershell in... Powershell. This wasn't possible in Powershell 1 where the only way to extend powershell is with SnapIn modules written in c#.

A module is a ["psm1" file which a function inside](https://github.com/jfromaniello/pswatch/blob/master/pswatch.psm1). 

If you want to have a module available everywhere you can store the module in the following path:

	user\documents\windowspowershell\modules\mymodule

if you want the module to be available for all users, you can store the module file in:

	windows\system32\windowspowershell\V1.0\modules\mymodule


The installation script
=======================

The first thing I did with PsWatch was to create an installation script which is another powershell file.

The installation script does two very basic steps:

* Download the psm1 file from github as raw string
* Save the content of the file in the user modules folder

The code is:

{% highlight bash %}
$modulespath = ($env:psmodulepath -split ";")[0]
$pswatchpath = "$modulespath\pswatch"

Write-Host "Creating module directory"
New-Item -Type Container -Force -path $pswatchpath | out-null

Write-Host "Downloading and installing"
(new-object net.webclient).DownloadString("https://raw.github.com/jfromaniello/pswatch/master/pswatch.psm1") | Out-File "$pswatchpath\pswatch.psm1" 

Write-Host "Installed!"
Write-Host 'Use "Import-Module pswatch" and then "watch"'
{% endhighlight %}


How to run the installation script?
===================================

Now, all this wouldn't make any sense if you have to download the installation script... in order to install the script. Luckily, there is an easier way.

1. Push this script to the repository of PsWatch in github. 
2. Once we have the installation script in github, we grab the url to the "raw" version of the  file, which is something like:

	https://raw.github.com/jfromaniello/pswatch/master/install.ps1

3. Then we can generate a shorter link with [bit.ly](http://bit.ly)

	http://bit.ly/Install-PsWatch

4. And now we can install the script simply executhing this line:

	iex ((new-object net.webclient).DownloadString("http://bit.ly/Install-PsWatch"))

The next step I would do is to add a readme file to the repository with the instalation instructions, i.e. the above line.

Even more easy for the users
============================

Okay, now we have an easy way to install PsWatch, and we can write scripts that use PsWatch. 

The sceario that I have is that the script that depends uppong PsWatch is used by other developers in my team **on their own machines**. And honestly, having to point my team mates to the installation instructions is a waste of time, so I wrote my script as follows:

{% highlight bash %}
$m = Get-Module -List pswatch 
if(!$m) {
	Write-Host "Uh-Oh you don't have the pswatch cmdlet installed. Let me handle that for you."
	iex ((new-object net.webclient).DownloadString("http://bit.ly/Install-PsWatch"))
} 
Import-Module pswatch

$currentLocation = Get-Location

watch "somefolder"
	| Get-Item
	| %{
		...$_.Path
		run tests whatever 
	}
{% endhighlight %}

In this script the first 6 lines will look for the module and if the module is not already installed on the machine/profile it will automatically install it.

Now, there are lot of things in Powershell that I would like too see distributed in this way. And by sure the powershell community can take this approach one step further and create a common directory or repository of opensource powershell scripts.