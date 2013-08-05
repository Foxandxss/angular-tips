---
layout: post
title: "Why does Angular.js rock?"
date: 2013-08-01 18:21
comments: true
ngapp: angularrocks
categories: [beginners] 
---

Let's see if we can discover why :)

Angular.js is a MV* (Model - View - Whatever) Javascript framework which is maintained by Google which excels in the creation of `single-page-applications` or even for adding some "magic" to our classic web applications.

I could spend all the day writing sentences of why you should try Angular.js in your new project, but I feel it that would be better if we see it in action.
<!-- more -->
## Data binding and scopes

> The first question that usually comes to mind is: Does it support data binding?

Let's see an example of Angular.js' way of data binding:

{% raw %}
<div ng-non-bindable>
```html index.html
<body ng-app>
  <span>Insert your name:</span>
  <input type="text" ng-model="user.name" />
  <h3>Echo: {{user.name}}</h3>
</body>
```
</div>
In this little piece of code, there are a few things to explain but before that, I want you to get familiarized with the code:

## Try it

<body ng-app="app">
  <span>Insert your name:</span>
  <input type="text" ng-model="user.name" />
  <h3>Echo: {{user.name}}</h3>
</body>
***

**NOTE**: Don't worry too much about the `ng-app` thing at this moment.

As you see, what we write in the input, is echoed after it. But how? In plain words, we can make a two-way binding in the input thanks to the `ng-model` directive (more on directives later in the article).

Ok, but where are we saving that `user.name`? In our `$scope`. Every time we type something in our input, our `user.name` object in the scope is going to be updated. Then we can output our models thanks to Angular.js interpolation <span ng-non-bindable>`{{ ... }}`</span>. With this we can show the value of `user.name` in our HTML. With this, when we type a letter in the input, our `user.name` is saved into the scope and then we can see it in the HTML thanks to the interpolation.

Alright alright, that wasn't hard, but.... What is that `$scope` thing you're talking about? The `$scope` is basically the glue between our controllers and our templates. It is an object where we can put our models so we can achieve two-way data binding.

The idea is something like:
{% endraw %}

{% img /images/angularrocks/diag1.jpg %}

This means that we set `user.name` into our `$scope` from the template, so we can access it from our controller too.

Let's see a complex example:

{% raw %}

```javascript app.js
var app = angular.module('app', []);

app.controller('MainCtrl', function($scope) {
  $scope.message = 'World';
});
```

<div ng-non-bindable>
```html index.html
<body ng-app="app" ng-controller="MainCtrl">
  Hello, {{ message }}
</body>
```
</div>

## See it

Hello, World
***

The first thing we are doing here is defining our Angular application. To do that we just create an angular module which receives a name and an array of dependencies (Line 1).

With our `app` in place the next thing to do is to create our controller. We do this calling the `controller` method in our `app module`. We give it a name and a function.

The function receives the `$scope` (More on this later) that we are going to use for our two-way data binding.

Then we attach a string `message` in our `$scope`.

In our view you will notice that our `body` tags have things in it. What are those? They are `directives`, they teach new tricks to our html, and in this case, we are using two of them:

* `ng-app` tells angular that the body element contains our Angular application, that means that everything inside it will be treated by Angular. Normally you would use it in the `html` tags and from now on, I won't show it anymore. The parameter is the name of our app, so it matches the name we gave to it in the module.

* `ng-controller`: with this directive, we assign as our element's scope that controller. In this case `MainCtrl`.

Then we just interpolate our message in the template :)

This can be represented visually like so:

{% endraw %}

{% img /images/angularrocks/diag2.jpg %}

Because you're so smart, I know you have a question: Can't we bind functions to our `$scope` ?

Of course!

{% raw %}

```javascript app.js
var app = angular.module('app', []);

app.controller('MainCtrl', function($scope) {
  $scope.greet = function() {
    $scope.message = "Hello, " + $scope.user.name;
  }
});
```
<div ng-non-bindable>
```html index.html
<body ng-controller="MainCtrl">
  What's is your name?:
  <input type="text" ng-model="user.name" />
  <button ng-click="greet()">Click here!</button>
  <h3>{{ message }}</h3>
</body>
```
</div>

