---
layout: post
title: "A frecuent case of double callbacks in node.js"
date: 2013-12-27 08:06
tags:
- node
---

A double-callback is in javascript hargon a callback that we expect to be called once but for some reason is called twice or more times.

Sometimes it is easy to discover, as in this example:

```
function doSomething(callback) {
  doAnotherThing(function (err) {
    if (err) callback(err);
    callback(null, result);
  });
}
```

The obvious error here is that when `doAnotherThing` fails the callback is called once with the error, and once with result.

However there is one special case that is very hard to reproduce and to discover, moreover it has happened to me several times.

Yesterday, my friend and co-worker [Alberto](https://twitter.com/thepose) asked me this:

> "Why does this test hangs on the __assertion__ line?"
> expect(foo).to.be.equal('123');

The test look like this

```
it('test something', function (done) {
  function_under_test(function (err, output) {
    expect(foo).to.be.equal('123');
  });
});
```

After some debugging I found out that it didn't hang only on expect but when we throw any error inside the callback.

A bunch of calls before in the stack, there was a little function with a bug like this:

```
function (callback) {
  another_function(function (err, some_data) {
    if (err) return callback(err);
    try {
      callback(null, JSON.parse(some_data));
    } catch(err) {
      callback(new Error(some_data + ' is not a valid JSON'));
    }
  });
}
```

The intention of the developer with this try method is clear: to catch JSON.parse errors. But the problem is that it also catch errors thrown __inside callback__ and execute the callback with a wrong error.

The solution is trivial, parse outside the try as follows:

```
function (callback) {
  another_function(function (err, some_data) {
    if (err) return callback(err);
    try {
      var parsed = JSON.parse(some_data)
    } catch(err) {
      return callback(new Error(some_data + ' is not a valid JSON'));
    }
    callback(null, parsed);
  });
}
```

Introducing these errors is very easy I've done several times, throubleshooting is very hard, so be careful and do not wrap callbacks call in try/catch blocks.