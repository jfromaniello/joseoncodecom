---
layout: post
title: "SinonJs: mocks for javascript"
date: 2012-01-18 07:58
tags:
- javascript
- tdd 
---

[Sinon.Js](http://sinonjs.org/) is a mock/stub/spy framework created by [Christian Johansen](http://cjohansen.no/) author of the book [Test-Driven Javascript Development ](http://www.amazon.com/dp/0321683919/).
It has a very handy syntax once you get used and some really useful features.


Do I need a mock framework in javascript?
=========================================

Since javascript is a dynamic language and weak typed language a newcomer might don't feel the need of a mock framework for javascript. For instance if I can write a test like this:

{% highlight javascript %}
test("when clicking the loadMore button then block the ui", function() {
    var called, message;
    $.blockUI = function(msg){
        called = true;
        message = msg;
    }

    $(".load-more").click();

    ok(called);
    equal(message, "Loading more tweets...");
});
{% endhighlight %}

Here, I replaced the $.blockUI method with a new method that stores two things; if the method was called and the message. And it will work but it has a problem since we are completely overwriting the method I am changing the environment where all test run.

Sinon.JS has the concept of "sandbox". You can create as many mocks and stubs inside the sandbox, but onces you dispose the sandbox everything will be restored to the original state. I use a sandbox per unit test always.

So the previous test with sinon.js will look as:

{% highlight javascript %}
test("when clicking the loadMore button then block the ui", function() {
    var blockUI = this.stub($, "blockUI");

    $(".load-more").click();

    ok(blockUI.called);
    equal(blockUI.args[0][0], "Loading more tweets...");
});
{% endhighlight %}

Which will work like the previous one, but the main difference is after the test has finished $.blockUI will be restored. Here I am using the Sinon.Js-qunit integration, but in the main website of Sinon.Js there are some other .js files to integrated with some other test frameworks. I have seen some people using Sinon.Js in node.js as well.

Mock ajax calls
===============

Sinon.JS has a way to mock ajax calls (and it also follows the sandboxes rules). Here is an example test:

{% highlight javascript %}
test("when loading an empty inbox then show a message", function() {
    this.server.respondWith("/getLatestMails",
                            [200, { "Content-Type": "application/json" }, JSON.stringify([])]);
    
    jmail.inbox.loadPage();

    this.server.respond();

    $("div#inbox")
        .assertNotContains("li.mail", "it should contains a li.mail");

    $("div#inbox")
        .assertContainsText("The inbox is empty");
});
{% endhighlight %}

The first parameter in respondWith is the relative url, then an array with the status code result, headers and the body payload.

Stub method calls
=================

Often we need to stub a function and set the result values for different arguments, with sinon we can do something like this:

{% highlight javascript %}
test("when changing the hash to target=inbox then call the inbox.loadPage", function() {
    //arrange
    var getState = this.stub($.bbq, "getState"),
        jmailLoadPage = this.stub(jmail.inbox, "loadPage");

    getState.withArgs("target").returns("inbox");

    //act
    $(window).triggerHandler("hashchange");

    //assert
    ok(jmailLoadPage.called);
});
{% endhighlight %}

When calling $.bbq.getState("target") it will returns "inbox". You can set as many withArgs/returns as you want. 

Using Mocks
===========

According to Sinon.Js documentation, 
    
> Mocks (and mock expectations) are fake methods (like spies) with pre-programmed behavior (like stubs) as well as pre-programmed expectations. A mock will fail your test if it is not used as expected. 

In an example before I shown the usage of called and args in stubs. We can set the expectation upfront (instead of asserting after the fact)  as follows:

{% highlight javascript %}
test("when clicking the loadMore button then block the ui", function() {
    var $mock = this.mock($);

    $mock.expects("blockUI")
         .once()
         .withArgs("Loading more tweets...");

    $(".load-more").click();

});
{% endhighlight %}

After the test is finished (and the sandbox disposed) if we didn't fulfill the expectation the test will fail.

I don't know why but I vaguely use this method, I prefer sinon.js stubs.

Test Spies
==========

Spy objects works as stubs but the only difference is that the underlying method is called normally. To use this, instead of this.stub you will use this.spy.

Another useful usage of spy is when you want to test how a method will use a callback. An example of this (from sinon docs) is:

{% highlight javascript %}
"test should call subscribers on publish": function () {
    var callback = sinon.spy();
    PubSub.subscribe("message", callback);

    PubSub.publishSync("message");

    assertTrue(callback.called);
} 
{% endhighlight %}

As you can see here we are creating an spy without args.

About the QUnit Integration
===========================

In the Sinon.Js main page there is a [sinon-qunit adapter](http://sinonjs.org/qunit/). Unfortunately we found some problems with it, I think it was something with async tests. 

So, [Gustavo Machado](http://machadogj.com) and I wrote a new adapter for qunit based on the module setup/teardown of qunit. I already published this file in my JMail repository so you can download it [here](https://github.com/jfromaniello/jmail/blob/master/scripts/Tests/sinon-qunit-1.0.0.js). There is only one drawback with this method and is that you need to set a qunit "module" for your tests.

Final thoughts
==============

Sinon.Js is a must-have when doing TDD in javascript and I haven't found any other alternative. The documentation of Sinon.Js is very clear and easy to follow.

Most of the examples in this blog post are from my Singe Page Application example called [Jmail](https://github.com/jfromaniello/jmail/).