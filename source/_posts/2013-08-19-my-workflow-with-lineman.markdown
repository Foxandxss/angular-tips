---
layout: post
title: "my workflow with lineman"
date: 2013-08-19 14:33
comments: true
categories: [workflow, beginners]
---

So, we decided to create a new Angular.js application. What should we do? Integrate our application into our backend? Pick an existing seed and extend it?

Here I want to explain **what** is my workflow and **why** I go through that route.

<!--more-->

Let's say that we want to use *Rails* as a backend (I pick *Rails* because is what I am most comfortable with, but this applies to any backend) and our first thought could be: Great, we just need to dump our Angular stuff into the *javascripts* folder. Well that is a solution that will work, but it contains some drawbacks in my opinion.

Rails' assets pipeline is good but it can be a pain in the ass when it gets in our way. I saw some projects where you need to use `.erb` extension to inject ruby code in our javascript, something like this:

```javascript
$routeProvider.when('/', {
	templateUrl: "<%= asset_path('templates/foo/bar.html') %>"
});
```

That works, but then we are coupling our Angular app with Rails and that is not good at all (and is ugly as hell). This turn really problematic if we want to use Angular-ui bootstrap in template-less mode because we would need to monkey patch the angular-ui's javascript file to load the templates like in the last snippet.

Of course this can be solved using `$templateCache` but for me sounds like a workaround because the coupling.

The other issue I have with the assets pipeline is that even when is powerful and easy to extend, there are not many custom tasks to facilitate our development like we have with `Grunt`.

On the other hand, we want to use a `CSRF token` and we know that we have one in our layout, so we can do something like this:

```javascript
$httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
```

That couples our app a little more with *Rails*.

The problem with this is that if we decide tomorrow that we don't want to use *Rails* anymore we have to "pick" our Angular.js app parts from different places and then build them into another backend opinion. That implies moving our files to different folders and modifying the parts we coupled with *Rails* stuff to match our new backend.

I like to see this like when we buy a hosting with a free domain. Someday we decide that we want a different hosting, but our domain is "coupled" with that hosting and we need to do several things to move that domain to a new place (I was asked once to pay $100 for my domain if I leave the hosting). This could be easily solved if we have our domains "decoupled" in a different place because we just need to point the DNS to a different place if we change our hosting.

The same applies to Angular. If we have our application decoupled from our backend, we can swap backends without having to touch any file or code from our Angular application.

## Enters Lineman.js

