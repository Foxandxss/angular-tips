---
layout: post
title: "Working with a Laravel 4 + Angular application"
date: 2014-10-27 14:48
comments: true
categories: [workflow, laravel]
---

So you decided that `Laravel` is a great choice for a backend and that `Angular` is going to fit perfectly as the framework of choice for the frontend. Yeah! That is correct and I am starting to like you.

How to start? So many question, so little time (someone said :P)
<!--more-->

Before we start, let me explain a little bit the different options we have for combining this two.

Isn't there a perfect solution which work in any case? No. It all depend on the project itself and the use case. I am going to show here my **opinions** about the subject.

Let's start with the option of letting `Laravel` serve `Angular` for you.

PROS:

* It is the simplest way of combining this two.
* In development, it is easier to communicate the `Angular` with `Laravel`. There is no need of CORS or proxies.
* Makes deployment a breeze. Just tell `forge` to compile the angular before doing any deployment and you are good to go.
* It is perfect for newbies and you can always move to other workflows later without problem if needed.
* Perfect for small projects and pet projects. I even see big projects using this workflow tho.
* Since everything is inside the same domain, you just need one SSL certificate, ideal for pet projects.
* We can easily bootstrap data from `Laravel` at startup with some minimum changes to this workflow.

CONS:

* It is a little bit (just a little) coupled. Letting `Laravel` serve our `Angular` couples the solution a little bit. It *could* be problematic for some kind of projects.
* If you want to change the frontend, you need to delete everything you created for `Angular` but luckily for us, you just need to delete one folder.
* If you want to change the backend, you need to move that folder somewhere else.

`Angular` in one domain (`example.com/`) and `Laravel` in another domain (`api.example.com/`):

PROS:

* Totally decoupled, they know nothing of each other, so we have complete freedom.
* You can swap `Laravel` or `Angular` in a breeze.
* Works for big projects without problem.
* Maybe little bit more daunting if you're just starting to learn `frontend` stuff.

CONS:

* You need two SSL certificates, I know, they are cheap but if you just have a pet project, you don't want to pay double (not a problem if it is an enterprise project).
* Communication between both of them, even when still easy, needs more work (which is not handy for newbies).

There is a middleground between both, having them separate but inside the same domain (`Angular` at `example.com` and `Laravel` at `example.com/api`)

PROS:

* Easy to deploy
* You just need one SSL certificate.

CONS:

* If you're using `Homestead` you will need to craft your own `nginx` config in the new applications.
* Makes API versioning maybe a little bit more complicated.

In my opinion, the first way works really good, it is done in a lot of different backends (just google about XXX + angular) and you will see a lot of people doing it. There is nothing wrong with it.

If you feel that your project is going to be big and you prefer a complete and total separation there, that is also awesome, you can do it.