## Try it

<div ng-controller="FuncCtrl">
  What's is your name?:
  <input type="text" ng-model="user.namee" />
  <button ng-click="greet()">Click here!</button>
  <h3>{{ message }}</h3>  
</div>
***

If we look into the controller, we can see how we attached to the `$scope` a function. That function will attach a message to the `$scope` as the result of a concatenation of a string and the content that was bound to our input `$scope.user.name`

Then in the HTML we created a button and we used `ng-click` directive. In short this directive makes the element clickable so upon a click it will execute the function that we assigned to it `greet()`.

**NOTE**: You will notice that pressing `enter` in the input doesn't work. That is normal, I wanted to show how `ng-click` works :)

{% endraw %}

{% img /images/angularrocks/diag3.jpg %}

## Directives

So what are these directives about?

A directive is a way of teaching HTML new tricks. HTML is really powerful but sometimes we need more.

And you think... Is that really needed? See yourself:

```html jquery_index.html
<body>
	<div id="chart"></div>
</body>
```

What is this code doing? Prff I don't have a clue, I see an id there, but who knows.

Then we look in one of our 30 javascript files and we saw:

```javascript charts.js
$('#chart').pieChart({ ... });
```

Aha! So it is the container of a pie chart.

What's the problem? You can't figure out what your page does if you don't look at every javacript file that is attached to it.

Then look at this code of an Angular app:

```html angular_index.html
<body>
	<pie-chart width="400" height="400" data="data"></pie-chart>
</body>
```

Isn't this more clear? With a simple look we know that we are adding a pie chart, and not only that, we can see how big it is and what data it has assigned.

