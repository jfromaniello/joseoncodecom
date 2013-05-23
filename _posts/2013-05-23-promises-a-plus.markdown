---
layout: post
title: "Promises A+ and the Q library"
date: 2013-05-23 08:04
tags: 
---

Two years ago I published a blog post about [jQuery promises](http://joseoncode.com/2011/09/26/a-walkthrough-jquery-deferred-and-promise/) I have got lot of feedback since then but even if this still valid for jQuery I want to drag focus to the great job some of the javascript gurus are doing.

The important specification here is [__Promises A+__](http://promises-aplus.github.io/promises-spec/)

![promisesalogo](https://rawgithub.com/promises-aplus/promises-spec/master/logo.svg) 

The specification is very short, readable and useful. Go read it.

There are several frameworks and libraries that follow this specification and this is a __GOOD__ thing, because it means that you can pass a promise from some library to other one and everyone speak the same interface.

### So, what's a promise again? 

> A promise represents a value that may not be available yet. 

There is another definition I heard that I like a lot:

> A promise is an asynchronous value.

If you have done any javascript you know that when you need to call an asynchronous function you have to pass a ```callback``` which is a function that will be called after it finish doing its job. So, the function doesn't return anything and this make it harder to compose asynchronous code sometimes.

### The Q library

[__Q__](https://github.com/kriskowal/q) is a library that implements the standard and has some extra helpers. Q works in the browse and in node.js.

From now on, I will use Q to show some examples, but keep in mind that the very basic things are part of the Promise/A+ and Q adds some friendly helpers on top of that.

### Basic usage

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/xFFVn/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

In this first example I have called `Q.delay(2000)` this method returns a promise that will be _fulfilled_ after two seconds. _You can think of this method as a `setTimeout` that instead of having callback parameter it returns a promise._ 

Every promise has a ```then``` method that receive two arguments (or two callbacks) in order to access the fulfilled value and rejected value. Either callbacks could be null or undef.

### Chaining

```then``` returns a new promise, this allow __Promises A+__ to be _chained_

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/qdmgy/1/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

In this example I'm returning a value in the first callback this makes the returned promise to be fulfilled with that value (3.2.6.1 section in spec).

Because this is something you do a lot, Q promises have a helper ```thenResolve```:

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/cyqU7/2/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

The most interesting thing about chaining promises is that you can _serialize_ work:


<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/mnNae/2/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

In this example we first get the user with ```getUser``` and then we get his tweets ```getTweets```. The result of ```then(getTweets)``` becomes a new promise that will be fullfiled when the two things are fulfilled and it will be fulfilled with tweets.

Can you read that thing __"getUser then getTweets then forEach tweet alert tweet message"__? This is important. We are working with asynchronous code in javascript yet the code is still very readable and easy to compose.


### Deferred

At this point we have used only the promise returned from the delay method. Another way to create promises is using ```Q.defer```. A Defer has two important methods ```resolve``` and ```reject```, and it has a property ```promise```. It goes without saying that this is not part of the specification and different frameworks might have different ways to create deferred.

The ```delay``` method in Q could be implemented with defer as follows: 


<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/pUAJ5/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>


At the point I'm writing this jQuery promises are not compatible with Promises/A and Promises/A+, so an easy way to fix this is as follows:

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/xSU2G/2/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

### Parallelism

What if you need to do several asynchronous tasks that doens't depend on each other? Use ```Q.all```.

```Q.all``` converts an array of promises into a single promise that will be fulfilled when all the promises are fulfilled with an array of all the values or rejected with the first reason a promise is rejected.

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/FRRxM/3/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

in this example I'm calling getUsers three time for the three ids I have in the array. Then I wait the three promises to be fulfilled (this will happen after 1s aprox.) and then I show a message.

A more complex example here:

<iframe width="100%" height="300" src="http://jsfiddle.net/jfromaniello/FRRxM/4/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

In this case the ```spread``` method (from Q- not standard) works like ```then``` but "spread" all the values in arguments thus we can give the mergeProfiles function directly.

### Error throwing and handling in asynchronous code

Another interesting thing about promises is error handling. In node.js land it happens a lot that you end with a code like this:

```
doFoo(function (err, r1) {
  if (err) return handleError(err);

  doBar(r1, function (err, r2) {
    if (err) return handleError(err);

    doBaz(r2, function (err, r3) {
      if (err) return handleError(err);

      callback(r3);
    });

  });
});
```
I want you to notice the this line three times:

```
if (err) return handleError(err)
```

With promises you can write this same code as follows:

```
doFoo()
  .then(doBar)
  .then(doBaz)
  .then(null, handleError);
```

Because the two first ```then``` calls doesn't have a onreject handler they will pass the rejection reason to the next promise until someone handles that error. More interesting if a promise is reject none of the fulfill handlers here will be called.

The other interesting thing about this is that if you throw an exception inside a then call the promise will be rejected.

### node.js

node.js api and modules follow a convention for asynchronous code, functions usually have callback parameter as the very last parameter and this callback get called with error and value.

So, Q make it easy to convert this style to promises as follows:

```
var Q = require('q');
var readdir = Q.nfbind(require('fs').readdir);

//usage
readdir('./path')
  .then(function (files) {

  }, function (err) {

  });
```

This nfbind method has an alias ```denodeify``` if that makes it easier to remember.

There are lot more helpers but one interesting is ```nodeify```. Do you feel shame letting the world know that you use promises and want to expose an standard-old node.js api? Use nodeify:

```
module.exports = function (callback) {
  mysuperpromise()
    .then(blabla)
    .nodeify(callback); 
};
```

### Tests

This is not that important but it is something I found and I like a lot. When writing unit tests against asynchronous code, typically you do something like this:

```
function test (done) {
  getSomething(function (err, result) {
    if (err) return done(err);
    Assert.areEqual(result, 123);
    done();
  });
}
```

As I cited before "promises are asynchronous values". What if the assert and test framework could handle promises as well? You could easily write something like this:

```
function test () {
  return getSomething().should.eventually.equal(123);
}
```

This is already done and you can use it today, have a look to [chai-as-promised](https://github.com/domenic/chai-as-promised).

### More material

Watch this video:

<iframe width="560" height="315" src="http://www.youtube.com/embed/hf1T_AONQJU" frameborder="0" allowfullscreen></iframe>

Follow [@domenic](https://twitter.com/domenic).

Read [his blogpost](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/).

[Q Api Reference](https://github.com/kriskowal/q/wiki/API-Reference) is very helpful.

### Conclusion

Promises are the future (of JavaScript asynchronous code). I put JavaScript there because I am sure some people are working on _better_ languages with better syntax for asynchronous flows but that doesn't feel is going to change in the short term for javascript.