An Angular application is as important as our backend, AKA a `first-class` web application. To achieve this we have to decouple our application from any backend opinion. For this, we are going to create our Angular application as a different and independent project. How? With [Lineman.js](http://linemanjs.com)

`Lineman` is a thin layer on top of `Grunt` which comes with a bunch of helpful tasks to aid us on our development. For those who don't know what `Grunt` is, it is a task runner which provides us with a lot of tools to automate our repetitive tasks.

So, what can `Lineman` automate for us? Anything we want: Coffeescript compilation, javascript linting, sass/less compilation, run our tests, concat our javascript, minify and uglify them...

The best part of it? We don't have to do anything to get that running. `Lineman` is smartly configured to do all of those things by default for us, and if we need to modify something, that is easily done as well.

Since examples are better than words, let's check an example:

First, clone this repository:

```bash
$ git clone https://github.com/davemo/lineman-angular-template.git our-application
$ cd our-application
$ npm install
```

`Lineman` itself is a generic solution for any kind of application, but there are several templates for different projects that brings custom tasks. In this case we are using a template made by my friend [David Mosher](https://twitter.com/dmosher) which is absolutely awesome for Angular development.

If we open our project, we can see this folder:

{% img /images/posts/lineman/image1.png %}

That are the files to configure `Lineman`. As I said before, `Lineman` comes with predefined configuration, but we need to configure it for our needs. In this case, we have `Lineman` configured for Angular.

What extra things do we have with this template? Well, apart from the things I said before, here we have `grunt-angular-templates` that will cache every template we have in our application with `$templateCache` automagically for us, we also have `grunt-ngmin` that will add the [inline annotation](http://docs.angularjs.org/guide/di) needed to be able to mangle our uglyfied javacript, and even source maps!

All of this sounds good, but having our application decoupled from the backend, how can we make a request to a backend (which we don't have)? That is not a problem! `Lineman` comes with a fake backend were we can create some fake endpoints so we are able to develop our application without the need of a backend.

The fake backend is built in `Express.js` and looks like this:

```javascript /config/server.js
module.exports = {
  drawRoutes: function(app) {
    app.post('/login', function(req, res) {
      res.json({ message: 'logging in!' });
    });

    app.post('/logout', function(req, res) {
      res.json({ message: 'logging out!'});
    });

    app.get('/books', function (req, res) {
      res.json([
        {title: 'Great Expectations', author: 'Dickens'},
        {title: 'Foundation Series', author: 'Asimov'},
        {title: 'Treasure Island', author: 'Stephenson'}
      ]);
    });
  }
};
```

Here we see three fake endpoints that we can use in our development. This fake backend is **THAT** great that it even comes with `pushState` support (enabled by default). This configuration lies in `/config/server.js`

Alright alright, you got me, but what if I have a real backend running somewhere and I want to use it instead of a fake one? That's right, is not a problem either. If we open `config/application.js` we can do something like this:

```javascript /config/application
server: {
  pushState: true,
  apiProxy: {
    enabled: true,
    port: 3000,
    prefix: 'api'
  }
}
```

With this we enable a proxy to a real backend and we specify that it is running at port 3000. With the `prefix` we forward any request that contains `api` to the proxy. Now if we do a request to `/api/foo` it will go to our real backend. Nice!

Last, we have a configuration file for our `e2e` tests (More on this later).

That is all for the configuration. Thanks to the amazing job of the `Lineman` team, we don't need to touch almost anything to make everything work.

We also have a folder for our application itself:

{% img /images/posts/lineman/image2.png %}

The folders are self-descriptive with the exception of the `pages` one. Here we have our `index.us` page which we will use to generate our final `index.html`.

The best part of this is that this is not opinionated at all. Here is were you decide what project structure you want to follow. You like `angular-app` way? Do it that way, the same applies for all the others seeds projects (`angular-seed`, `ng-boilerplate`, etc). If you decide to go with the `angular-app` way, you can delete the `templates` folder and configure `grunt-angular-templates` to look for templates in `app/js/**/*.tpl.html`

This templates contains some code to see how `Lineman` works. Do this:

```bash
$ lineman run
```

This will listen to any changes in our application to lint the files, compile our less, our coffee, concat our files, cache our templates... And of course, it runs the express server at port 8000. Easy as pie! We just need to clone the repository, install the `npm` dependencies and then run `Lineman`. Any changes we do in our app will be automatically processed by grunt.

## Testing with Lineman

Because we want to test our application, `Lineman` comes configured for testing as well. All we need to do is to create our unit tests inside the `spec` folder. `lineman run` will process our tests so the only thing remaining is just to launch our runner:

```bash
$ lineman spec
```

The first thing you will notice is that the runner is not `Karma` but `Test'em`. The `Lineman` guys decided to use `Test'em` and to be honest, I won't go back to `Karma`. `Test'em` is awesome and it has an awesome CLI interface. Not only that, you can open any browser and open the URL that `test'em` uses to test our app in that browser. With this we can test our app in every `OS X` browsers, `Android` ones, `Iphone` safari, even `internet explorer`.

Ok. What about e2e testing?

For that we have a pre-configured `Protractor` ready for business. `Protractor`? Why not `Karma` this time? Angular team is dropping `Karma` in favor of `Protractor` so the `Lineman` team decided to start using `Protractor` here.

## Deployment

That's the easy part, you just need to do:

```bash
$ lineman build
```

and you will get a `dist` folder with the application ready for deployment. If you wants to know how to deploy a `Lineman` application with *Rails* you can check this [guide](https://github.com/Foxandxss/hello-lineman) I wrote some time ago.

## Conclusion

Our Angular applications are as important as the backends, so here we have a workflow to give them the attention they deserve. `Lineman` is an awesome tool packed with a lot of tasks that makes our development easy and fun. And `Lineman` gives much more, like continuous integration.

If you want to learn more about `Lineman` and this template, I recommend you to go to the [Lineman homepage](http://linemanjs.com) and [Lineman angular template](https://github.com/davemo/lineman-angular-template). On the other hand, my friend David has some awesome videos about it [here](http://www.youtube.com/user/vidjadavemo/videos) (In concrete the one about workflows and the one about testing, but what the heck, watch them all, they are awesome).

Well, see you in the next article.