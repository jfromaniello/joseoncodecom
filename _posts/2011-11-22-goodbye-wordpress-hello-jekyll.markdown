--- 
layout: post
title: "Goodbye Wordpress, Hello Jekyll!"
tags: 
- ruby
- jekyll
type: post
---

From now on this blog is running with [Jekyll](https://github.com/mojombo/jekyll)!
What is jekyll?
===============

Jekyll is a simple, blog aware, static site generator. 

In short; I write my blogposts in [markdown](http://daringfireball.net/projects/markdown/) files and when I publish jekyll generate all the blog, which means not only the blogpost page but also the archives and by-tags indexes.

The result is an incredible performance because instead of doing database calls to some backend and rendering the pages server side, the web server already has the static content to serve.


Yeah, but Wordpress has WPSuperCache
====================================

I know but configuring is not that easy, and on the other hand performance was not the only thing I was look with Jekyll. 

The other thing that I was looking for is that I feel that I don't have control over wordpress. I can't understand the structure of the pages thru the different php files. Why? because wordpress is more than a blogengine is a multipurpose CMS so the inner details are very complex to my understanding.

The other thing that I love is that I can use a text editor to write a blog post (now I am using [Sublime Text 2](http://sublimetext.com/2) which I love ) and publish to heroku with a simple git push.

How to start?
=============

Well, starting a blog with Jekyll might not be that easy, what I did was to clone anothe repository, delete the posts directory and start tweaking it.

I clone [Johnny Halife](http://johnny.io) repository to start, just because I was talking with him on twitter about Jekyll and he helped me.

You can read in Johnny's blog [how to get started](http://johnny.io/2011/11/18/Jekyll-is-rocking-my-new-blog/).

My modifications
================

I did some modifications in my clone:

* I am [running ejekyll](http://rfelix.com/2010/01/19/jekyll-extensions-minus-equal-pain/) which is a wrapper arround jekyll that allows me to use some extensions.
* I use a tag_gen.rb plugin from [kismetik](http://www.kismetik.com/), to generate a page per tag. Which is an index, so you can open http://joseoncode.com/tag/wpf. The pluggin is [here](https://github.com/jfromaniello/joseoncodecom/blob/master/_plugins/tag_gen.rb).
* I wrote an [archive_gen.rb](https://github.com/jfromaniello/joseoncodecom/blob/master/_plugins/archive_gen.rb) inspired in the tag_gen.rb to generate an index per month which is accessible thru http://joseoncode.com/2011/07 for instance.
* I wrote an ejekyll extension, which replace the pygments rendering stuff in jekyll with a pygments version hosted in the cloud that I can access with http. I did this because I couldn't install pygments on heroku because it is python.
* I added the [tag_category_iterator.rb](https://github.com/jfromaniello/joseoncodecom/blob/master/_extensions/tag_category_iterator/tag_category_iterator.rb) ejekyll extension. This extension is an slightly modified version from kismetik. What it does is to add three properties to the "site" template data tags, categories and archives. I used this thing to generate the drop down selectors at the right of this page.
* I added a [search page](https://github.com/jfromaniello/joseoncodecom/blob/master/search.html) which uses a [Custom Google Search](www.google.com/cse) engine. So, I can call the page with http://joseoncode.com/search?q=TDD and it works.
* I have also added an Open Search Description to the [default layout](https://github.com/jfromaniello/joseoncodecom/blob/master/_layouts/default.html#L30) and the description document is [here](https://github.com/jfromaniello/joseoncodecom/blob/master/osd.xml). This is a nice feature if you are using Chrome for instance, the first time that you got to my blog, Chrome will grab the search engine. Suppose that while you were working you remember something on my blog, you can go to the address bar and type "joseoncode.com" then [TAB], then a *search criteria* and finally enter.

If you like these four things, you can clon [my repository](https://github.com/jfromaniello/joseoncodecom) or simple copy the files.

And that's all I hope I haven't messed up the rss thingy :). 
