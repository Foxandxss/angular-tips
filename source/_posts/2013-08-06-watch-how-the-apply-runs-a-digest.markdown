---
layout: post
title: "$watch how the $apply runs a $digest"
date: 2013-08-06 15:06
comments: true
categories: [$apply, $digest, $watch, advanced]
---
{% raw %}
Angular users want to know how data-binding works. There is a lot of vocabulary around this: `$watch`, `$apply`, `$digest`, `dirty-checking`... What are they and how do they work? Here I want to address all those questions, which are well addressed in the documentation, but I want to glue some pieces together to address everything in here, but keep in mind that I want to do that in a simple way. For more technical issues, check the source.

Let's start from the beginning.
<!--more-->
## The browser events-loop and the Angular.js extension

Our browser is waiting for events, for example the user interactions. If you click on a button or write into an input, the event's callback will run inside Javascript and there you can do any DOM manipulation, so when the callback is done, the browser will make the appropiate changes in the DOM.

Angular extends this events-loop creating something called `angular context` (remember this, it is an important concept). To explain what this context is and how it works we will need to explain more concepts.

## The $watch list

Every time you bind something in the UI you insert a `$watch` in a `$watch list`. Imagine the `$watch` as something that is able to detect changes in the model it is watching (bear with me, this will be clear soon). Imagine you have this:

```html index.html
User: <input type="text" ng-model="user" />
Password: <input type="password" ng-model="pass" />
```

Here we have `$scope.user`, which is bound to the first input, and we have `$scope.pass`, which is bound to the second one. Doing this we add two `$watch` to the `$watch list`.

```javascript controllers.js
app.controller('MainCtrl', function($scope) {
	$scope.foo = "Foo";
	$scope.world = "World";
});
```

```html index.html
Hello, {{ World }}
```

Here, even though we have two things attached to the `$scope`, only one is bound. So in this case we only created one `$watch`.

```javascript controllers.js
app.controller('MainCtrl', function($scope) {
	$scope.people = [...];
});
```

```html index.html
<ul>
	<li ng-repeat="person in people">
		{{person.name}} - {{person.age}}
	</li>
</ul>
```

How many `$watch` are created here? Two for each person (for name and age) in people plus one for the ng-repeat. If we have 10 people in the list it will be `(2 * 10) + 1`, AKA `21` `$watch`.

So, everything that is bound in our UI using directives creates a `$watch`. Right, but when are those `$watch` created?

When our template is loaded, AKA in the `linking phase`, the compiler will look for every directive and creates all the `$watch` that are needed. This sounds good, but... now what?

## $digest loop

Remember the extended `event-loop` I talked about? When the browser receives an event that can be managed by the `angular context` the `$digest` loop will be fired. This loop is made from two smaller loops. One processes the `$evalAsync` queue and the other one processes the `$watch` list, which is the subject of this article.

What is that process about? The `$digest` will loop through the list of `$watch` that we have, asking this:

- Hey `$watch`, what is your value?
	- It is `9`
- Alright, has it changed?
	- No, sir.
- (nothing happens with this one, so it moves to the next)
- You, what is your value?
	- It is `Foo`.
- Has it changed?
	- Yes, it was `Bar`.
- (good, we have a DOM to be updated)
- This continues until every `$watch` has been checked.

This is the `dirty-checking`. Now that all the `$watch` have been checked there is something else to ask: Is there any `$watch` that has been updated? If there is at least one of them that has changed, the loop will fire again until all of the `$watch` report no changes. This is to ensure that every model is clean. Have in mind that if the loop runs more than 10 times, it will throw an exception to prevent infinite loops.

When the `$digest loop` finishes, the DOM makes the changes.

Example:

```javascript controllers.js
app.controller('MainCtrl', function() {
	$scope.name = "Foo";

	$scope.changeFoo = function() {
		$scope.name = "Bar";
	}
});
```

```html index.html
{{ name }}
<button ng-click="changeFoo()">Change the name</button>
```

Here we have only one `$watch` because ng-click doesn't create any watches (the function is not going to change :P).

- We press the button.
- The browser receives an event which will enter the `angular context` (I will explain why, later in this article).
- The `$digest loop` will run and will ask every `$watch` for changes.
- Since the `$watch` which was watching for changes in `$scope.name` reports a change, if will force another $digest loop.
- The new loop reports nothing.
- The browser gets the control back and it will update the DOM reflecting the new value of `$scope.name`

