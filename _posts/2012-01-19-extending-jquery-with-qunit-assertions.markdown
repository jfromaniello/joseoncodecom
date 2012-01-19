---
layout: post
title: "Extending jQuery with QUnit assertions"
date: 2012-01-19 11:25
tags:
 - jquery
 - qunit
 - tdd 
---


QUnit come out of the box with some very basic assertions; ok, equal, notequal, deepequal, raises and few others.  In this post I will show how to extend the jQuery object with some useful assertions for qunit.

When I was working in [Moesion](http://www.moesion.com/) I saw that I was writing having many times test like this:

{% highlight javascript %}
test("some test", function() {
    //do something
    //mock ajax call

    $(".a-button").click();

    //assert
    ok($(".some-element", $(".container")).length > 0, 
        "it should contains some-element");
    
    ok($(".some-other-element", $(".container")).length > 0,
        "it should contains some-other-element");

    ok($(".container").is(":contains('some text')"),
        "it should contains 'some text'");
});
{% endhighlight %}
 

So, I wrote some extensions to the jquery object and now I can write the assertions like this:


{% highlight javascript %}
test("some test", function() {
    //do something
    //mock ajax call

    $(".a-button").click();

    //assert
    $(".container")
        .assertContains(".some-element")
        .assertContains(".some-other-element")
        .assertContainsText("some text");
});
{% endhighlight %}

The implementation is quite easy:


{% highlight javascript %}
(function( $ ){

  function escapeHtml(s) {
      if (!s) {
          return "";
      }
      s = s + "";
      return s.replace(/[\&"<>\\]/g, function(s) {
          switch(s) {
              case "&": return "&amp;";
              case "\\": return "\\\\";
              case '"': return '\"';
              case "<": return "&lt;";
              case ">": return "&gt;";
              default: return s;
          }
      }).replace(/(\r\n|\n|\r)/gm, "<br />");
  }

  function pushSelectorAssertToQunit(result, message, c
                                    ontent, expectedMessage, 
                                    expectedValue){
      QUnit.log({
            result: result,
            message: message,
            actual: content,
            expected: expectedMessage + " " + expectedValue
        });

      QUnit.config.current.assertions.push({
          result: !!result,
          message: message || ("<code><pre>" + escapeHtml(style_html(content)) 
                        + "</pre></code> <br /> <div class=\"test-expected\">" 
                        + expectedMessage + " " + expectedValue + "</div>")
      });  
  }

  $.fn.assertContains = function(selector, message) {
    pushSelectorAssertToQunit($(selector, this).length > 0, 
                        message, 
                        this.html(), 
                        "should contains", 
                        selector);
    return this;
  };

  $.fn.assertNotContains = function(selector, message) {
    pushSelectorAssertToQunit($(selector, this).length === 0, 
                        message, 
                        this.html(), 
                        "should not contains", 
                        selector);
    return this;
  };

  $.fn.assertContainsText = function(text, message) {
    pushSelectorAssertToQunit(this.is(":contains('" + text + "')"), 
                        message, 
                        this.html(), 
                        "should contains text", 
                        text);
    return this;
  };

  $.fn.assertNotContainsText = function(text, message) {
    pushSelectorAssertToQunit(!this.is(":contains('" + text + "')"), 
                        message, 
                        this.html(), 
                        "should not contains text", 
                        text);
    return this;
  };
})( jQuery );
{% endhighlight %}

There is only one dependency, the style_html function comes from [beutify_html.js](https://github.com/einars/js-beautify/blob/master/beautify-html.js). You can remove the function call, but it allows me to see beutiful errors when a test fail:

![2012-01-19_1147.png](http://joseoncodecom.ipage.com/wp-content/uploads/images/2012-01-19_1147.png)