+++
date = "2013-08-28T16:25:15+01:00"
categories = []
tags = ["tip", "directives"]
description = ""
title = "Tip: directives with the same name"

+++

Since this blog is a blog for tips, let's begin with the first one.

You want to log the clicks on a `ng-click` directive. What could you do?

We can take this first approach:
<!--more-->

File: `index.html`
```html
<button ng-click="dummyClickFoo()" log>Submit</button>
<button ng-click="dummyClickBar()" log>Cancel</button>
```

File: `log.js`
```javascript
app.directive('log', function($log) {
  return {
    link: function(scope, element, attrs) {      
      element.bind('click', function() {
        scope.$apply(function() {
          $log.log("ng-click clicked");
        });
      });
    }
  };
});
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/UCekAqa/1/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

**NOTE**: Check the logging on your browser's dev tools console.

That works. We log the clicks into the directive. That is good. But what if we have 200 `ng-click` and we want to log them all? Putting the directive 200 times would work, but it is a lot of work.

Alright, let's take a different approach. We are going to replicate the `ng-click` to do the logging.

File: `index.html`
```html
<button logging-click="dummyClickFoo()">Submit</button>
<button logging-click="dummyClickBar()">Cancel</button>
```

File: `loggingClick.js`
```javascript
app.directive('loggingClick', function($parse, $log) {
  return function(scope, element, attrs) {
    var fn = $parse(attrs['loggingClick']);
    element.bind('click', function(event) {
      scope.$apply(function() {
        $log.log("logging-click clicked");
        fn(scope, {$event: event});
      });
    });
  };
});
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/UCekAqa/2/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

**NOTE**: Check the logging on your browser's dev tools console.

This is the "original" (almost :P) `ng-click` directive with logging. Works like the original but it also logs what we want.

What's the problem? We need to use this directive instead of `ng-click` and we could forget to use our logging version in one place and so we lose some of the logging.

What can we do? Easy, we can create a directive called `ng-click`. Uh, won't that replace the original one? No, Angular will run both. Uhm, it sounds good, let's try:

File: `index.html`
```html
<button ng-click="dummyClickFoo()">Submit</button>
<button ng-click="dummyClickBar()">Cancel</button>
```

File: `ngClick.js`
```javascript
app.directive('ngClick', function($parse, $log) {
  return function(scope, element, attrs) {
    element.bind('click', function() {
      scope.$apply(function() {
        $log.log("logging-click clicked");
      });
    });
  };
});
```

## Try it

<a class="jsbin-embed" href="http://jsbin.com/UCekAqa/3/embed?output">JS Bin</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

**NOTE**: Check the logging on your browser's dev tools console.

We created a directive with the same name, which will log when we click.

## Conclusion

By doing this we can write directives that we need to run when other directive appears. So if we need to do something in every `<input>` we only need to write another `input` directive... etc.
