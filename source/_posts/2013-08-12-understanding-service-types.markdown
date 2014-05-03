---
layout: post
title: "understanding service types"
date: 2013-08-12 11:12
comments: true
categories: [services]
---

Angular comes with different types of services. Each one with its own use cases.

Something important that you have to keep in mind is that the services are always singleton, it doesn't matter which type you use. This is the desired behavior.

**NOTE**: A singleton is a design pattern that restricts the instantiation of a class to just one object. Every place where we inject our service, will use the same instance.

Let's start with my own opinion about services.
<!--more-->
## Constant

Example:

```javascript
app.constant('fooConfig', {
  config1: true,
  config2: "Default config2"
});
```

A constant is a useful service often used to provide default configurations in directives. So if you are creating a directive and you want to be able to pass options to it but also at the same time to give it some default configurations, a `constant` service is a good way to go.

The `constant` service expects a primitive or an object.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/2/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Value

Example:

```javascript
app.value('fooConfig', {
  config1: true,
  config2: "Default config2 but it can changes"
});
```

A `value` service is like the `constant` service. It accepts a primitive or an object. So... what's the difference between the two? The difference is that a `constant` service can be injected on a `config` function but `value` can't do that. That is why `constant` is commonly used for directive's configuration, because we can override it at configuration time.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/5/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Factory

Example:

```javascript
app.factory('foo', function() {
  var thisIsPrivate = "Private";
  function getPrivate() {
    return thisIsPrivate;
  }
  
  return {
    variable: "This is public",
    getPrivate: getPrivate
  };
});

// or..

app.factory('bar', function(a) {
  return a * 2;
});
```

The `Factory` is the most common used service. It is also the easiest to understand.

