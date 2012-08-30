---
layout: post
title: "Share server-side templates with the browser using AMD"
date: 2012-08-30 10:04
tags: 
- node.js
- javascript
---

In this post I will show you how you can share pre-compiled templates that you use in the server to the client-side JavaScript.

Imagine that you have to show a list of products in a web page. You can render this in the server-side but then.. you need also to have the option to add new products in the same page, create it using ajax and add the new item to the same list without rendering the page again.

Instead of having two separated templates and having to maintain both you can have only one. 

Most of the JavaScript template engines works in two steps:

- first you have to compile the template
- then you pass to the compiled template the data to render the thing

In this process of compilation, most of the template engines generate a plain JavaScript function. 

For this example I will use [Jade](http://jade-lang.com).

Our server side template might look like this product-line.js:

{% highlight text %}
  tr 
    td #{name}
    td #{price}
{% endhighlight %}

So, we include this on a web page as follows:

{% highlight text %}
doctype 5
html(lang="en")
  head
    title product list demo
  body
    h1 Products
    .current-products
      h2 Current Products
      table#product-list
        thead
          tr
            th name
            th price
        tbody
          each product in products
            name = product.name
            price = product.price
            include includes/product-line

{% endhighlight %}

# sharing the template to the client side

Now, we want to share with the browser the compiled template for the product. We can use different ways, in fact it is very easy to compile with jade in the server like:

{% highlight javascript %}
var jade = require("jade"),
    compilerOptions = { 
      client: true, 
      debug: false, 
      pretty: true 
    };

var myCompiledTemplate = jade("template string", compilerOptions).toString();
{% endhighlight %}

but what I like most is to use the [Asynchronous Module Definition](https://github.com/amdjs/amdjs-api/wiki/AMD). 

# enter jade-amd

I was planning to create a module for this, but I found [this one](https://github.com/mysociety/node-jade-amd). The module works in two different ways:

* you can call it as a command line program (most likely for production)
* you can use it as an express middleware (most likely during development)

what it does is to compile a jade template (using jade) and then transform it to AMD. We can use the middleware as follows:

{% highlight javascript %}
app.configure("development", function(){
  var jadeAmd = require('jade-amd');
  app.use("/templates", jadeAmd.jadeAmdMiddleware({
    views: path.join(__dirname, 'views/includes'),
    jadeRuntime: "jade-runtime"
  }));
});
{% endhighlight %}

Another thing that you will need besides the compiled function, is to have jade in the browser. You have two options to add jade as it is, or you dont plan to *compile* jade templates in the browser you can just use the jade-runtime which is smaller.

For this example, I have installed two [jam](http://jamjs.org) packages:

* [jade-runtime](http://jamjs.org/packages/#/details/jade-runtime)
* [zq](http://jamjs.org/packages/#/details/zq): a combination of three modules for dom manipulation with a syntax similar to jquery.

Next thing we can do is to modify our page to this:


{% highlight text %}
doctype 5
html(lang="en")
  head
    title product list demo
    script(src="/jam/require.js", data-main="main.js")
  body
    h1 Products
    .current-products
      h2 Current Products
      table#product-list
        thead
          tr
            th name
            th price
        tbody
          each product in products
            name = product.name
            price = product.price
            include includes/product-line

    .create-product
      h2 Create a new product
      input(id="product-name", type="text", placeholder="product name") 
      input(id="product-price", type="text", placeholder="product price") 
      input(id="create-product", type="button", value="create") 

{% endhighlight %}

note the usage of require.js (comes with jam) and the data-main attribute. Our main.js looks as follows:

{% highlight javascript %}
require(["zq", "/templates/product-line.js"], function($, prodTemplate){
  $("#create-product").on("click", function(e){
    e.preventDefault();
    var newProduct = {
          name: $("#product-name").val(),
          price: $("#product-price").val()
        },
        productHtml = prodTemplate(newProduct);

    $("#product-list tbody")
      .append($.create(productHtml));
  });
});
{% endhighlight %}

This works as expected, and if you look at the network tab in the developers tools of your browser you will see this:

![2012-08-30_1231.png](http://joseoncodecom.ipage.com/wp-content/uploads/images/2012-08-30_1231.png)

notice the main.js, the product-line.js, jade.runtime.js, zq.js and the dependencies of zq.

# going to production

Now, suppose that we are going to production. I would like to build with jam-requirejs, a single mimified file with everything inside even the templates for this particular page.

So, what I did is to create an script in javascript:


{% highlight javascript %}
var exec = require("child_process").exec,
    path = require("path"),
    async = require("async");

function executeCommand(command, callback){
    var childProc = exec(command, {}, callback || function(){});
    childProc.stdout.pipe(process.stdout);
    childProc.stderr.pipe(process.stderr);
}

var tasks = [
    "jam install"
  ];

if(process.env.NODE_ENV === "production"){
  //compile the templates into template.js files
  tasks.push("jade-amd --from views/includes/ --to public/templates -r jade-runtime");
  
  //generate your one file application script
  tasks.push("jam compile -i main.js -o public/jam/require.js --almond");
  
  //remove the templates folder
  tasks.push("rm -rf public/templates");
}

async.series(tasks.map(function(t){
  return executeCommand.bind(this, t);
}));
{% endhighlight %}

This is script not only install jam dependencies from the package.json of this application, but also build the templates to file and compile jam if your NODE_ENV is production.

This is a postinstall script in my package.json:

{% highlight javascript %}
  "scripts": {
    "postinstall": "node postinstall.js"
  }
{% endhighlight %}

when you are in production, everything is inside the require.js file, even the templates and you don't have to change anything on the html side. The result is this:

![2012-08-30_1407.png](http://joseoncodecom.ipage.com/wp-content/uploads/images/2012-08-30_1407.png)

The code for this example is hosted in [github](http://github.com/jfromaniello/tedemo).