As a curiosity, you can check a example `pie-chart` I did for fun [here](http://t.co/7vK8v2Om0N).

### Built-in directives

Angular comes with a lot of built-in directives, let's analyze some of them, but we already saw `ng-app`, `ng-controller`, `ng-click`, `ng-model` (You see the pattern here, `ng` is a diminutive of Angular).

Imagine that we have a portion of our page that we want to show only if a certain property is true:

<div ng-non-bindable>
```html
<button ng-click="show = !show">Show</button>
 <div ng-show="show">
   I am only visible when show is true.
 </div>
```
</div>

## Try it

<button ng-click="show = !show">Show</button>
 <div ng-show="show">
   I am only visible when show is true.
 </div>
***

With `ng-show` we show the element (and childs) only if the expression, in our case the value of the binding, is true.

Note how we used `ng-click` this time. There is no need of create a function in our controller (we don't even have a controller this time!), we can write an expression as the directive's argument and in this case, we toggle the value of `show`. Which starts `undefined` and is set to true with the first click.

We also have `ng-hide` which does the opposite :)

Let's go to something funnier. What if we have an array of objects and we want to list it?

```javascript app.js
var app = angular.module('app', []);

app.controller('MainCtrl', function($scope) {
  $scope.developers = [
      {
        name: "Jesus", country: "Spain"
      },
      {
        name: "Dave", country: "Canada"
      },
      {
        name: "Wesley", country: "USA"
      },
      {
        name: "Krzysztof", country: "Poland"
      }
    ];
});
```

{% raw %}
<div ng-non-bindable>
```html index.html
<body ng-app="app" ng-controller="MainCtrl">
 <ul>
   <li ng-repeat="person in developers">
     {{person.name}} from {{person.country}}
   </li>
 </ul>
</body>
```
</div>
{% endraw %}

## See it

<body ng-controller="MainCtrl">
 <div ng-repeat="person in developers">
  <span ng-bind="person.name"></span> from <span ng-bind="person.country"></span>
 </div>
</body>

***

**NOTE**: In the `See it` I had to modify the code because it is really tricky to add interactivity to the articles.

Well, we define a list of objects in our controller, nothing that would surprise you and then we use the `ng-repeat` directive in our HTML.

How does it work?

`ng-repeat` will create a new template for every item in the collection. So in our case and since we have 4 items in it, it will create this piece of code four times:

{% raw %}
<div ng-non-bindable>
```html 
<li ng-repeat="person in developers">
 {{person.name}} from {{person.country}}
</li>
```
</div>
{% endraw %}

Every copy will contain its **own scope**. So now in this template we don't have the controller as the scope, in this case, the person is the scope. This means that we don't have access to our parent controller from here (This isn't totally true, there are ways to access it).

Let me show it visually:

{% img /images/angularrocks/diag4.jpg %}

Much better :)

### Can we create our own directives?

What do you expect? Of course we can!

We can create almost anything. Directives for modal dialogs, accordions, paginators, charts, search form...

Are they always that visual? No, you can create directives that won't do anything visual.

Let's begin with an example.

Going back to our greet example, we had this:
{% raw %}
<div ng-non-bindable>
```html form.html
<body ng-controller="MainCtrl">
  What's is your name?:
  <input type="text" ng-model="user.name" />
  <button ng-click="greet()">Click here!</button>
  <h3>{{ message }}</h3>
</body>
```
</div>

It works great but what if we want the input to have the focus when the page loads? jQuery right? We grab the input and we call the `focus()` method in it. **NO**.

With directives we want our HTML to be as self-descriptive as possible so we are going to create a `focus` directive.

```javascript focus.js
app.directive('focus', function() {
  return {
    link: function(scope, element, attrs) {
      element[0].focus();
    }
  };
});
```

So we are calling the *directive* function of our *app* object, this like our controller receives the name of the directive and a function.

Directives is the most complex thing in the entire Angular.js and for the sake of simplicity (this is like a showcase article :P) I won't give excesive details (but I promise several articles on the subject in a future).

A directive needs to return an object and there we can define some attributes in it, in our case, none. A directive can also return a link function. Is in the link function where we put most of our template logic.

We can register DOM listeners here, update our DOM, etc.

The link function receives 3 parameters (Actually 4, but that is more advanced), the `scope`, the `element` itself and its attributes `attr`.

Here we can bind our element to `click` event or `mouseenter` among others.

In our case we grab the first element (our input) and call the `focus` function in it.

If you're wondering how can we work with the element, check the official doc: [Element API](http://docs.angularjs.org/api/angular.element)

Simple as that. The only thing needed now is to use it. Just put the directive name in the element you want to grab your focus:

<div ng-non-bindable>
```html form.html
<body ng-controller="MainCtrl">
  What's is your name?:
  <input type="text" focus ng-model="user.name" />
  <button ng-click="greet()">Click here!</button>
  <h3>{{ message }}</h3>
</body>
```
</div>

**NOTE**: There is no `Try it` this time, seems like octopress is grabbing the focus too and my example won't work here.

Fair enough, this directive was really simple.

What about a directive that will render some HTML?

Here it is:

```javascript hello.js
app.directive('hello', function() {
  return {
    restrict: "E",
    replace: true,
    template: "<div>Hello readers, thank you for coming</div>"
  }
});
```

This one returns the object and in there we set some attributes (as we said earlier).

* restrict: A directive can be placed in several places:
  * **A**ttribute, like: `<div foo></div>`
  * **E**lement, like: `<foo></foo>`
  * **C**lass, like: `<div class="foo"></div>`
  * Co**M**ment, like: `<!-- directive: foo -->`
* replace: If we set this to true, our element will be replaced with our new template
* template: Here we put the template we want to append (or replace as we have seen) into the element.

We are restricting our directive to element (is restricted to attribute by default) and we specifying a template to replace our element.

There are a lot more options that we can use in our directives, but these will do the work we need.

Note that we are not using a link function here, that is because we need no logic here.

How to use it? Easy:

<div ng-non-bindable>
```html index.html
<hello></hello>
```
</div>

## See it

Hello readers, thank you for coming

***

And if you inspect the code, you will see that the `<hello></hello>` as been replaced for `<div>Hello readers, thank you for coming</div>` as we expected.

## Filters

Imagine that we have a view where we show a shopping basket:

<div ng-non-bindable>
```html
<span>There are 13 phones in the basket. Total: {{ 1232.12 }}</span>
```
</div>

## See it

There are 13 phones in the basket. Total: 1232.12

***

Notice how can we use some basic expressions in the interpolation. In this case we are printing a number. We can read it and realize that we are talking about $1,232.12 but wouldn't be better if we can convert that number into money?

Of course, and that is really easy with filters. There is an example of the `currency` filter:

<div ng-non-bindable>
```html
<span>There are 13 phones in the basket. Total: {{ 1232.12 | currency }}</span>
```
</div>

## See it

There are 13 phones in the basket. Total: $1,232.12

***

Much better, isn't it?

As you can see, we can use a filter using the `|` character. Is like we do in a Unix environment, piping.

We can pipe one or more filters in a expression.

For example, we can specify an order in a `ng-repeat`. Let's try it out with the developers collection we made earlier:

<div ng-non-bindable>
```html
<ul>
  <li ng-repeat="person in developers | orderBy:'name'">
    {{ person.name }} from {{ person.country }}
  </li>
</ul>
```
</div>

## See it

<body ng-controller="MainCtrl">
 <div ng-repeat="person in developers | orderBy:'name'">
  <span ng-bind="person.name"></span> from <span ng-bind="person.country"></span>
 </div>
</body>

***

We can see here something interesting. We can pass parameters to the filters.

The `orderBy` filters receives a predicate which will use to order. In our case we passed `name` so we will order the list by name. Note that if we put `-name` as the predicate, we will order ir in reverse mode :)

