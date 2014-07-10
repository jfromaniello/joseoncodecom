---
layout: post
title: "Activation links with Hawk"
date: 2013-05-22 08:44
tags:
- node
- hawk
---

If you ever wrote a Sign-up form I am sure you have faced this use case where you have  to generate an activation link to confirm the email account of the new user. One of the most common solutions is to generate a random-unique identifier and save it to the database.

In this post I will show how to generate a secure link using [Hawk](https://github.com/hueniverse/hawk).

> Hawk is an HTTP authentication scheme using a [message authentication code (MAC)](http://en.wikipedia.org/wiki/Message_authentication_code) algorithm to provide partial HTTP request cryptographic verification.

Hawk allows the MAC to be in a host header or a query string parameter. We will use this last feature know as "bewit".

The basic idea is that Hawk can generate a MAC for a url including every part of the url this is its protocol, host, port, path, query and then can validate if a MAC is valid for that particular url. MAC are generated with a private key.

Imagine we have already saved the user profile with an ```active: false``` flag, now we want to send the activation link, we can call this little module to generate the link:

```
var hawk    = require('hawk');
var urljoin = require('urljoin');

var credentials = {
  id: 'l',
  key: 'my super secret key',
  algorithm: 'sha256'
};


function getActivationLink (user) {
  var url = urljoin(process.env.BASE_URL, '/activate?user=' + user.email);

  var bewit = hawk.uri.getBewit(url, {
    credentials: credentials,
    ttlSec:      60 * 5
  });

  return url + '&bewit=' + bewit;
}
```

I've used [url-join](https://github.com/jfromaniello/url-join) to join a BASE_URL environment variable with the path of the activation endpoint. Another thing to notice is that this MAC will be valid just for the next 5 minutes after generated the link.

The resulting link will look like this ```http://mysuperapp.com/activate?user=foo@bar.com&bewit=H3424HFSDKJ4FDS```.

The next step is to handle the activation endpoint. If we are using Express we can have a middleware like this:


```
var hawk    = require('hawk');

var credentials = {
  id: 'l',
  key: 'my super secret key',
  algorithm: 'sha256'
};

function credentialsFunc (id, callback) {
  return callback(null, credentials);
};

function validateMac (req, res, next) {
  hawk.uri.authenticate(req, credentialsFunc, {}, function (err, credentials, attributes) {
    if (err) return res.send(401);
    next();
  });
}

module.exports = validateMac
```


And then the activation endpoint will look like this:

```
app.get('/activate', validateMac, function (req, res) {
  //this get called only if the mac is valid
  //save in the database that req.query.user is an active user.
});
```

This is all, the benefits of this technique:

-  no need to query the database when activating the user.
-  no need to store another secret in the database.

Do not trust randomness, cryptography is your friend.