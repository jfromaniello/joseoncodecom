---
layout: post
title: "Introducing mdocs.io"
date: 2013-02-28 20:04
tags: 
---

I would like to introduce a tool we have built to demo  [Auth0](http://auth0.com).

[mdocs.io](http://mdocs.io) is a free and [opensource](https://github.com/auth0/mdocs) tool to collaborative write documents. You can think of it like google docs with markdown. It uses the technique called operational transformation to allows users to edit a document simultaneously.

Every document is private at the beginning and you can easily share it to your peers or make it publicly available.

## How auth0 powers mdocs.io

Login with google through OAuth, select contacts, etc. is basic stuff and there are lot of tools to this kind of thing on every platform. You can use mdocs in _solo_ mode with your @gmail.com account.

But we wanted to use mdocs just as we use google docs, this means being able to share documents across the company or group of people. 

So, when you go to [mdocs.io](http://mdocs.io) you will see an option to connect mdocs to your company either by using __google apps__, __office365__ or __adfs__. In order to complete this process you will need to involve an admin of the domain. If you are no the admin, you can follow the procedure which is about 2 clicks and send the link at the end of the process to your admin.

After you have finished this process you can login with your account in [mdocs.io](http://mdocs.io) or you can bookmark a link like __http://mdocs.io/e/yourcompany.com__ in which case you will see a prompt of google like this:

![](https://s3.amazonaws.com/joseoncode.com/img/dump/2013-02-28_1941.png)

if your are not currently logged (or your adfs login, etc).

Then, you will be able to share documents to your company peers:


![](https://s3.amazonaws.com/joseoncode.com/img/dump/2013-02-28_1944.png)


## More details

mdocs.io is running on heroku and it uses mongodb thru [mongolab](http://mongolab.com) and elastic search with [bonsai.io](http://bonsai.io) (yes! searching documents works like a charm).

It also uses a JavaScript framework called [ot.js](https://github.com/Operational-Transformation) for the collaborative part. It is pretty interesting how that concept works, maybe I will expand about it in another post.

It has some powerful key shortcuts when you are editing a document.

It is built on node.js of course :).

## Final thoughts

We think that Auth0 open a lot of new possibilities and we really love mdocs.io, we use it to brainstorm ideas, to write articles, documentations and a lot of other things.

Since we are building this on the open, any pull request that we merge on the github repository will be immediately available on mdocs.io. So, if you feel like it could be better go ahead and help us :)

> If you want to learn more about Auth0 follow my upcoming articles on [blog.auth0.com](http://blog.auth0.com)