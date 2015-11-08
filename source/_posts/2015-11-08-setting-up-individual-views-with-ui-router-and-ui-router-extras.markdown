---
layout: post
title: "Setting up individual views with ui-router and ui-router-extras"
date: 2015-11-08 12:41
comments: true
categories:
---

I had a problem: My application had multiple independent parts, which needed their own states. For example, I have a toolbar that's on top and a sidebar on the right. The user can change each of the parts without affecting the other, and setting it up as a normal ui-router state tree will not work.

The standard ui-router has no concept of parallel states. Everything must be modeled as a tree, which means a setup like this doesn't work. For example, changing the sidebar's state would affect the toolbar's state as well - which is not something we want.

Thankfully there's [ui-router-extras][ui-router-extras], which adds support for so-called "sticky states" or "parallel states". We can use this to have as many individual parts, that have their own parallel state trees, as we want.

Let's go through a small sample app and look how to set this up step by step. You can [find the full sample app here][sample] so you can follow along more easily.
<!--more-->
### Setting up the necessary libraries

ui-router-extras recommends ui-router version 0.2.8 or newer. As for ui-router-extras itself, we can either install it completely, or just install the core and sticky modules which are needed for sticky states.

An easy way to set it up is to use cdnjs and simply include the necessary scripts like so:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/ui-router-extras/0.1.0/modular/ct-ui-router-extras.core.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ui-router-extras/0.1.0/modular/ct-ui-router-extras.sticky.min.js"></script>
```

ui-router-extras can also be [installed via npm or bower](https://github.com/christopherthielen/ui-router-extras#monolithic-install).

### Setting up the page markup

Below we have a fairly simple page template for this example. We set up two named views, `toolbar` and `sidebar`, which will contain our sticky states, and some templates for their child-states.

It's important each part of our application has its own ui-view. Each sticky state must have its own unique view.

We'll also set up some buttons to toggle the states so we can see it in action.

```html
<body ng-app="stickystates">
  <div ui-view="toolbar"></div>
  <div ui-view="sidebar"></div>

  <div ng-controller="StateController">
    <button ng-click="$state.go('toolbar.state1')">Toolbar 1</button>
    <button ng-click="$state.go('toolbar.state2')">Toolbar 2</button>
    <button ng-click="$state.go('sidebar.state1')">Sidebar 1</button>
    <button ng-click="$state.go('sidebar.state2')">Sidebar 2</button>
  </div>


  <script type="text/ng-template" id="toolbar-state1.html">
    Toolbar state 1
  </script>
  <script type="text/ng-template" id="toolbar-state2.html">
    Toolbar state 2
  </script>
  <script type="text/ng-template" id="sidebar-state1.html">
    Sidebar state 1
  </script>
  <script type="text/ng-template" id="sidebar-state2.html">
    Sidebar state 2
  </script>
</body>
```

### Setting up the states

We'll set up two separate state trees: One for the toolbar and one for the sidebar.

First, we define our application's module. Note that we need to include ui-router and the ui-router-extras core and sticky modules in our dependencies:

```javascript
var app = angular.module('stickystates', [
  'ui.router',
  'ct.ui.router.extras.core',
  'ct.ui.router.extras.sticky'
]);
```

Next, we'll set up the `$stateProvider`. Both the toolbar and sidebar states are set up in the same way, the main difference being which templates and ui-view used.

```javascript
app.config(['$stateProvider', function($stateProvider) {
  //set up the toolbar parent state, and its two child-states
  $stateProvider.state('toolbar', {
    sticky: true,
    views: {
      toolbar: { template: '<div ui-view></div>' }
    }
  })
  .state('toolbar.state1', {
    templateUrl: 'toolbar-state1.html'
  })
  .state('toolbar.state2', {
    templateUrl: 'toolbar-state2.html'
  });
}]);
```

Here we set up three states that we need for the toolbar. First, we set up the base state `toolbar`. We set `sticky: true` to make it a sticky states. Its template is just a div, containing a ui-view. It's important to set it up like this - if you have multiple states accessing the same named view, even if they're the children of the sticky state, it will not work correctly.

You can put other content into the base state's template if you want, or set it up using `templateUrl` - just make sure you include a ui-view within the template for it. Otherwise this won't work correctly.

Each of the child states - `toolbar.state1` and `toolbar.state2` - have a `templateUrl`. The template contents are placed within the ui-view from the parent `toolbar` state. If you want, you can include a state controller in addition to a template, or any other state properties.

Next, we'll set up the sidebar states. These work exactly the same way as the toolbar states - we have a base `sidebar` state with a ui-view, and two child states.

```javascript
//set up the sidebar's states, which are structured the same way
$stateProvider.state('sidebar', {
  sticky: true,
  views: {
    sidebar: { template: '<div ui-view></div>' }
  }
})
.state('sidebar.state1', {
  templateUrl: 'sidebar-state1.html'
})
.state('sidebar.state2', {
  templateUrl: 'sidebar-state2.html'
});
```

Note the only differences in the sidebar states are the state names, templates and the target ui-view.

### Setting up the button controller

For toggling between the states, we need to write a controller.

```javascript
app.controller('StateController', ['$scope', '$state', function($scope, $state) {
  $scope.$state = $state;
}]);
```

In a real application, you probably wouldn't want to add `$state` directly into scope as here, but this works for demonstration purposes.

### Loading default states

Depending on how your application and views are set up, you may want to load a default state for each of your individual views.

Normally you could use the `url` property on a state to choose which to load, but if you want to load multiple defaults - for example, if we want to load a state into both the sidebar and the toolbar - then it won't work, as ui-router requires each state to have a unique URL.

We can work around it by manually changing the state in the application's run-block. However, simply calling `$state.go` twice in a row will not work. We need to chain it using the promise like so:

```javascript
app.run(['$state', function($state) {
  $state.go('toolbar.state1').then(function() {
    $state.go('sidebar.state1');
  });
}]);
```

If you have many states and don't want to repeat their names, you can also use a flag on the state definition object:

```javascript
$stateProvider.state('sidebar.state1', {
  preload: true,
  templateUrl: 'sidebar-state1.html'
});
```

Here we set a `preload` property on the state. Then, in the run-block, we can load all states with the property set and load them instead of having to hardcode them:

```javascript
app.run(['$state', '$q', function($state, $q) {
  var preloads = $state.get().filter(function(s) { return s.preload; });
  preloads.reduce(function(promise, nextState) {
    return promise.then($state.go.bind($state, nextState));
  }, $q.when());
}]);
```

### Conclusion

With all of the above set up, you have a working application with parallel states which can each be manipulated independently from each other. You can [see the whole project put together here][sample].

Although ui-router is a bit limited when it comes to parallel states like this, it's mostly fixed by ui-router-extras and workarounds like chaining the default state loading. One of ui-router's 1.0 version goals is better support for scenarios like this, but until then, this is the best way to do it.

This article was contributed by Jani Hartikainen. He helps JavaScript developers level up their skills by teaching them more advanced development concepts, such as unit testing. Visit Jani's site to [learn how automated testing can help you write better JavaScript code](http://codeutopia.net/blog/h/subscribe/).

[ui-router-extras]: https://christopherthielen.github.io/ui-router-extras/#/home
[sample]: http://plnkr.co/edit/bEdJczNwYEfTI7joyh9h?p=preview
