---
layout: post
title: "Removing the unneeded watches"
date: 2013-08-08 11:38
comments: true
categories: [$watch]
---
{% raw %}
Having too many `$watch` can create performance issues for webpages, especially on mobile devices. This post will explain how to remove extraneous `$watch` and accelerate your application!

Any `$watch` can be disabled when it is no longer needed. Thus, we have the freedom to choose when to remove a `$watch` from the `$watch` list.

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

The `$watch` function itself returns a function which will unbind the `$watch` when called. So, when the `$watch` is no longer needed, we simply call the function returned by `$watch`.

How can this be useful for bigger applications with hundreds to thousands of `$watch`?

## A page made with static data

Let's imagine that we are building a page for a conference that lists all the sessions on a certain day. This page could look like this:

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

Imagine that this is a big conference, and one day has 30 sessions. How many `$watch` are there? There are five per session, plus one for the `ng-repeat`. That makes 151 `$watch`. What's the problem with this? Every time the user “likes” a session, Angular is going to check if the name of the session has changed (and will do the same with the other bindings as well).

The problem is that all of our data, with the exception of the likes, are static. Isn't that a waste of resources? We are 100% sure that our data are not going to change, so, why should Angular check if they have changed?

The solution is simple. We unbind every `$watch` that is never going to detect a change. These `$watch` are important during the first run, in which our DOM is updated with the static information, but after that, they are watching a constant for changes, which is a clear waste of resources.

You convinced me! How can we approach this? Luckily for us, there is a guy who asked himself this question before us and created a set of directives that does the job for us: [Bindonce](https://github.com/Pasvaz/bindonce).
	
## Bindonce

Bindonce is a set of directives meant for bindings that are not going to change while the user is on a page. That sounds like a perfect match for our application.

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

For this to work we need to import `bindonce` into our app (and load the library after Angular):

```javascript app.js
app = angular.module('app', ['pasvaz.bindonce']);
```

We changed our interpolations (`{{ ... }}`) to `bo-text`. This directive binds our model and waits until the DOM is updated to unbind the `$watch`. This way, the data will be on screen but without any `$watch`.

To make this happen, we need to set the `bindonce` directive in the parent, so it will know when the data is ready (in this case, the session) so the children directives like `bo-text` will know when they can actually unbind the `$watch`.

The result of this is one `$watch` per session instead of five. That makes 31 `$watch` instead of 151. That means that with a proper use of `bindonce` we can potentially reduce the number of watches in our application.

## Conclusion

While premature optimization should be avoided, this library could help an application that is suffering from a performance bottleneck.

There are a lot more directives in `bindonce`, so I encourage you to check them out! [List of directives](https://github.com/Pasvaz/bindonce#attribute-usage)

{% endraw %}
