---
layout: post
title: "Experiment: decorating directives"
date: 2013-09-02 11:26
comments: true
categories: [experiment, directives]
---

**DISCLAIMER**: This is an experiment, it is not something officially supported and by that, this is not meant for beginners. Use it at your own risk and take notice that a bad use of it can break the internet.

Jokes aside, this could be useful in a bunch of use cases. It is up to you to decide.

Ever had a 3rd party directive where you wished it had any extra behavior you wanted? I did.
<!--more-->
Let's see an example:

```javascript foo.js
app.directive("foo", function() {
  return {
    replace: true,
    template: '<div>This is foo directive</div>'
  };
});
```

```html index.html
<body ng-controller="MainCtrl">
  <div foo></div>
</body>
```

You think that this directive is awesome (really? :P) but you're one of those developers that likes to use directives as a comments. The problem is that the directive doesn't allow it and you don't see why it shouldn't. What can you do here? We can decorate it! How? Using the `$provide.decorator` we use to decorate services. Really? See:

```javascript foo_decorator.js
app.config(function($provide) {
  $provide.decorator('fooDirective', function($delegate) {
    var directive = $delegate[0];
    
    directive.restrict = "AM";
    return $delegate;
  });
});
```

What's going on here? We pass the directive name (with the `Directive` suffix) into the `$provide.decorator` and then the callback receives the original directive inside an array. We store the directive itself in a variable and we just need to change the `restrict` to what we want, AKA restricted to attributes and comments. Finally we just return the delegate.

Now we can do this:

```html index.html
<body ng-controller="MainCtrl">
  <div foo></div>
  <!-- directive: foo -->
</body>
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/OraVoJOT/1/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

The bright side of this way is that we don't need to create an extra directive to hold our new behavior, we just decorate the original one, so we just need to use it as before, the only difference is that now it has a decorated behavior.

Let's see another example:

```javascript foo.js
app.directive("foo", function() {
  return {
    restrict: 'E',
    scope: {
      name: "@"
    },
    replace: true,
    template: '<div>Hello, {{name}}</div>',
    link: function(scope, element, attrs) {
      if (angular.isDefined(attrs.name)) {
        attrs.name = attrs.name + "!";
      }
    }
  };
});
```

```html index.html
<body ng-controller="MainCtrl">
  <foo name="Angular Tips"></foo>
</body>
```

A more complicated directive. It receives a name via attribute and we display it on the template with an exclamation mark.

We got it but we really need to run a function to log how many times a user has clicked in the directive. That means that we need to extend our isolated scope and link function. Let's go:

```javascript foo_decorator.js
app.config(function($provide) {
  $provide.decorator('fooDirective', function($delegate) {
    var directive = $delegate[0];
    
    directive.scope.fn = "&";
    var link = directive.link;
    
    directive.compile = function() {
      return function(scope, element, attrs) {
        link.apply(this, arguments);
        element.bind('click', function() {
          scope.$apply(function() {
            scope.fn();
          });
        });
      };
    };
    
    return $delegate;
  });
});
```

First we just added a new key to our isolated scope for the function, then the idea is to **extend** our `link` function with new functionality. To do that, we first hold the old `link` function into a variable and then we extend it. How?

Since the `link` function is just syntactic sugar, we need to create a compile function which will return our new `link` function. Inside there, we call `apply` in the old `link` function to get the old functionality. With that set, we just need to add the extra behavior, in this case we bind the `click` event into the element which will call the new function upon click.

We just need to add the following code:
{% raw %}
```html index.html
<body ng-controller="MainCtrl">
	<foo name="Angular Tips" fn="updateCounter()"></foo>
	Times clicked: {{counter}}
