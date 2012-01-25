---
layout: post
title: "Hide passed tests by default in Qunit"
date: 2012-01-25 14:37
tags: 
- tdd
- javascript
- qunit
---

If you are using qunit and you are tired of the 392019321 passed tests output in your browser, there is a checkbox at the top to hide all passed tests. Unfortunately after you refresh the page you will lose this. 

Don't worry I have a snippet for you, insert this at the botton of your test harness page (inside a script block):

{% highlight javascript %}
$(document)
    .ready(function(){
        $('#qunit-tests').addClass('hidepass');
    })
    .delegate("#qunit-testrunner-toolbar", "DOMNodeInserted", function(e){
        $("#qunit-filter-pass").attr("checked", true)   
    })
    .delegate("#qunit-filter-pass", "click", function(e){
        e.stopPropagation();
        var newValue = $(this).is(":checked");
        $('#qunit-tests').toggleClass('hidepass', newValue);
    });
{% endhighlight %}
