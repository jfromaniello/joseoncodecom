---
layout: post
title: "How I use Jing to add screenshots in markdown"
date: 2011-12-09 00:35
tags: 
- jekyll
---

Since I started to use Jekyll for this blog, one of the things that I miss was the way I was "pasting" screenshots in my posts: 

* Take a screenshot with [Jing](http://www.techsmith.com/jing.html)
* Save it locally
* Insert it in the blog post (with Windows live writer)

The first posts that I wrote in markdown, I did something crazy: I uploaded the file using filezilla to my old ftp and then figure out what was the url to that image, and then the markdown syntax.

Now, Jing has a very handy option to add a new button, first I went to Preferences and then to Customize Buttons:

![2011-12-09_0047.png](https://s3.amazonaws.com/joseoncode.com/img/2011-12-09_0047.png)

Next I added a new button with these settings:

![2011-12-09_0050.png](https://s3.amazonaws.com/joseoncode.com/img/2011-12-09_0050.png)

1. Button type: FTP
2. My FTP settings connection settings
3. After the screenshot is uploaded, I want the piece of markdown in my clipboard ready to paste. This include the markdown syntax with the full url to the image. 


And now I can take a screenshot with a key combination, then click a button and get the markdown code ready to paste! I think is even easier than with the old WLW :).