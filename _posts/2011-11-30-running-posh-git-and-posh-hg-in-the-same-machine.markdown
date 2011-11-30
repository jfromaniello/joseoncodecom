---
layout: post
title: "Posh-Git and Posh-Hg in the same machine"
date: 2011-11-30 14:30
tags:
- git 
- mercurial
---


[Git](http://git-scm.com/) and [Mercurial](http://mercurial.selenic.com/) have powerfull command line interfaces besides GUIs like TortoiseGit, GitExtensions and TortoiseHg. 

There are two projects that I like [Posh-Git](https://github.com/dahlbyk/posh-git) and [Posh-Hg](https://github.com/JeremySkinner/posh-hg). These projects add to the Powersherll terminal TAB completion and some usefull information in the prompt as shown here:

![Posh-Hg screenshot](http://joseoncodecom.ipage.com/wp-content/uploads/images/2011-11-30_1527.png)

The problem that I had is that even if it is well documented how to install each one, I couldn't make both work in the same machine. There is an answer in [stackoverflow](http://stackoverflow.com/a/4845935/234047) which is a very good starting point, but it has a problem with the path variables used and TAB completion in mercurial seems broken after.

This is how I installed and I have both working now. First you will need to download the two repositorios to My Documents\WindowsPowerShell\Modules\ and then in My Documents\WindowsPowerShell add a file named profile.ps1 with the following content:

{% highlight bash %}
function isCurrentDirectoryARepository($type) {

    if ((Test-Path $type) -eq $TRUE) {
        return $TRUE
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/' + $type;
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }
    return $FALSE
}

# Posh-Hg and Posh-git prompt

. $Home\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1
. $Home\Documents\WindowsPowerShell\Modules\posh-hg\profile.example.ps1

function prompt(){
    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd) -nonewline

    if (isCurrentDirectoryARepository(".git")) {
        # Git Prompt
        $Global:GitStatus = Get-GitStatus
        Write-GitStatus $GitStatus
    } elseif (isCurrentDirectoryARepository(".hg")) {
        # Mercurial Prompt
        $Global:HgStatus = Get-HgStatus
        Write-HgStatus $HgStatus
    }

    return "> "
}
{% endhighlight %} 