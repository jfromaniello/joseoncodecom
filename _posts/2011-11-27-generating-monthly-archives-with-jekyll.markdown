---
layout: post
title: "Generating monthly archives with Jekyll"
date: 2011-11-27 21:23
tags: 
- jekyll
---

Continuing my series of posts about Jekyll I will show in this post how to generate monthly archives.
This is the index you see when you enter this url:

	http://joseoncode.com/2011/11

The difference between Jekyll and any other blog system is that Jekyll generate the site at build time, while the others generate the page at runtime with data coming from a database.

The first thing you will need is a jekyll plugin in the "_plugins" folder as follow:

{% highlight ruby %}
module Jekyll
  class ArchiveIndex < Page
    def initialize(site, base, dir, period, posts)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'archive_index.html')
      self.data['period'] = period
      self.data['period_posts'] = posts
      archive_title_prefix = site.config['archive_title_prefix'] || 'Archive: &ldquo;'
      archive_title_suffix = site.config['archive_title_suffix'] || '&rdquo;'
      self.data['title'] = "#{archive_title_prefix}#{period["month"]}-#{period["year"]}#{archive_title_suffix}"
    end
  end
  class ArchiveGenerator < Generator
    safe true
    def generate(site)
      if site.layouts.key? 'archive_index'
        site.posts.group_by{ |c| {"month" => c.date.month, "year" => c.date.year} }.each do |period, posts|
          archive_dir = File.join(period["year"].to_s(), "%02d" % period["month"].to_s())
          write_archive_index(site, archive_dir, period, posts)
        end
      end
    end
    def write_archive_index(site, dir, period, posts)
      index = ArchiveIndex.new(site, site.source, dir, period, posts)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end
  end
end
{% endhighlight %}

Shame on me!! please pardon my ruby skills.

This will generate an html file index.html in the folder /YYYY/MM.

And then in the "layout" folder I wrote a template for this archive_index.html (you can set another name in _config.yml):

{% highlight html %}
---
layout: default
meta-robots: "noodp, noydir, noindex, noarchive, follow"
---

<h1> Posts archive: \{\{ page.period["month"] \}\} - \{\{page.period["year"]\}\} </h1><br>
<ul>
{\% for post in page.period_posts \%}
<li> 
	<a href="{{post.url}}">\{\{ post.title \}\}</a><br>
	<span class="entry-meta">Published: \{\{ post.date | date: "%B %d, %Y" \}\}</span>
</li>
{\% endfor \%}
</ul>
{% endhighlight %}