So the **TL;DR** here is that there are a couple of ways (and more I didn't mention here) and luckily we have the freedom of picking the one who fits our project. But before doing that, we need to learn how to use them :)

So for this first article, we are going to use the first way

So, right from the beginning:

```
$ laravel new laravelangulardemo
$ cd laravelangulardemo
```

{% img /images/posts/laravelangulardemo/1.png %}

Blimey! We arrived. Thank you reading this article.

No, wait, we forgot the Angular part.

As I said before, we are going to follow the first approach here, so I prepared a little workflow [here](https://github.com/Foxandxss/angular-laravel4-workflow) that we can use to accomplish this easily.

Assuming we are on the directory of our `Laravel` application we do:

```
$ git clone https://github.com/Foxandxss/angular-laravel4-workflow angular
$ cd angular
$ npm install
```

To use the `Angular` workflow we just need to clone it on the application root and install its dependencies. We can choose any name for the workflow, I chose `angular` because it is a pretty obvious name. You can clone it on the `/app` directory if you wish (check the workflow repository for more information).

Let's create a git repo for our project. From the root directory we:

```
$ rm -rf angular/.git
$ git init
```

We delete the repository that comes with the workflow and we create a new one for the whole application, then we modify our `.gitignore` to support our `Angular` workflow:

```
/bootstrap/compiled.php
/vendor
composer.phar
composer.lock
.env.*.php
.env.php
.DS_Store
Thumbs.db

# Angular ignores
angular/node_modules
public/images
public/css
public/js
public/angular.html
```

Ignoring those ignores for now, we can now commit:

```
$ git add .
$ git commit -m "Initial commit"
```

Now assuming we have a remote repository (I have mine for this project [here](https://github.com/Foxandxss/Laravel-angular-demo)):

```
$ git push
```

Alright, everything is set in place, let's do a `Hello World` first to see everthing working.

First, we just need to start `gulp` which is going to do all the heavy lifting for us:

```
$ cd angular
$ gulp
```

And then we modify our `index.html` file to put that `Hello World`.

{% raw %}
```html angular/app/index.html
<!doctype html>
<html ng-app="app" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Angular App</title>
  <link rel="stylesheet" href="<%= css %>">
</head>
<body>
  Hello, World, this is angular and to prove it, there is a computation: 5 + 3 == {{ 5 + 3 }}
  <script type="text/javascript" src="<%= js %>"></script>
</body>
</html>
```
{% endraw %}

Here we have the message with a little angular to prove it is working. Notice that the `ng-app` is already set for us.

Also, don't be scared with those `<%= ... %>` placeholders, that is for the `cache-busting` and we don't need to worry about that.

If you take a look to our `/public` folder (the `Laravel` one) we can see:

{% img /images/posts/laravelangulardemo/2.png %}

There is our compiled `angular` application! (In concrete, the `css` and `js` folders along the `angular.html`)

Why `angular.html` instead of `index.html`? Well, the `nginx` could load that for us and in a first sight there is no issue, but I am not an experienced `Laravel` developer so it could have some side effect and I don't want that. Changing the name to `angular.html` will prevent that.

Great, but if we run our application...

{% img /images/posts/laravelangulardemo/1.png %}

Uh, what happened with our `Hello World` ?

Well, nothing, the question is... Who is routing it? `Laravel` knows nothing about that file, we need to create a route for it:

```php app/routes.php
App::missing(function($exception)
{
    return File::get(public_path() . '/angular.html');
});
```

We delete all its content and we put that.

What can you tell me about this complex route? This is a `catch-all` route. What's that? A `catch-all` route is a route we put at the **END** that will catch any request (that is why we put it last). You can read it like... If after all the routes I have on the file, you end here, please get the `/public/angular.html` file and give it back. Just what we needed. We can define all our `/api` routes before that and when our request doesn't match any `REST endpoint` it will serve the `angular`. Later you will see another advantage.

If we run the app now, we see:

{% img /images/posts/laravelangulardemo/3.png %}

Fantastic! It simply works!

We can create a `Laravel controller` to serve that `/public/angular.html` but we don't really need to. Uh, talking about controllers... There is one we don't need:

```
$ git rm app/controllers/HomeController.php
$ git rm app/views/hello.php
```

We didn't need that view as well.

Let's commit the changes:

```
$ git add .
$ git commit -m "Angular is now working"
$ git push
```

Now we are going to implement a simple endpoint to serve a list of our favorite TV shows:

```php app/controllers/ShowController.php
<?php

class ShowController extends \BaseController
{

    /**
     * Display a listing of the shows.
     *
     * @return Response::json
     */
    public function index()
    {
        $shows = array('Doctor Who', 'Stargate SG1', 'Once upon a time',
                       'The Blacklist', 'Prison Break', 'White Collar');


        return Response::json($shows);
	}
}
```

```php app/routes.php
Route::get('api/shows', 'ShowController@index');

App::missing(function($exception)
{
    return File::get(public_path() . '/angular.html');
});
```

Excuse my `Laravel` fu, I am new at it.

So, a controller which returns an array of TV shows and a route to serve them (notice how I put it before the `catch-all`).

We know need to consume it from `Angular`.

For the sake of completion, we are going to pull `angular-route.js` from [here](https://code.angularjs.org/1.3.0/angular-route.js) and we just need to download it to `angular/vendor/js`. There is no bower here, I don't like it.

Well, we don't need to tell anyone about that new file, just put is a dependency:

```javascript angular/app/js/app.js
angular.module('app', ['ngRoute']);
```

Then we configure `ngRoute` a little bit:

```javascript angular/app/js/config.routes.js
angular.module('app').config(function($routeProvider) {
  $routeProvider.otherwise('/shows');
});
```

We redirect to '/shows' if the route doesn't match anything registered.

Now we create a new feature for the show listing:

{% img /images/posts/laravelangulardemo/4.png %}

```javascript angular/app/js/features/shows/config.routes.js
angular.module('app').config(function($routeProvider) {
  $routeProvider.when('/shows', {
    templateUrl: 'features/shows/shows.tpl.html',
    controller: 'Shows'
  });
});
```

```javascript angular/app/js/features/shows/shows.js
angular.module('app').controller('Shows', function($scope, $http) {
  $http.get('/api/shows').then(function(result) {
    $scope.shows = result.data;
  });
});
```
{% raw %}
```html angular/app/js/features/shows/shows.tpl.html
<h1>My favorite TV Shows ever</h1>

<ul>
  <li ng-repeat="show in shows">
    {{show}}
  </li>
</ul>
```
{% endraw %}

We create a new route for the `/shows` pointing to our template and controller. The controller will forget a little bit about angular conventions and will make a `$http` request to our `Laravel` endpoint and will save the result on `$scope.shows`. Lastly, our template will show them on a list.

The last piece is our `index.html` which needs a `ng-view`:

```html angular/app/index.html
<body>
  <div ng-view></div>
  <script type="text/javascript" src="<%= js %>"></script>
</body>
```

If we execute this:

{% img /images/posts/laravelangulardemo/5.png %}

Here it is! Working like charm.

Notice the `/#/` at the url, that is something we expect on an `Angular` app. What if we want to use `html5mode` to remove it?

```javascript angular/app/js/config.routes.js
angular.module('app').config(function($routeProvider, $locationProvider) {
  $routeProvider.otherwise('/shows');

  $locationProvider.html5Mode(true).hashPrefix('!');
});
```

With that new change, we are using `html5mode`. That also needs a little change on the `index.html` as well:

```html angular/app/index.html
<head>
  <meta charset="UTF-8">
  <title>Angular App</title>
  <link rel="stylesheet" href="<%= css %>">
  <base href="/" />
</head>
```

Just that `base` tag.

{% img /images/posts/laravelangulardemo/6.png %}

Oh, now it doesn't have that `/#/`.

If you're curious about how this work, it is something like:

* You request `/`
* It goes to Laravel and it starts looking the `routes.php` file.
* Is `/api/shows` matching `/` ? No.
* Ok, we ran out of matches, so here is the `catch-all` route.
* `catch-all` route will render the angular and will give to it the `/` requested route.
* Angular will give that `/` requested route to its router.
* No match, so it runs the `otherwise` which redirects to `/shows`.

Let's commit our changes:

```
$ git add .
$ git commit -m "TV Shows endpoint + angular consumption"
$ git push
```

Our application is done! What about preparing our `Angular` for production?

Easy:

```
$ cd angular
$ gulp clean && gulp production
```

You will notice that our `angular.html` is different now:

```html public/angular.html
<!doctype html>
<html ng-app="app" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Angular App</title>
  <link rel="stylesheet" href="app-d41d8cd9.css">
  <base href="/" />
</head>
<body>
  <div ng-view></div>
  <script type="text/javascript" src="app-b9f3917d.js"></script>
</body>
</html>
```

Our assets have a hash to do cache-busting.

You can simply tell `forge` to run that before any deployment and you're good to go.

If you feel like this way is not for you, worry not, in a future article, we are going to play with the third option of having both separated but in the same domain.