The important thing here (which is seen as a pain-point by many people) is that EVERY event that enters the `angular context` will run a `$digest loop`. That means that every time we write a letter in an input, the loop will run checking every `$watch` in this page.

## Entering the angular context with $apply

What says which events enter the angular context and which ones do not? `$apply`

If you call `$apply` when an event is fired, it will go through the `angular-context`, but if you don't call it, it will run outside it. It is as easy as that. So you may now ask... That last example does work and I haven't called `$apply`, why? Angular will do it for you. So if you click on an element with `ng-click`, the event will be wrapped inside an `$apply` call. If you have an input with `ng-model="foo"` and you write an `f`, the event will be called like this: `$apply("foo = 'f';")`, in other words, wrapped in an `$apply` call.

## When angular doesn't use $apply for us

This is the common pain-point for newcomers to Angular. Why is my jQuery not updating my bindings? Because jQuery doesn't call `$apply` and then the events never enter the `angular context` and then the `$digest loop` is never fired.

Let's see an interesting example:

Imagine we have the following directive and controller:

```javascript app.js
app.directive('clickable', function() {

return {
  restrict: "E",
  scope: {
    foo: '=',
    bar: '='
  },
  template: '<ul style="background-color: lightblue"><li>{{foo}}</li><li>{{bar}}</li></ul>',
  link: function(scope, element, attrs) {
    element.bind('click', function() {
      scope.foo++;
      scope.bar++;
    });
  }
}

});

app.controller('MainCtrl', function($scope) {
  $scope.foo = 0;
  $scope.bar = 0;
});
```

It binds `foo` and `bar` from the controller to show them in a list, then every time we click on the element, both `foo` and `bar` values are incremented by one.

What will happen if we click on the element? Are we going to see the updates? The answer is no. No, because the `click` event is a common event that is not wrapped into an `$apply` call. So that means that we are going to lose our count? No.

What is happening is that the `$scope` is indeed changing but since that is not forcing a `$digest loop`, the `$watch` for `foo` and the one for `bar` are not running, so they are not aware of the changes. This also means that if we do something else that does run an `$apply`, then all the `$watch` we have will see that they have changed and then update the DOM as needed.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/opimat/2/embed?live">Directive example</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

If we click on the directive (the blue zone) we won't see any changes, but if we click on the button to update the string next to it, we suddenly see how many times we clicked on the directive. Just what I said, the clicks on the directive won't trigger any `$digest loop` but when the button is clicked on, the `ng-click` will call `$apply` and it will run the `$digest loop`, so all the `$watch` we have are going to be checked for changes, and that includes the one for `foo` and the one for `bar`.

Now you are thinking that this is not what you want, you want to update the bindings as soon as you click on the directive. That is easy, we just need to call `$apply` like this:

```javascript
element.bind('click', function() {
  scope.foo++;
  scope.bar++;

  scope.$apply();
});
```

`$apply` is a function of our `$scope` (or `scope` inside a directive's link function) so calling it will force a `$digest loop` (except if there is a loop in course, in that case it will throw an exception, which is a sign that we don't need to call '$apply' there).

## Try it 

<a class="jsbin-embed" href="http://jsbin.com/opimat/3/embed?live">Directive example</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

It works! But there is a better way for using `$apply`:

```javascript
element.bind('click', function() {
	scope.$apply(function() {
		scope.foo++;
		scope.bar++;
	});
})
```

What's the difference? The difference is that in the first version, we are updating the values outside the `angular context` so if that throws an error, Angular will never know. Obviously in this tiny toy example it won't make much difference, but imagine that we have an alert box to show errors to our users and we have a 3rd party library that does a network call and it fails. If we don't wrap it inside an `$apply`, Angular will never know about the failure and the alert box won't be there.

So if you want to use a jQuery plugin, be sure you call `$apply` if you need to run a `$digest loop` to update your DOM.

Something I want to add is that some people "feel bad" having to call `$apply` because they think that they are doing something wrong. That is not true. It is just Angular that is not a magician and it doesn't know when a 3rd party library wants to update the bindings.