</body>
```

```javascript controller.js
app.controller("MainCtrl", function($scope) {
  $scope.counter = 0;
  
  $scope.updateCounter = function() {
    $scope.counter++;
  };
});
```
{% endraw %}
As you see, now we can use the `fn` attribute on our directive and it works as expected.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/OraVoJOT/2/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Works like a charm!

I like this solution, but what happens if we also have a `compile` function? Wouldn't that remove it? Yes, but we can avoid that. Let's see:


```javascript foo.js
app.directive("foo", function() {
  return {
    restrict: 'E',
    scope: {
      name: "@"
    },
    replace: true,
    template: '<div>Hello, {{name}}</div>',
    compile: function(tElement, tAttrs) {
      tElement.append('<div>Added in compile</div>');
      
      return function(scope, element, attrs) {
        if (angular.isDefined(attrs.name)) {
          attrs.name = attrs.name + "!";
        }
      };
    }
  };
});
```

It is the last directive but now it appends a new *div* into the *DOM*. How can we work with the `link` function in this case?:

```javascript foo_decorator.js
app.config(function($provide) {
  $provide.decorator('fooDirective', function($delegate) {
    var directive = $delegate[0];
    
    var compile = directive.compile;
    
    directive.compile = function(tElement, tAttrs) {
      var link = compile.apply(this, arguments);
      tElement.append('<div>Added in the decorator</div>');
      return function(scope, elem, attrs) {
        link.apply(this, arguments);
        // We can extend the link function here
      };
    };
    
    return $delegate;
  });
});
```

Just the same idea! We grab the old `compile` function and we create a new one. Notice that we put proper parameters this time because we have a real `compile` function in our directive. Then we call `apply` as we did before but since our `compile` returns the `link` function, we hold it in a new variable. The rest is much the same, we return a new `link` function that will be extended with our new stuff.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/OraVoJOT/3/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Working as expected. What about... controllers? Well there are two possibilities. If the `controller` is an inline function in our directive, it is much the same, holding the old one, extending it as we did with `compile` and `link`.

But if the `controller` just hold the name of the controller it wants to use, the decoration becomes a little bit problematic.

Let's see:

```javascript foo.js
app.controller("fooCtrl", function($scope) {
  $scope.name = "from the directive controller";
});

app.directive("foo", function() {
  return {
    restrict: 'E',
    replace: true,
    template: '<div>Hello, {{name}}</div>',
    controller: 'fooCtrl'
  };
});
```

Sure, the directive is good enough, but we would love to change `$scope.name` after three seconds to something else. To do that we need to decorate the controller:

```javascript foo_decorator.js
app.config(function($provide) {
  $provide.decorator('fooDirective', function($delegate, $controller) {
    var directive = $delegate[0];
    
    var controllerName = directive.controller;
    directive.controller = function($scope, $timeout) {
      angular.extend(this, $controller(controllerName, {$scope: $scope}));
      
      $timeout(function() {
        $scope.name = "from the decorator now";
      }, 3000);
    };
    
    return $delegate;
  });
});
```

We assign the controller name (if the controller is inline, `directive.controller` will hold the actual controller instead of the name) into a variable and then we create a new controller in our directive. Since we need to use `$timeout` we inject it too.

The difference here is since we don't hold the actual controller but a name, we need to use `$controller` (injected in the decorator) to fetch the actual controller. To make it work we pass the controller name and all the parameters the original controller has, AKA the `$scope`.

Here we can't use `apply`, instead, we used `angular.extend` to "apply" the old behavior. Then we just needed to add the new behavior.

There is other way (just the important bits):

```javascript
directive.controller = function($scope, $timeout) {
  var controller = $controller(controllerName, {$scope: $scope});
  
  $timeout(function() {
    $scope.name = "from the decorator now";
  }, 3000);
  
  return controller;
};
```

Instead of using `angular.extend` we just return the old controller at the end. If you need to override old stuff, just use `controller.xxx` :)

## Try it

<a class="jsbin-embed" href="http://jsbin.com/OraVoJOT/4/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Conclusion

Two things to have in mind. First: The decorators needs to appear after the directives or they won't find them. Second: If you want to decorate let's say the `accordion` of `ui-bootstrap` you should apply the decorator in a config function on the `ui-bootstrap` module, not your application one.

This experiment could be useful in those cases were we have some 3rd party directive that we need it do to something else. Is not something for everyday use but I think that the knowledge worth it.

I remember the day I spent like 2 hours creating a new directive to extend the functionality of the `accordion` to log when a user clicks on the header. A lot of DOM manipulation, fighting with `jqLite` limitations and finally, we got it working. With this, it is just... 5 lines of code?

I also want to thanks my good friend [Rodric Haddad](https://twitter.com/rodyhaddad) which helped me a lot with the brainstorming.
