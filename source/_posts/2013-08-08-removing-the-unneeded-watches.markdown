---
layout: post
title: "Removing the unneeded watches"
date: 2013-08-08 11:38
comments: true
categories: [$watch]
---
{% raw %}
If you ran across any performance issue or you simply want to get rid of those unneeded watches, here is a tip for you!

All the `$watch` that are created have a mechanism to be disabled in the case they are not needed anymore. We have the freedom to choose when a `$watch` is not needed anymore.

Let's see an example:
<!--more-->
```javascript app.js
app = angular.module('app', []);

app.controller('MainCtrl', function($scope) {
  $scope.updated = 0;
  
  $scope.stop = function() {
    textWatch();
  };
  
  var textWatch = $scope.$watch('text', function(newVal, oldVal) {
    if (newVal === oldVal) { return; }
    $scope.updated++;
  });
});
```

```html index.html
<body ng-controller="MainCtrl">
  <input type="text" ng-model="text" /> {{updated}} times updated.
  <button ng-click="stop()">Stop count</button>
</body>
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/emenuf/3/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

The `$watch` returns a function which will unbind the `$watch` upon call. So we simply call it when we don't want to `$watch` anymore.

How can this be useful for bigger applications with hundred to thousand watches?

## A page made with static data

Let's imagine that we are building a page for a conference where we have a page listing all the sessions on a certain day. This page could be like this:

```javascript app.js
app.controller('MainCtrl', function($scope) {
	$scope.sessions = [...];

	$scope.likeSession = function(session) {
		// Like the session
	}
});
```

```html index.html
<ul>
	<li ng-repeat="session in sessions">
		<div class="info">
			{{session.name}} - {{session.room}} - {{session.hour}} - {{session.speaker}}
		</div>
		<div class="likes">
			{{session.likes}} likes! <button ng-click="likeSession(session)">Like it!</button>
		</div>
	</li>
</ul>
```

Imagine that this is a big conference and one day has 30 sessions. How many watches are there? 5 per session plus 1 of the `ng-repeat`. That makes 151 watches. What's the problem with this? That every time we click to like a session, Angular is going to check if the name of the session has changed (and will do the same with the other bindings as well).

The problem here is that all of our data, with the exception of the likes, are static. Isn't that a waste of resources? We are 100% sure that our data are not going to change, so, why should Angular check every time if it has changed?

The solution is simple. We unbind every `$watch` that is not meant to change. They do a fantastic job in the first run, where our DOM is updated with the static information, but after that, they are always listening for changes that are not going to happen.

You convinced me! How can we approach that? Luckily for us, there is a guy who asked himself this question before us and created a set of directives that does the job for us: [Bindonce](https://github.com/Pasvaz/bindonce).

## Bindonce

Bindonce is a set of directives meant for bindings that are not going to change while we are on that page. That sounds like a perfect match for our application.

Let's rewrite our view:

```html index.html
<ul>
	<li bindonce ng-repeat="session in sessions">
		<div class="info">
			<span bo-text="session.name"></span> -
			<span bo-text="session.room"></span> -
			<span bo-text="session.hour"></span> -
			<span bo-text="session.speaker"></span>
		</div>
		<div class="likes">
			{{session.likes}} likes! <button ng-click="likeSession(session)">Like it!</button>
		</div>
	</li>
</ul>
```

For this to work we need to import `bindonce` into our app (and load the library after angular):

```javascript app.js
app = angular.module('app', ['pasvaz.bindonce']);
```

We changed our interpolations (`{{ ... }}`) to `bo-text`. This directive binds our model and waits until the DOM is updated to unbind the `$watch`. This way, the data will be on screen but without any `$watch`.

To make this happen, we need to set the `bindonce` directive in the parent, so it will know when the data is ready (in this case, the session) so the children directives like `bo-text` will know when they can actually unbind the `$watch`.

The result of this is 1 `$watch` per session instead of 5. That makes 31 `$watch` instead of 151. That means that with a proper use of `bindonce` we can potentially reduce the number of watches in our application.

## Conclusion

We shouldn't worry about the performance of our applications, rare are the cases where our application starts to lag, but if you run into one of those cases or you simply want to remove unneeded watches, this library is for you.

There are a lot more directives in `bindonce`, so I encourage you to check them out! [List of directives](https://github.com/Pasvaz/bindonce#attribute-usage)

{% endraw %}