## Using $watch for our own stuff

You already know that every binding we set has its own `$watch` to update the DOM when is needed, but what if we want our own watches for our purposes? Easy.

Let's see some examples:

```javascript app.js
app.controller('MainCtrl', function($scope) {
  $scope.name = "Angular";
  
  $scope.updated = -1;
  
  $scope.$watch('name', function() {
    $scope.updated++;
  });
});
```

```html index.html
<body ng-controller="MainCtrl">
  <input ng-model="name" />
  Name updated: {{updated}} times.
</body>
```

That is how we create a new `$watch`. The first parameter can be a string or a function. In this case it is just a string with the name of what we want to `$watch`, in this case, `$scope.name` (notice how we just need to use `name`). The second parameter is what is going to happen when `$watch` says that our watched expression has changed. The first thing we have to know is that when the controller is executed and finds the `$watch`, it will immediately fire.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ucaxan/1/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

I initialized the `$scope.updated` to `-1` because as I said, the `$watch` will run once when it is processed and it will put the `$scope.updated` to 0.

Example 2:

```javascript app.js
app.controller('MainCtrl', function($scope) {
  $scope.name = "Angular";
  
  $scope.updated = 0;
  
  $scope.$watch('name', function(newValue, oldValue) {
    if (newValue === oldValue) { return; } // AKA first run
    $scope.updated++;
  });
});
```

```html index.html
<body ng-controller="MainCtrl">
  <input ng-model="name" />
  Name updated: {{updated}} times.
</body>
```

The second parameter of `$watch` receives two parameters. The new value and the old value. We can use them to skip the first run that every `$watch` does. Normally you don't need to skip the first run, but in the rare cases where you need it (like this one), this trick comes in handy.

Example 3:

```javascript app.js
app.controller('MainCtrl', function($scope) {
  $scope.user = { name: "Fox" };
  
  $scope.updated = 0;
  
  $scope.$watch('user', function(newValue, oldValue) {
    if (newValue === oldValue) { return; }
    $scope.updated++;
  });
});
```

```html index.html
<body ng-controller="MainCtrl">
  <input ng-model="user.name" />
  Name updated: {{updated}} times.
</body>
```

We want to `$watch` any changes in our `$scope.user` object. Same as before but using an object instead of a primitive.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ucaxan/3/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Uhm? It doesn't work. Why? Because the `$watch` by default compares the reference of the objects. In example 1 and 2, every time we modify `$scope.name` it will create a new primitive, so the `$watch` will fire because the reference of the object is new and that is our change. In this new case, since we are watching `$scope.user` and then we are changing `$scope.user.name`, the reference of `$scope.user` is never changing because we are creating a new `$scope.user.name` every time we change the input, but the `$scope.user` will be always the same.

That is obviously not the desired case in this example.

Example 4:

```javascript app.js
app.controller('MainCtrl', function($scope) {
  $scope.user = { name: "Fox" };
  
  $scope.updated = 0;
  
  $scope.$watch('user', function(newValue, oldValue) {
    if (newValue === oldValue) { return; }
    $scope.updated++;
  }, true);
});
```

```html index.html
<body ng-controller="MainCtrl">
  <input ng-model="user.name" />
  Name updated: {{updated}} times.
</body>
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ucaxan/4/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Now it is working! How? We added a third parameter to the `$watch` which is a `bool` to indicate that we want to compare the value of the objects instead of the reference. And since the value of `$scope.user` is changing when we update the `$scope.user.name` the `$watch` will fire appropriately.

There are more tips & tricks with `$watch` but these are the basics.


### Conclusion

Well, I hope you have learnt how data-binding works in Angular. I guess that your first impression is that this `dirty-checking` is slow; well, that is not true. It is fast as lightning. But yes, if you have something like 2000-3000 `$watch` in a template, it will become laggy. But I think that if you reach that, it would be time to ask an UX expert :P.

Anyway, in a future version of Angular and with the release of EcmaScript 6, we will have `Object.observe` which will improve the `$digest loop` a lot. Meanwhile there are some tips & tricks that I am going to cover in a future article.

On the other hand, this topic is not easy and if you find that I missed something important or there is anything completely wrong, please fill an issue at Github or write a pull request :).

{% endraw %}
