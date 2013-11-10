---
layout: post
title: "The Architecture we use to Deploy to Public and Private Clouds"
date: 2013-09-13 11:48
tags: 
- puppet
- git
- continuous delivery
---

> Originally posted on <a href="http://inside.auth0.com/2013/09/13/shiping-auth0/" rel="canonical">inside.auth0.com</a>.

> How we use Puppet, GitHub, TeamCity, Windows Azure, Amazon EC2 and Route53 to ship Auth0


## Introduction

There are two ways companies deploys web applications to the cloud: PaaS and IaaS. With [Platform as a Service](http://en.wikipedia.org/wiki/Platform_as_a_service) you usually deploy your applications to the vendor's platform. [Infrastructure as a Service](http://en.wikipedia.org/wiki/Infrastructure_as_a_service#Infrastructure_as_a_service_.28IaaS.29) is the basic cloud-service model: you get servers, usually vms.

We started auth0 using [Heroku](http://heroku.com)'s Platform as a Service but soon we decided to provide a self-hosted option of Auth0 for some customers. In addition, we wanted to have the same deployment mechanism for the cloud/public version and the appliance version. So, we decided to move to IaaS.

What I am going to show here is the work after several iterations at a very high level. It is not a silver bullet and you probably don't need this (yet?) but it is another option to consider. Even if this is exactly what you are looking for, the best advice I can give you "don't architect everything from start", this come from the work of several weeks and took several iterations but __we never ceased to ship__, everything evolved and keeps evolving, and we keep tuning the process a lot on the run. 



## The big picture

![](https://s3.amazonaws.com/joseoncode.com/img/2013-08-25_1458.png)

## What's Puppet and why is so important when using IaaS?

Picture yourself deploying your application to your brand new vm today. What is the first thing you will do? Well, if you have a node.js application installing node will be a good start. But probably you will need to install 10 other things as well, and changing the famous [ulimit](https://www.google.com/search?q=nodejs+ulimit&oq=nodejs+ulimit&aqs=chrome..69i57j0l2.2293j0&sourceid=chrome&ie=UTF-8), configuring logrotate, ntp and so on. Then you will copy your application somewhere in the disk and configure it as a service and so on. Where do you keep this recipe?

[Puppet](http://docs.puppetlabs.com/) is a tool for [configuration management](http://en.wikipedia.org/wiki/Configuration_management). Rather than an install script you describe at a high level the state of the resources in the server. When you run puppet it will check everything and then it will do whatever it takes to put the server in that specific state, from removing a file to installing a software.

There is another tool similar to puppet called [chef](http://www.opscode.com/chef/). One of the things regarding Chef that I would like to test in the future is [Amazon OpsWorks](http://aws.amazon.com/en/opsworks). 

After you have your configuration in a language like this, deploying to a new server is very easy. Sometimes I modify the configuration via ssh to test and then I update my puppet scripts. 

There is another concept emerging called [InmutableServers](http://martinfowler.com/bliki/ImmutableServer.html), it is a very interesting way and there seems to be some companies using it.

## Sources and repositories

Auth0 is very modularized and it is not a single web application but a network of less than ten. Every web application is a node application. Our __core__ is a web app without ui which handles the authentication flows and provide a rest interface, __dashboard__ is another web application which is just an interface to our __core__ where you can configure and test most of the settings, __docs__ is another app full of markdown tutorials to name a few.

We use github private repositories because we already had a lot of things opensourced there.

We use branches to develop new features and when it is ready we merge to master. Master is always deployable. We took some of the concepts from a talk we saw; "[How Github uses Github to build Github](http://zachholman.com/talk/how-github-uses-github-to-build-github/)". When something is ready? is a tricky question but we are very responsible and self organized team, we do pull-requests _from branch to master_ when we want the approval of our peers. Teamcity automatically run all tests and will mark the pull requests as OK, this is a very useful feature of TC. But the most important thing we do in this stage are code reviews.

Very often we send a branch to one of our 4 tests environments with our [hubot](https://github.com/github/hubot) (a personal bot on the chat room):

![](https://s3.amazonaws.com/joseoncode.com/img/2013-08-25_1622.png)

-  __ui__ is our dashboard application
-  __template-scripts__ was a branch
-  __proto__ is the name of te environment

with that in place we can review a living instance of the branch in a environment similar to production.

Then we iterate until we finally merge.

This is what works for us now, anyone of the team can merge or push directly to master and we consciously decide when we should do the pull-request ceremony.

## Continuous integration

We used [Jenkins](http://jenkins-ci.org/) for six months but it failed a lot, I had to rebuild few of the plugins we were using. Then I had a short fantasy to build our own CI server but we choose [teamcity](http://www.jetbrains.com/teamcity/) since I had use it before, I knew how to set it up and it is a good product.

Every application is a project in teamcity, when we push to master teamcity does:

1.  pull the repository
2.  install the dependencies (in some repos node\_modules versioned)
3.  run all the tests
4.  bundle node dependencies with [carlos8f/bundle-deps](http://github.com/carlos8f/bundle-deps)
5.  bump package version
6.  npm pack

1,2,3 are very common even in non-node.js projects. In the 4th step what we do is to move all "dependencies" to "bundleDependencies" in the package.json by doing this, the `npm pack` will contain all the modules already preinstalled. The result of the task is the tgz generated by `npm pack`.

This will automatically trigger the next task called "__configuration__". This taks pull our configuration repository written in puppet and all the puppet sub modules, then it will take the last version of every node project and build one ".tgz" for every "site" we have in puppet. We have several "site"  implementations like:

-  __myauth0__ used to create a quick appliance
-  __auth0__ the cloud version you see in app.auth0.com. It is very different from the previous one, for instance it will not install mongodb since we use MongoLab in the cloud deployment.
-  __some-customer__ some customers need some specific settings or features, so we have configurations with our customers name.

The artifact of the _configuration task_ is a tgz with all puppet modules including auth0 and the site.pp. All the packages are uploaded to Azure Blob storage in this stage.

The next task called "__cloud deploy__" in the CI pipeline will trigger immediately after the config task, it updates the puppetmaster (currently in the same CI server) and then runs the puppet agent in every node of our load balanced stack via ssh. After it deploys to the first node it does a quick test of the node and if there is something wrong it stop it and it will not deploy to the rest of the nodes. Azure load balancer then will take the node out of rotation until we fix the problem in the next push.

We have a backup environment where we continuously deploy, it is on Amazon and in a different region. It has a clone of our database (max 1h stale). This node node is used in case that azure us-east has an outage or something like that, when this happens [Route53](http://aws.amazon.com/en/route53/) will redirect the traffic to the backup environment. We take high availability seriously, read more [here](http://www.auth0.com/trust). When running in backup mode, all the settings become read-only, this means that you can't change the properties of an Identity Provider however your users will be able to login to your application which is Auth0 critical mission.

Adding a new server to our infrastructure take very few steps:

-  create the node
-  run an small script that installs and configure puppetagent
-  approve the node in the puppetmaster

Assembling an appliance for a customer is very easy as well, we run an script that install puppetmaster in the vm, download the last config from the blob storage and run it. We use [Ubuntu JeOS](http://es.wikipedia.org/wiki/JeOS) in this case.

## Final thoughts

I've to skip a lot of details to make this article concise. I hope you find it useful, if there is something you will like to know regarding this don't hesitate to put your question in a comment.