So you are thinking at this moment... Not bad, they can be useful...

Ok, this next one will blow your mind.

Imagine that we don't have 4 developers, we have 300 and we want to filter them (by name, country...). So you start planning how to filter your collections, swap the non-filtered one with the filtered...

It is a way more simple (Again using the same controller as before with the list of developers):

<div ng-non-bindable>
```html
<body ng-controller="MainCtrl">
  Search: <input ng-model="search" type="text" />
   <ul>
     <li ng-repeat="person in developers | filter:search">
       {{ person.name }} from {{ person.country }}
     </li>
   </ul>
</body>
```
</div>

## Try it

<body ng-controller="MainCtrl">
 Search: <input ng-model="search" type="text" />
 <div ng-repeat="person in developers | filter:search">
  <span ng-bind="person.name"></span> from <span ng-bind="person.country"></span>
 </div>
</body>

***

Wow! That is awesome. We only needed a filter!

With the `filter` filter, you only need to pass a parameter which will contain the filter itself. In this case, we pass `search` which is bound to our scope and it is populated by our input.

If you want, you can make the filter more precisely, you can do something like this:

<div ng-non-bindable>
```html
<body ng-controller="MainCtrl">
  Search: <input ng-model="search.name" type="text" />
   <ul>
     <li ng-repeat="person in developers | filter:search">
       {{ person.name }} from {{ person.country }}
     </li>
   </ul>
</body>
```
</div>

With this (notice how we are binding to `search.name` in the input) we are now filtering just by name. The filter parameter doesn't change. It is bound to the `search` object and it will find there a name populated with by our input and then filter by name.

I hope you're excited with this too :)

What about creating our own filter? Yeah!

A filter to capitalize the text. How? Like this:

```javascript capitalize.js
app.filter('capitalize', function() {
    return function(input, param) {
        return input.substring(0,1).toUpperCase()+input.substring(1);
    }
});
```

A filter returns a function which receives the input (the result of the interpolation) and the filter parameter. The function returns our new input. In this case it capitalize the input.

Then, we just need to use it:

<div ng-non-bindable>
```html
<span>{{ "this is some text" | capitalize }}</span>
```
</div>

## See it

This is some text

***

We had to wrap our string into quotes to make it a literal string. Then we "pipe" our capitalize filter and it works!

## Services

And our last section for this article, services. What is a service? They are singleton classes that provides certain functionality to our app.

Instead of splitting our app logic into the controllers, we can put that logic into different services.

Angular has a lot of built-in services, managing `$http` requests, `$q` for promises, etc. But in this part we are not going to talk about any built-in service, because they are more complex to explain and that belongs to a new article. Instead we are going to create a simple one.