A `factory` is a service which can return any datatype. There is no opinion of how you need to create it, you only need to return something. When working with objects, I like to work with the [Revealing module pattern](http://addyosmani.com/resources/essentialjsdesignpatterns/book/#revealingmodulepatternjavascript), but you can use the approach you want.

As I said before, all types are singleton, so if we modify `foo.variable` in one place, the other places will have that change too.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/7/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Service

Example:

```javascript
app.service('foo', function() {
  var thisIsPrivate = "Private";
  this.variable = "This is public";
  this.getPrivate = function() {
    return thisIsPrivate;
  };
});
```

The `service` service works much the same as the `factory` one. The difference is that `service` receives a constructor, so when you use it for the first time, it will do a `new Foo();` to instantiate the object. Keep in mind that it will return the same object if you use this service again in other places.

In fact, it is the same thing as doing this:

```javascript
app.factory('foo2', function() {
  return new Foobar();
});


function Foobar() {
  var thisIsPrivate = "Private";
  this.variable = "This is public";
  this.getPrivate = function() {
    return thisIsPrivate;
  };
}
```

`Foobar` is a *class* and we instantiate it in our `factory` the first time we use it and then we return it. Like the service, the `Foobar` *class* will be instantiated only once and the next time we use the `factory` it will return the same instance again.

If we already have the class and we want to use it in our `service` we can do that like the following:

```javascript
app.service('foo3', Foobar);
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/8/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Provider

`Provider` is the big brother of `factory`. In fact our `factory` from the last example is something like this:

```javascript
app.provider('foo', function() {

  return {
    
    $get: function() {
      var thisIsPrivate = "Private";
      function getPrivate() {
        return thisIsPrivate;
      }
  
      return {
        variable: "This is public",
        getPrivate: getPrivate
      };
    } 
    
  };

});
```

A `provider` expects a `$get` function that will be what we inject into other parts of our application. So when we inject `foo` into a controller, what we inject is the `$get` function.

Why should we use this form when a `factory` is much simple? Because we can configure a `provider` in the config function. So we can do something like this:

```javascript
app.provider('foo', function() {
  
  var thisIsPrivate = "Private";

  return {
    
    setPrivate: function(newVal) {
      thisIsPrivate = newVal; 
    },
    
    $get: function() {
      function getPrivate() {
        return thisIsPrivate;
      }
  
      return {
        variable: "This is public",
        getPrivate: getPrivate
      };
    } 
    
  };

});

app.config(function(fooProvider) {
  fooProvider.setPrivate('New value from config');
});
```

Here we moved the `thisIsPrivate` outside our `$get` function and then we created a `setPrivate` function to be able to change `thisIsPrivate` in a config function. Why do we need to do this? Won't it be easier to just add the *setter* in the `factory`? This has a different purpose.

We want to inject a certain object but we want to provide a way to configure it for our needs. For example: a service that wraps a resource using jsonp and we want to be able to config which URL we want to use or, we are consuming a 3rd party service like `restangular` that allows us to configure it to our purposes.

Notice that we have to put `nameProvider` instead of just `name` in our config function. To consume it, we just need to use `name`.

Seeing this we realize that we already configured some services in our applications, like `$routeProvider` and `$locationProvider`, to configure our routes and html5mode respectively.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/9/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Bonus 1: Decorator

So you decided that the `foo` service I sent to you lacks a `greet` function and you want it. Will you modify the `factory`? No! You can decorate it:

```javascript
app.config(function($provide) {
  $provide.decorator('foo', function($delegate) {
    $delegate.greet = function() {
      return "Hello, I am a new function of 'foo'";
    };
    
    return $delegate;
  });
});
```

`$provide` is what Angular uses to create all of our services internally. We can use it by hand if we want to or just use the functions provided in our modules (we need to use `$provide` for decorating). `$provide` has a function, `decorator`, that lets us decorate our services. It receives the name of the service that we are decorating and the callback receives a `$delegate` which is our original service instance.

Here we can do what we want to decorate our service. In our case, we added a `greet` function to our original service. Then we return the new modified service.

Now when we consume it, it will have the new `greet` function as you will see in the `Try it`.

The ability to decorate services comes in handy when we are consuming 3rd party services and we want to decorate it without having to copy it in our project and then doing there the modifications.

**Note**: The `constant` service cannot be decorated.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/10/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Bonus 2: Creating new instances

Our services are singleton but we can create a singleton factory that creates new instances. Before you dive deeper, keep in mind that having singleton services is the way to go and we don't want to change that. Said that, in the **rare cases** you need to generate new instances, you can do that like this:

```javascript
// Our class
function Person( json ) {
  angular.extend(this, json);
}

Person.prototype = {
  update: function() {
    // Update it (With real code :P)
    this.name = "Dave";
    this.country = "Canada";
  }
};

Person.getById = function( id ) {
  // Do something to fetch a Person by the id
  return new Person({
    name: "Jesus",
    country: "Spain"
  });
};

// Our factory
app.factory('personService', function() {
  return {
    getById: Person.getById
  };
});
```

Here we create a `Person` object which receives some json to initialize the object. Then we created a function in our prototype (functions in the prototype are for the instances of the `Person`) and a function directly in `Person` (which is like a class function).

So we have a class function that will create a new `Person` object based on the id that we provide (well, it will in real code) and every instance is able to update itself. Now we just need to create a service that will use it.

Every time we call `personService.getById` we are creating a new `Person` object, so you can use this service in different controllers and even when the factory in a singleton, it generates new objects.

Kudos to [Josh David Miller](http://stackoverflow.com/a/16626908/123204) for his example.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/irebew/4/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Bonus 3: Coffeescript

Coffeescript can be handy with services since they provide a prettier way to create classes. Let's see an example of the `Bonus 2` using Coffeescript:

```
app.controller 'MainCtrl', ($scope, personService) ->
  $scope.aPerson = personService.getById(1)
  
app.controller 'SecondCtrl', ($scope, personService) ->
  $scope.aPerson = personService.getById(2)
  $scope.updateIt = () ->
    $scope.aPerson.update()
  
class Person

  constructor: (json) ->
    angular.extend @, json
    
  update: () ->
    @name = "Dave"
    @country = "Canada"
    
  @getById: (id) ->
    new Person
      name: "Jesus"
      country: "Spain"
      
app.factory 'personService', () ->
  {
    getById: Person.getById
  }
```

It is prettier now in my humble opinion.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/uyewoq/4/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

**NOTE**: This last one, being Coffeescript seems to fail a little bit with JSbin. Go to the Javascript tab and select Coffeescript to make it work.

## Conclusion

Services are one of the coolest features of Angular. We have a lot of ways to create them, we just need to pick the correct one for our use cases and implement it.

If you found any issue or you think that this can be improved, please leave an issue or pull request at Github. In any case, a comment will be appreciated :).

