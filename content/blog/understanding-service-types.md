+++
tags = ["services"]
date = "2013-08-12T11:12:45+01:00"
title = "Understanding service types"


+++

**Last update: June 2014**. I have partially rewritten this article to provide more technical details and also to show their differences more clearly.

***

Angular comes with different types of services. Each one with its own use cases.

Something important that you have to keep in mind is that the services are always singleton, it doesn't matter which type you use. This is the desired behavior.

**NOTE**: A singleton is a design pattern that restricts the instantiation of a class to just one object. Every place where we inject our service, will use the same instance.

<!--more-->
## Provider

`Provider` is the parent of almost all the other services (all but constant) and it is also the most complex but more configurable one.

Let's see a basic example:

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

A `provider` on its simplest form, just needs to return a function called `$get` which is what we inject on the other components. So if we have a controller and we want to inject this `foo` provider, what we inject is the `$get` function of it.

Why should we use a `provider` when a `factory` is much simple? Because we can configure a `provider` in the config function. We can do something like this:

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

Here we moved the `thisIsPrivate` outside our `$get` function and then we created a `setPrivate` function to be able to change `thisIsPrivate` in a config function. Why do we need to do this? Won't it be easier to just add the *setter* in the `$get`? This has a different purpose.

Imagine we want to create a generic library to manage our models and make some REST petitions. If we hardcode the endpoints URLs, we are not making it any generic, so the idea is to be able to configure those URLs and to do so, we create a provider and we allow those URLs to be configured on a config function.

Notice that we have to put `nameProvider` instead of just `name` in our config function. To consume it, we just need to use `name`.

Seeing this we realize that we already configured some services in our applications, like `$routeProvider` and `$locationProvider`, to configure our routes and html5mode respectively.

`Providers` have two different places to make injections, on the provider constructor and on the `$get` function. On the provider constructor we can only inject other providers and constants (is the same limitation as the `config` function). On the `$get` function we can inject all but other providers (but we can inject other provider's `$get` function).

Remember: To inject a provider you use: *name + 'Provider'* and to inject its `$get` function you just use *name*

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/9/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Factory

`Provider` are good, they are quite flexible and complex. But what if we only want its `$get` function? I mean, no configuration at all. Well, in that cases we have the `factory`. Let's see an example:

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

As you see, we moved our `provider` `$get` function into a `factory` so we have what we had on the first `provider` example but with a much simpler syntax. In fact, internally a `factory` is a `provider` with only the `$get` function.

As I said before, all types are singleton, so if we modify `foo.variable` in one place, the other places will have that change too.

We can inject everything but providers on a `factory` and we can inject it everywhere except on the `provider` constructor and config functions.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/7/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Value

`Factory` is good, but what if I just want to store a simple value? I mean, no injections, just a simple value or object. Well angular has you covered with the `value` service:

Example:

```javascript
app.value('foo', 'A simple value');
```

Internally a `value` is just a factory. And since it is a `factory` the same injection rules applies, AKA can't be injected into `provider` constructor or config functions.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/12/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Service

So having the complex `provider`, the more simple `factory` and the `value` services, what is the `service` service? Let's see an example first:

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

The `service` service works much the same as the `factory` one. The difference is simple: The `factory` receives a function that gets called when we create it and the `service` receives a constructor function where we do a `new` on it (actually internally is uses `Object.create` instead of `new`).

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

`Foobar` is a *constructor function* and we instantiate it in our `factory` when angular processes it for the first time and then it returns it. Like the service, `Foobar` will be instantiated only once and the next time we use the `factory` it will return the same instance again.

If we already have the class and we want to use it in our `service` we can do that like the following:

```javascript
app.service('foo3', Foobar);
```

If you're wondering, what we did on `foo2` is actually what angular does with services internally. That means that `service` is actually a `factory` and because of that, same injection rules applies.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/8/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

## Constant

Then, you're expecting me to say that a `constant` is another subtype of `provider` like the others, but this one is not. A `constant` works much the same as a `value` as we can see here:

Example:

```javascript
app.constant('fooConfig', {
  config1: true,
  config2: "Default config2"
});
```

So... what's the difference then? A `constant` can be injected everywhere and that includes `provider` constructor and config functions. That is why we use `constant` services to create default configuration for directives, because we can modify those configuration on our config functions.

You are wondering why it is called `constant` if we can modify it and well that was a design decision and I have no idea about the reasons behind it.

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ayohuz/2/embed?live">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

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

`$provide` is what Angular uses internally to create all the services. We can use it to create new services if we want but also to decorate existing services. `$provide` has a method called `decorator` that allows us to do that. `decorator` receives the name of the service and a callback function that receives a `$delegate` parameter. That `$delegate` parameter is our original service instance.

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

## Conclusion

Services are one of the coolest features of Angular. We have a lot of ways to create them, we just need to pick the correct one for our use cases and implement it.

If you found any issue or you think that this can be improved, please leave an issue or pull request at Github. In any case, a comment will be appreciated :).
