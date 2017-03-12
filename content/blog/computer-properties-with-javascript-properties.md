+++
description = ""
date = "2013-02-03T16:48:57+01:00"
title = "Tip: computed properties with Javascript properties"
categories = []
tags = ["tip"]

+++

First, I apologize for not updating the blog as much as expected. I am kinda busy with other stuff and I am writing an Angular book. I want to write more so I am going to find some ideas that won't be covered in my book. Well, let's get started.

There is a question I see a lot about Angular: Does it support computed properties? Well, there is no direct support in the framework like with Ember, but you can certainly create computed properties. Let's see an example, the typical example:
<!--more-->
We have someone name, in two different variables: `$scope.firstName` and `$scope.lastName` and we want `$scope.fullName` to print it out. Let's see a first approach:

```javascript
var app = angular.module('app', []);

app.controller('MyCtrl', function($scope) {
  $scope.firstName = "John";
  $scope.lastName = "Doe";
  
  $scope.fullName = function() {
    return $scope.firstName + ' ' + $scope.lastName;
  };
  
  $scope.counter = -1;
  
  $scope.$watch($scope.fullName, function() {
    $scope.counter++;
  });
});
```

To create our computed property we used a function called `fullName`. That function will just return a concatenation of `firstName` and `lastName`. We also created a `$watch` just to see how can we use or computer property on a `$watch`.

What about the html?:

```html
<body ng-controller="MyCtrl">
  First name: <input ng-model="firstName" /><br>
  Last name: <input ng-model="lastName" /><br>
  Full name: {{fullName()}}<br>
  Number of times changed: {{counter}}
</body>
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/EGAWivu/1/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

What we notice here is how we use our computed property. Instead of `fullName` we are doing `fullName()`. That is expected because `fullName` is a function. That works and well, there is no problem about that, but some people doesn't like the extra `()` for the computed property. They feel like this is not a computed property but just a mere function (well, that is true actually). Can we do something about that? Yes!

Also, if you see the `$watch` syntax, what you do is pass directly `$scope.fullName` instead of just `'fullName'`. Nothing wrong here. 

`Ecmascript 5` came with [properties](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty), where we can have a custom getter and setter for a concrete property. Can we use it somehow? Yes!

```javascript
var app = angular.module('app', []);

app.controller('MyCtrl', function($scope) {
  $scope.firstName = "John";
  $scope.lastName = "Doe";
  
  Object.defineProperty($scope, 'fullName', {
    get: function() {
      return $scope.firstName + ' ' + $scope.lastName;
    }
  });
  
  $scope.counter = -1;
  
  $scope.$watch('fullName', function() {
    $scope.counter++;
  });
});
```

Here we defined an `Ecmascript 5` property where we pass the object to "augment" with a property, AKA `$scope` and the new property name, `fullName`. Then we just need to define a `get` function. That function will return the same concatenation as before. Notice how the `$watch` now works passing the name of the property as a string. What about the html?:

```html
<body ng-controller="MyCtrl">
  First name: <input ng-model="firstName" /><br>
  Last name: <input ng-model="lastName" /><br>
  Full name: {{fullName}}<br>
  Number of times changed: {{counter}}
</body>
```

Heey, we got rid of the `()`. Now it work like the other properties! We can also create a set method to be able to modify the computed property, but that is way trickier :P

## Try it

<a class="jsbin-embed" href="http://jsbin.com/EGAWivu/2/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Conclusion

Even when this is not really needed, it is a good tip to have under the sleeve.
