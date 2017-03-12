+++
date = "2015-06-22T22:58:28+01:00"
title = "Using AngularJS with ES6 and Webpack"
categories = []
tags = ["ES6", "webpack", "workflow"]
description = ""

+++

I know you're all excited with Angular 2 and ES6, but that doesn't mean we can't use ES6 with Angular 1.x.

Today, I am going to present you my new workflow for Angular 1.x with ES6.
<!--more-->

## A brief introduction to Webpack

`Webpack` is a module bundler, what does that mean? Well, it basically take modules with dependencies and generate static assets to represent those modules.

So we could have a module like:

File: `my_module.js`
```javascript
import foo from './foo';

foo.bar();
```

And if we process it with `Webpack`, it will take this `my_module.js`, retrieve its dependencies (`foo.js`) and generate a static file with both files.

So the idea with `Webpack` is: I tell you what the entry point is and you figure out the rest. For `Angular` applications, that is normally the file where we create our main module. So starting from that file, it starts pulling dependencies in (basically our entire application) and then it generates a `bundle.js` file which contains our application. There is no more need of creating hundred of `<script>` tags anymore.

`Webpack` is not a replacement for `Gulp`, but it can do all the job by itself without needing `Gulp`. The philosophy is also different. In `Gulp` we do something like: "Grab all the .js files from this directory, start creating a sourcemap, concat the files, if it is for production run ng-annotate, uglify and then finish the sourcemap". In `Webpack` we have loaders so if we need `sass` support, we can do something like:

File: `webpack.config.js`
```javascript
loaders: [{
  test: /\.scss$/,
  loader: 'style!css!sass'
}];
```

How does this work? First, we match all the `.scss` files in our project and then we send it to the loader. If you have more than one loader, you separate them using `!` and then they run starting from the last one (pretty much like `Rails` and the file extensions if you're familiar with it).

So it send all the `.scss` files to the `sass` loader which will transform our `sass` into `css`. The output of that will be sent to the `css` loader which will read them and return their `css` code and finally it ends on the `style-loader` which `Webpack` uses to generate `<link>` tags and stuff.

Thanks to that, we can achieve things like:

File: `app.js`
```javascript
import './styles.scss'
```

to import that `scss` into our app.

So the idea with `Webpack` is just that. An entry point, and from there we import the different dependencies of our application thanks to the loaders.

Before we move on, what about the `ES6` ? That is another loader, in concrete, the `babel-loader`:

File: `webpack.config.js`
```javascript
loaders: [
  // SASS one omitted
  {
    test: /\.js$/,
    loader: 'babel',
    exclude: /node_modules/
  }
];
```

Now when we import a javascript file, it will be processed by `babel`. Notice how we exclude `node_modules` to get some performance ;)

## Using Angular 1.x with ES6

So having `Webpack` to process everything for us, we just need to start coding our app.

