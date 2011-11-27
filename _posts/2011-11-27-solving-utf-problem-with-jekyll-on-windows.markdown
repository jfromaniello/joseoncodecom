---
layout: post
title: "Solving UTF problem with Jekyll on Windows"
date: 2011-11-27 10:48
tags: 
- jekyll
- ruby
---

As I mention before I am running this blog with Jekyll. 
I noticed a problem while trying to execute the blog from windows:

	Liquid Exception: incompatible character encodings: UTF-8 and IBM437 in index.html

After further investigation I found that this problem means that the console you are trying to run ruby doesn't work with UTF characters ( ? ).
The way you can fix this is to set the code-page before running the jekyll command, simple execute this:

	chcp 65001

Beaware that I tried to set this globally by changing a registry key, and I broke my windows installation... seems that 65001 is not something that you can use globally, so don't do it.

Instead I added a new rake task as follows:

	task :runwindows do
		puts '* Changing the codepage'
		`chcp 65001`
		puts '* Running Jekyll'
		`jekyll --server --auto`
	end
	
and now I can execute jekyll with:

	rake runwindows