One of the more common uses for a service is to share information along controllers. Every controller has its own scope so you can't bind to other controller scope. The solution is to use services, so you can have the data in one central place and then use it where you want.

First, let's try this without the service to see the problem:

<div ng-non-bindable>
```html index.html
<div ng-controller="MainCtrl">
  MainCtrl:
  <input type="text" ng-model="user.name">
</div>
<div ng-controller="SecondCtrl">
  SecondCtrl:
  <input type="text" ng-model="user.name">
</div>
```
</div>

```javascript controllers.js
app.controller('MainCtrl', function($scope) {
  
});

app.controller('SecondCtrl', function($scope) {
  
});
```

## Try it

<div ng-controller="MainCtrl">
  MainCtrl:
  <input type="text" ng-model="user.namey">
</div>
<div ng-controller="SecondCtrl">
  SecondCtrl:
  <input type="text" ng-model="user.namez">
</div>

***
{% endraw %}

Well, since you have your inputs bound to the same model, you expect that writing in a box, will update the other one. Like this:

{% img /images/angularrocks/diag5.jpg %}

That is not true, what is really happening is this:

{% img /images/angularrocks/diag6.jpg %}

So we are going to fix this with a service which will hold the user name so we can use it in both controllers:

```javascript user_information.js
app.factory('UserInformation', function() {
  var user = {
    name: "Angular.js"
  };
  
  return user;
});
```

We used the `factory` function of our app module to create a service. There are other advanced ways to create services (using the `service` and `provider` functions, but that belongs to another post).

There are several ways to create a service, and in this case, we are creating a private `user` object with a predefined name and then we are returning it.

Good, how can I use this in our controllers? Like this:

```javascript controllers.js
app.controller('MainCtrl', function($scope, UserInformation) {
  $scope.user = UserInformation;
});

app.controller('SecondCtrl', function($scope, UserInformation) {
  $scope.user = UserInformation;
});
```

With this we get something like:

{% img /images/angularrocks/diag7.jpg %}

## Try it

<div ng-controller="MainCtrl">
  MainCtrl:
  <input type="text" ng-model="usera.name">
</div>
<div ng-controller="SecondCtrl">
  SecondCtrl:
  <input type="text" ng-model="usera.name">
</div>

***

Well this seems to work.

Now our `$scope.user` in both `MainCtrl` and `SecondCtrl` is using `UserInformation` and since the service is a singleton, if we update it from one controller, the other will be updated too. So your question now is. Where the `UserInformation` parameter comes from?

Angular uses `dependency injection` to inject the services where we need them. Explaining how the `dependency injection` works is not a subject for this article. But in plain words, when we create a service, we can inject it in any controller, directive or even in another service. How? Just passing as a parameter the name of the service.

You're maybe wondering if this is the same for `$scope`. Well, `$scope` is maybe one of the exceptions that is not really a service that is injected into our controllers.

## Conclusions

With this we end the first (but not the last :)) article of this blog.

Angular.js is a great framework and I think that you are already in love with it. I expect to see you here for the next articles!

Last but not least, I want to thank `Auser` from [ng-newsletter](http://www.ng-newsletter.com/) which told to me how to add this interactivity to my blog.

I hope you enjoyed it and I expect your comments :)

<script type="text/javascript">
	var app = angular.module('angularrocks', []);

	app.controller('MainCtrl', function($scope, UserInformation) {

    $scope.usera = UserInformation;
	  $scope.greet = function() {
	    $scope.message = "Hello, " + $scope.user.name;
	  }

	  $scope.developers = [
      {
        name: "Jesus", country: "Spain"
      },
      {
        name: "Dave", country: "Canada"
      },
      {
        name: "Wesley", country: "USA"
      },
      {
        name: "Krzysztof", country: "Poland"
      }
    ];
	});

  app.controller('SecondCtrl', function($scope, UserInformation) {
    $scope.usera = UserInformation;
  });

	app.controller('FuncCtrl', function($scope) {
    $scope.greet = function() {
      $scope.message = "Hello, " + $scope.user.namee;
    }
  });
  app.factory('UserInformation', function() {
    var user = {
      name: "Angular.js"
    };
    
    return user;
  });
</script>