I created a [workflow](https://github.com/Foxandxss/angular-webpack-workflow) with `Webpack` for you, so you just have to clone it and stop worrying about tooling:

```plain
$ git clone https://github.com/Foxandxss/angular-webpack-workflow my_app
$ cd my_app
$ npm install
$ npm run dev
```

`npm run dev` will launch the `webpack-dev-server` which comes with livereload. Now you can go to `http://localhost:8080` to see the application working.

From here, how you structure your app and how you name the files is up to you. I am going to share in here my conventions in how to use `ES6` with Angular 1.x.

If you open `src/app.js` (our entry point) you could code:

File: `src/app.js`
```javascript
angular.module('app', []);
```

If you remember from what I said earlier, `Webpack` will grab this file and all its dependencies to generate the final result. Is this line going to work? Try it. It doesn't. Why? Because `Angular` hasn't been loaded yet and when `Webpack` generates the final `build.js` it won't have `Angular` in it so it won't work. How do we tell `Webpack` to load `Angular` ? As simple as:

File: `src/app.js`
```javascript
require('angular');

angular.module('app', []);
```

That will tell `Webpack` to require `Angular` so the final `build.js` will have `Angular` loaded. Now, since `Angular` creates a global `angular` object, we can simply use it to create our `app` module.

That is good, but not good enough. One of the best things of being able to "require" stuff is knowing where our stuff come from. Yes, requiring angular will create that global variable, but it is not that clear...

Isn't it better to do:

File: `src/app.js`
```javascript
const angular = require('angular');

angular.module('app', []);
```

I think it is. `Angular` also exports the `angular` object so we can get it like that and use it to create our modules and components. You can also use ES6 syntax to require modules:

File: `src/app.js`
```javascript
import angular from 'angular';

angular.module('app', []);
```

I personally prefer the ES6 syntax, but the previous one is good as well.

### Loading Bootstrap

Not related with `Angular`, but it is a common choice to include CSS frameworks like `bootstrap`. How can we use it?

```plain
$ npm install --save bootstrap
```

Now, we import it:

File: `src/app.js`
```javascript
import 'bootstrap/dist/css/bootstrap.css';

import angular from 'angular';

angular.module('app', []);
```

And it works!

Why load it in here? Isn't this file the one who creates the `app` module? Yes, but we can think of the `bootstrap.css` as the main `css` of our entire application, so here we are saying: I want to apply the 'bootstrap.css' on our entire application. While that sentence is not completely true (you can load it in a inner file and it will still be applied in the entire app), we are talking here about the semantics, in other words, to make clear that `bootstrap.css` will apply to the entire app.

### Config functions

Creating a config function in ES6 is not really different to ES5, it is just a function we export to be used in a different file:

File: `src/app.config.js`
```javascript
routing.$inject = ['$urlRouterProvider', '$locationProvider'];

export default function routing($urlRouterProvider, $locationProvider) {
  $locationProvider.html5Mode(true);
  $urlRouterProvider.otherwise('/');
}
```

Here we created a function to configure `html5Mode` and also to send us to `/` on startup. Notice how we used `export default` to export our function.

**NOTE**: There is no need of using `$inject` like I did in here, there is a `Webpack` loader for `ng-annotate` that you can use to let webpack annotate for you. Personally I prefer the `$inject` syntax. The loader is not installed on my workflow, but it is a 1 minute change.

Now with our exported function, we just need to import it somewhere and use it, for example:

File: `src/app.js`
```javascript
import 'bootstrap/dist/css/bootstrap.css';

import angular from 'angular';

import routing from './app.config';

angular.module('app', [])
  .config(routing);
```

Good, now our configuration is done and it is clear where that "routing" function comes from.

Ah! We are using `ui-router`, so we need to install it:

```plain
$ npm install --save angular-ui-router
```

Now we need to import it (like we did with angular) and put it is a dependency to `app`. But... how? I mean, angular returns an object, but what does `ui-router` return? It won't return an object, basically because there is none.

Since angular comes with its own module system, what it expects is the name of the module we want to load, something like:

```javascript
angular.module('app', ['ui.router']);
```

Alright, but we still need to import `ui-router` to include it on the `bundle.js`, so here we can kill two birds with one stone:

File: `src/app.js`
```javascript
import 'bootstrap/dist/css/bootstrap.css';

import angular from 'angular';
import uirouter from 'angular-ui-router';

import routing from './app.config';

angular.module('app', [uirouter])
  .config(routing);
```

The convention that all external modules are following is to simply export the name of the module, so `uirouter` here is the string `'ui.router'`.

### A new module

So let's code a dummy feature. We need a new module, a controller, a template and route config. Let's start with the controller:

File: `src/features/home/home.controller.js`
```javascript
export default class HomeController {
  constructor() {
    this.name = 'World';
  }

  changeName() {
    this.name = 'angular-tips';
  }
}
```

So a controller with ES6 is just a class. When using ES6 we will use `controllerAs` so we put our stuff in `this.`. Here we initialize a `name` field and also we have a button to change it. The controller gets exported so we can use it in a different file. Let's create the template now:

File: `src/features/home/home.html`
```html
<div class="jumbotron">
  <h1>Hello, {{home.name}}</h1>
</div>

<button class="btn btn-primary" ng-click="home.changeName()">Change</button>
```

Also the routing config:

File: `src/features/home/home.routes.js`
```javascript
routes.$inject = ['$stateProvider'];

export default function routes($stateProvider) {
  $stateProvider
    .state('home', {
      url: '/',
      template: require('./home.html'),
      controller: 'HomeController',
      controllerAs: 'home'
    });
}
```

Notice how we loaded our template. Thanks to webpack, we can require html files (just read them, without processing) and that will return the template as a string. Just what `template` needs.

Ok, now we just need our module:

File: `src/features/home/index.js`
```javascript
import angular from 'angular';
import uirouter from 'angular-ui-router';

import routing from './home.routes';
import HomeController from './home.controller';

export default angular.module('app.home', [uirouter])
  .config(routing)
  .controller('HomeController', HomeController)
  .name;
```

First notice the name of the file, `index.js`. Thanks to that we can import a folder and this file will be the one that runs.

Also, we return the `name` of the module as we said earlier (external modules always return their name).

Since this module is also using `ui-router`, we import it. There is no *real* need to do this, we loaded `ui-router` in the `app` module, but doing this we get two things: It is easy to see what dependencies our module have, and if we need this feature in another app, we can simply copy & paste it without having to worry about dependencies. Also, Angular won't care, it will simply ignore it.

Now back to the `app` module, we need to add this new module as a dependency:

File: `src/app.js`
```javascript
// other imports omitted

import routing from './app.config';
import home from './features/home';

angular.module('app', [uirouter, home])
  .config(routing);
```

Finally, we just need to add a `ui-view` to our `index.html`:

File: `src/index.html`
```html
<!doctype html>
<html ng-app="app" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Angular App</title>
  <base href="/">
</head>
<body>
  <div class="container
    <ui-view></ui-view>
  </div>
</body>
</html>
```

**NOTE**: If we modify the `index.html`, we need to re-run webpack.

If you try it, it works!

![](/images/posts/webpackintro/1.png)

Uhm, I would like the text to be centered in the jumbotron. First, let's add an id to our jumbotron:


File: `src/features/home/home.html`
```html
<div id="home-header" class="jumbotron">
  <h1>Hello, {{home.name}}</h1>
</div>

<button class="btn btn-primary" ng-click="home.changeName()">Change</button>
```


And now let's create a specific `css` file for this feature:

File: `src/features/home/home.css`
```css
#home-header {
  text-align: center;
}
```

Like we did with `bootstrap.css`, we need to load this `home.css`. A good place would be the file where we create our `home` module:

File: `src/features/home/index.js`
```javascript
import './home.css';

import angular from 'angular';
import uirouter from 'angular-ui-router';

// Rest omitted
```

Now, it is a bit better.

### Services

With ES6, we won't use factories anymore, instead we are going to use services. The reason behind that is that a class maps perfectly to a service:

File: `src/services/randomNames.service.js`
```javascript
import angular from 'angular';

class RandomNames {
  constructor() {
    this.names = ['John', 'Elisa', 'Mark', 'Annie'];
  }

  getName() {
    const totalNames = this.names.length;
    const rand = Math.floor(Math.random() * totalNames);
    return this.names[rand];
  }
}

export default angular.module('services.random-names', [])
  .service('randomNames', RandomNames)
  .name;
```

So here we have a service that returns a random name. In my personal convention, I decided to create both service + module in one file and export the module's name.

The service itself, just a class with methods, nothing complex nor fancy. Let's use it on the `home` module. First import it:

File: `src/features/home/index.js`
```javascript
// Rest of imports omitted
import HomeController from './home.controller';
import randomNames from '../../services/randomNames.service';

export default angular.module('app.home', [uirouter, randomNames])
  .config(routing)
  .controller('HomeController', HomeController)
  .name;
```

Nothing new in here. Let's use it:

File: `src/features/home/home.controller.js`
```javascript
export default class HomeController {
  constructor(randomNames) {
    this.random = randomNames;
    this.name = 'World';
  }

  changeName() {
    this.name = 'angular-tips';
  }

  randomName() {
    this.name = this.random.getName();
  }
}

HomeController.$inject = ['randomNames'];
```

We inject it on the constructor, assign it to a local variable and then we just simply use it. For the template, a little update:


File: `src/features/home/home.html`
```html
<div id="home-header" class="jumbotron">
  <h1>Hello, {{home.name}}</h1>
</div>

<button class="btn btn-primary" ng-click="home.changeName()">Change</button>
<button class="btn btn-danger" ng-click="home.randomName()">Random</button>
```

Yay, new features.

### Directives

Sadly, directives are not easy to implement as a class (there are some [workarounds](http://stackoverflow.com/a/28634429/123204)) so I prefer to keep using them as a function:

File: `src/directives/greeting.directive.js`
```javascript
import angular from 'angular';

function greeting() {
  return {
    restrict: 'E',
    scope: {
      name: '='
    },
    template: '<h1>Hello, {{name}}</div>'
  }
}

export default angular.module('directives.greeting', [])
  .directive('greeting', greeting)
  .name;
```

Doesn't hurt anyway. Let's import it:

File: `src/features/home/index.js`
```javascript
// Rest of imports omitted
import HomeController from './home.controller';
import randomNames from '../../services/randomNames.service';
import greeting    from '../../directives/greeting.directive';

export default angular.module('app.home', [uirouter, randomNames, greeting])
  .config(routing)
  .controller('HomeController', HomeController)
  .name;
```

Finally:

File: `src/features/home/home.html`
```html
<div id="home-header" class="jumbotron">
  <greeting name="home.name"></greeting>
</div>

<button class="btn btn-primary" ng-click="home.changeName()">Change</button>
<button class="btn btn-danger" ng-click="home.randomName()">Random</button>
```

### Testing

Webpack is awesome for testing, but sadly Angular is a bit limited in that aspect. On a good world, we would have our test requiring different entry points so we can test our modules in isolation without having to load all the application. But yet again, angular was never made with that intention in mind so we have to forget about that and test like we always did.

There is a karma.conf.js on our project which basically uses a plugin for webpack support. There, we also load a file that I named: `tests.webpack.js`. That file will simply load all the tests on our project. Yes, it is a bit of a hack but that is what we have right now:

File: `src/tests.webpack.js`
```javascript
import 'angular';
import 'angular-mocks/angular-mocks';

var testsContext = require.context(".", true, /.test$/);
testsContext.keys().forEach(testsContext);
```

We also load angular and angular-mocks for our tests.

Let's start karma:

```plain
$ npm run test:live
```

And code a simple test for the sake of the article:

File: `src/features/home/home.controller.test.js`
```javascript
import home from './index';

describe('Controller: Home', function() {
  let $controller;

  beforeEach(angular.mock.module(home));

  beforeEach(angular.mock.inject(function(_$controller_) {
    $controller = _$controller_;
  }));

  it('name is initialized to World', function() {
    let ctrl = $controller('HomeController');
    expect(ctrl.name).toBe('World');
  });
});
```

Here we import the module we want to test, we load it and we just test it as we are used to.

**NOTE**: On my workflow, you need to prepend `.test` to your test files.

As a freebie, there on the `build` folder you can find the tests coverage.

### Production

The hardest part. Or it is not? I guess not.

```plain
$ npm run build
```

That will generate the final build at `/dist`. Just point your server to `/dist/index.html` and you're good to go. It also includes cache-busting for free :)

### Extra

What about third party libraries that doesn't have `Webpack` support? I mean, libraries that are not exporting anything. Well, we can simply require it like:

```javascript
import 'thelibrary';
```

That will include `thelibrary` on the build and that is good enough.

So please library creators, make your libraries to work with Webpack, it is as easy as 2-3 lines of code :)

### Conclusions

Webpack is a nice way to use ES6 with Angular 1.x. It is easy to configure and does a lot of things for you.

It is not the only option tho, you can also use [JSPM](http://jspm.io) but that is something for another day ;)

I want to give my thanks to my friend [Cesar Andreu](https://github.com/cesarandreu) for creating the original workflow and for helping me with this one.

If you want to play with this demo, you can clone it from [here](https://github.com/angular-tips/webpack-demo).
