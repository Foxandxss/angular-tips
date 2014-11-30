---
layout: post
title: "Working with Laravel + Angular - part 2"
date: 2014-11-30 11:57
comments: true
categories: [workflow, laravel]
---

[Last time](blog/2014/10/working-with-a-laravel-4-plus-angular-application) we saw a couple of different options on how to integrate `Angular` and `Laravel`. Today we are going to learn how to create our backend and frontend as separate applications but having them work together under the same domain. Every request will go to angular except the ones for `/api` which are going to be managed by `Laravel`.
<!--more-->
First, we need to create our applications:

```
$ cd /path/to/your/apps
$ mkdir sharingdomain && cd $_
$ laravel new sharingdomain-backend
$ git clone https://github.com/Foxandxss/fox-angular-gulp-workflow sharingdomain-frontend
```

So in a new folder, we created a new laravel application and also we cloned an angular boilerplate (I used mine, but you can use anything else, or even your own boilerplate).

Let's git it:

```
$ rm -rf sharingdomain-frontend/.git
$ git init
$ git add .
$ git commit -m "First commit"
$ git remote add origin https://github.com/yourhandle/sharingdomain.git
$ git push origin master
```

On a real project, you would want to create a separate repository for each application to have the maximum flexibility, but for this demo, we are going to put both applications together on the same repository.

Like we did on the last article, we are going to create a controller to show us our favorite tv shows:

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

And we also need a router for it:

```php app/routes.php
Route::group(array('prefix' => 'api'), function () {
  Route::get('shows', 'ShowController@index');
});
```

We made a group to prefix every route with `/api` because as we said earlier, only the petitions to `/api` are going to be managed by `Laravel`.

Alright, let's try our API, but first let's run our laravel application:

```plain
$ cd sharingdomain-backend
$ php artisan serve --port 8000
```

Now with our app running on port `8000` we can try our api:

{% img /images/posts/laravelangulardemo/samedomain/1.png %}

The `Laravel` side is done. Notice how it knows nothing about `Angular` or any kind of frontend.

Let's commit it:

```
$ git add .
$ git commit -m "Laravel API done"
$ git push origin master
```

Let's move to the `Angular` application. First we need to install the dependencies:

```
$ cd ../sharingdomain-frontend
$ npm install
```

This will install all of our workflow dependencies and also install the `bower` packages.

First, we are going to install `angular-route`:

```
$ bower install --save angular-route
```

Next, we modify our vendor manifest like:

```javascript vendor/manifest.js
exports.javascript = [
  'vendor/angular/angular.js',
  'vendor/angular-route/angular-route.js',
  'vendor/lodash/dist/lodash.js'
];
```

This makes our workflow aware of what vendor files we want to load and in what order.

Now we load `ngRoute` as a dependency on our application:

```javascript app/js/app.js
angular.module('app', ['ngRoute']);
```

And then we configure it a little bit:

```javascript app/js/config.routes.js
angular.module('app').config(function($routeProvider, $locationProvider) {
  $routeProvider.otherwise('/shows');

  $locationProvider.html5Mode(true).hashPrefix('!');
});
```

That will redirect unknown routes to `/show` and it will also enable the `html5mode` in our application (In other words, no more `/#/` in our URLs).

Then as a last step to enable that `html5mode` we need to update our `index.html` `<head>` tag like:

```html app/index.html
<head>
  <meta charset="UTF-8">
  <title>Angular App</title>
  <link rel="stylesheet" href="<%= css %>">
  <base href="/" />
</head>
```

We just added a `base` tag to it which is needed if we want to remove that hash on our routes.

Now, let's code our feature:

```javascript app/js/features/shows/config.routes.js
angular.module('app').config(function($routeProvider) {
  $routeProvider.when('/shows', {
    templateUrl: 'features/shows/shows.tpl.html',
    controller: 'Shows'
  });
});
```

```javascript app/js/features/shows/shows.js
angular.module('app').controller('Shows', function($scope, $http) {
  $http.get('/api/shows').then(function(result) {
    $scope.shows = result.data;
  });
});
```
{% raw %}
```html app/js/features/shows/shows.tpl.html
<h1>My favorite TV Shows ever</h1>

<ul>
  <li ng-repeat="show in shows">
    {{show}}
  </li>
</ul>
```
{% endraw %}

Lastly, we need to put an `ng-view` on our `index.html` which is the entry point of the router:

```html app/index.html
<body>
  <div ng-view></div>
  <script type="text/javascript" src="<%= js %>"></script>
</body>
```

We have our feature there, but if we look closer, we see that our request URL is `/api/shows`. How can angular relates that URL with our `Laravel` application running at port `8000`? It can't do that by default but also, we don't want to use CORS because in production we are not going to use that. So... what's the solution here? We can proxy our requests for development. The workflow we are using does that for us automatically. If we open the `gulpfile.js` we can see:

```javascript gulpfile.js
gulp.task('webserver', ['indexHtml-dev', 'images-dev'], function() {
  plugins.connect.server({
    root: paths.tmpFolder,
    port: 5000,
    livereload: true,
    middleware: function(connect, o) {
      return [ (function() {
        var url = require('url');
        var proxy = require('proxy-middleware');
        var options = url.parse('http://localhost:8080/api');
        options.route = '/api';
        return proxy(options);
        })(), historyApiFallback ];
    }
  });
});
```

That is the task that serves our angular application, and if you look carefully, you will see that we are building a proxy there. That means that by default, all the request we do to `/api` are going to be redirected to `localhost:8080/api`. Just what we needed!

The only change we need to do here, is to change the port from `8080` to `8000` to match the one we are using for `Laravel`.

```javascript gulpfile.js
var options = url.parse('http://localhost:8000/api');
```

Alright, after all this coding, let's run our angular application:

```plain
$ gulp
```

And if we have our `Laravel` app running, we can see:

{% img /images/posts/laravelangulardemo/samedomain/2.png %}

Let's commit the changes:

```
$ git add .
$ git commit -m "Angular side done"
$ git push origin master
```

So, we have two separate projects now, one with `Laravel` serving an `API` and one with `Angular` which is proxying all the `/api` requests to `Laravel`. Right, but how can we deploy this on the same domain but still have them separated? That is managed by `nginx`. But first, we generate or production files for the `Angular` app like:

```plain
$ gulp production
```

That will generate a `dist` folder with the static files we will use on production.

Having that files and also our `Laravel` application, we can move them to our server and then create an `nginx` configuration like:

```bash
server {
  server_name ourappname.local;
  root /path/to/frontend/;

  location / {
    index index.html;
    try_files $uri $uri/ /index.html =404;
  }

  location /api {
    root /path/to/laravel/backend/public;
    try_files /index.php =404;

    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $request_filename;
    fastcgi_param APP_ENV dev;
    fastcgi_pass 127.0.0.1:9000;
  }
}
```

First, we set the path to our frontend (AKA the content of the `dist` folder we generated previously) and then we set the path for the `public` folder of our `Laravel` application.

Thanks to this config, when we request `/shows` that will go to `Angular` but if we do any request that begins with `/api`, that will go directly to `Laravel`.

We can see it working here in production mode:

{% img /images/posts/laravelangulardemo/samedomain/3.png %}

So here we saw another way to integrate `Angular` with `Laravel`. This idea is so cool because we can easily change the frontend or the backend without having to change any code from the other unchanged part.
