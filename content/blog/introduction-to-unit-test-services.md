+++
date = "2014-06-01T13:26:14+01:00"
tags = ["unit test"]
description = ""
title = "Introduction to unit test: services"
categories = []

+++

Testing a service is not much more difficult than [testing a filter](/blog/2014/04/introduction-to-unit-test-filters), in fact, the same rules applies. The difficulty comes on what you do with your service. It is not the same thing testing a service that holds data (a wizard for example) than a service that does RESTful stuff + cache. I plan to write more testing examples on the future but for this article we are going to set the basics :)
<!--more-->
So what are we going to do on this service? Well taking advantage of my [toastr](https://github.com/Foxandxss/angular-toastr) library, I thought about a logger service. What can we do with it? Let me think... Right, we could use it to log to the dev console using its `log`, `debug` and `error` functions and also optionally pop up a toast with proper colors to match those functions. Sounds good to me, let's go:

```javascript
describe('factory: Logger', function() {
  var logger, toastr;
  
  beforeEach(inject(function(_logger_) {
    logger = _logger_;
  }));
  
});
```

Well, we created a variable to hold our `logger` service and also one to hold the `toastr` service. Then we injected the logger and saved it. What should we do with the `toastr` service?

This is a common pain point for new users. I bet that the half of you would have this question here: How can I test that the toast is on the screen? The answer is: You don't care. This is a UNIT test, that means that you're testing that concrete unit and you shouldn't care about its dependencies. If it is another service you made, you would have tests for it and if it is a third party dependency, it has its own tests (or it should :P). So in this case, the `toastr` service is already tested so you don't have to care.

Alright, having that in mind, the common path here is to spy the functions we are going to use from the `toastr` service and also the functions from the console. I am going to show you two different ways:

The previous code would end like this:

```javascript
describe('factory: Logger', function() {
  var logger, toastr;
  
  beforeEach(module('app', function($provide) {
    toastr = {};
    
    toastr.info = jasmine.createSpy();
    toastr.warning = jasmine.createSpy();
    toastr.error = jasmine.createSpy();
    
    $provide.value('toastr', toastr);
  }));
  
  beforeEach(inject(function(_logger_) {
    logger = _logger_;
    
    spyOn(console, 'log');
    spyOn(console, 'debug');
    spyOn(console, 'error');
  }));  
});
```

For the console, we are going to stick on `spyOn` from jasmine as we did on a previous article, but for `toastr` we did something completely new. We replaced the `toastr` service with one we made right here, in other words, a complete mock.

Basically, when we loaded the `app` module (we do this on the `app` module because it is where the service is created or added as a dependency) we created a new `toastr` object and then we created 3 spies (more on this shortly). After that we just needed to create a new `value` service that will create/override the `toastr` one.

> If we have a service (of any kind) with a certain name and we after that create another service (of any kind) with that same name, it will be overriden. That is whycreating a simple `value` service will override the previous one. 

> If we load the original `toastr` library on the test, it will be overriden but in this case, we can just ignore the dependency and a new `toastr` service will be created. In any case we have what we need.

What about those `createSpy`? They do more or less the same as `spyOn`. What's the difference? `spyOn` is used to spy an existing function and `createSpy` will create a dummy spied function. Since our new `toastr` service has none, we can create spied functions from scratch, handy.

Alright, our preparations are done, let's write a couple of tests:

```javascript
it('should log using the log function but not toast', function() {
  logger.log('Hello');
  expect(console.log).toHaveBeenCalledWith('Hello');
  expect(toastr.info).not.toHaveBeenCalledWith('Hello');
});

it('should log using the log function and also toast', function() {
  logger.log('Foo', true);
  expect(console.log).toHaveBeenCalledWith('Foo');
  expect(toastr.info).toHaveBeenCalledWith('Foo');
});

it('should log using the debug function and also toast', function() {
  logger.log('Foo', 'debug', true);
  expect(console.debug).toHaveBeenCalledWith('Foo');
  expect(toastr.warning).toHaveBeenCalledWith('Foo');
});

it('should log to the debug function but without toast', function() {
  logger.log('Foo', 'debug');
  expect(console.debug).toHaveBeenCalledWith('Foo');
  expect(toastr.info).not.toHaveBeenCalledWith('Foo');
});

it('should log using the error function and also toast', function() {
  logger.log('Bar', 'error', true);
  expect(console.error).toHaveBeenCalledWith('Bar');
  expect(toastr.error).toHaveBeenCalledWith('Bar');
});

it('should log to the error function but without toast', function() {
  logger.log('Baz', 'error');
  expect(console.error).toHaveBeenCalledWith('Baz');
  expect(toastr.error).not.toHaveBeenCalledWith('Baz');
});

it('should fallback to the log function if it is not valid', function() {
  logger.log('Not valid', 'emergency', true);
  expect(console.log).toHaveBeenCalledWith('Not valid');
  expect(toastr.info).toHaveBeenCalledWith('Not valid');
});
```

Here we are testing the different combinations of our `logger`. As you can see, it has 3 parameters, one for the message, one for the log type and one boolean for our `toastr` popup. The type parameter is optional and will use `log` by default. Also I provided a fallback option to the library.

The final result of the service is:

```javascript
angular.module('app', ['toastr']).factory('logger', function(toastr) {
  
  var types = {
    'log': 'info',
    'debug': 'warning',
    'error': 'error'
  };
  
  var log = function(message, type, toast) {
    if (typeof type == "boolean") {
      toast = type;
    }
    
    if (!types.hasOwnProperty(type)) {
      type = 'log';
    }
    
    console[type](message);
    
    if (toast) {
      toastr[types[type]](message);
    }
  };
  
  return {
    log: log
  };
  
});
```

I mapped the console functions to the toastr function that has the most appropiated colors. And the log function is easy, we just log and show a popup if needed.

Even when we used a `factory` here, testing a `service` is not different.

You can see it live [here](http://plnkr.co/edit/6UEx0otNVsgrTm5bP6PF?p=preview).
