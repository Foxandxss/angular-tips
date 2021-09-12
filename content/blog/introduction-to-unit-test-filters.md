+++
categories = []
tags = ["unit test"]
description = ""
date = "2014-04-28T13:02:04+01:00"
title = "Introduction to unit test: filters"

+++

**THIS TUTORIAL IS FOR ANGULAR.JS. FOR AN ANGULAR UNIT TESTING TUTORIAL GO [HERE](/blog/2021/07/unit-testing-toc)**

Filters are the easiest components to test in `Angular`. That is why I decided to explain them first. Our first job is to decide what we want to achieve and in this case I decided to write a custom `uppercase` filter with options.

What should our filter do? Our filter will uppercase the entire input or just part of it based on an input. Let's describe how we would like to use it here:
<!--more-->

* {{ "hello" | upper }} - HELLO
* {{ "hello" | upper:4 }} - HELLo
* {{ "hello" | upper:-2 }} - helLO


As you see, we want a numeric argument to specify how many characters we want to uppercase, which can also be a negative number to start from the end.

Alright, let's start with the tests:

```javascript
describe('Filter: upper', function() {
  var upperFilter;
  
  beforeEach(module('app'));
  beforeEach(inject(function(_upperFilter_) {
    upperFilter = _upperFilter_;
  }));
});
```

We learned about this in the introduction. We are simply loading out `app` module (where we are going to put our filter) and then we are injecting it. Filters are injected using `nameFilter` where `name` is the name of the filter.

There are a couple ways of testing, we can write all the tests at once or we can write some tests and make them pass and repeat until it is feature complete or we can write all the tests at once. We are going to use the first technique here.

Let's add the first one (just after the last `beforeEach`):

```javascript
it('should be able to uppercase an entire input', function() {
  expect(upperFilter('hello')).toBe('HELLO');
  expect(upperFilter('hello world')).toBe('HELLO WORLD');
});
```

As you see, testing a filter is really really easy. We only need to call it passing the input we want to process.

![](/images/posts/introtest/filters/image1.png)

That was expected. We don't have the filter created yet. Let's do it:

```javascript
angular.module('app').filter('upper', function() {
  return function(input) {
    return input.toUpperCase();
  };
});
```

We just return the input uppercased and it...

![](/images/posts/introtest/filters/image2.png)

...it passes!

What about uppercasing just the first `x` parameters?

```javascript
it('can uppercase just the first x characters of an input', function() {
  expect(upperFilter('hello', 4)).toBe('HELLo');
  expect(upperFilter('hello world', 5)).toBe('HELLO world');
});
```

![](/images/posts/introtest/filters/image3.png)

So far, it is ignoring our parameter so our tests don't pass. Let's fix that:

```javascript
angular.module('app').filter('upper', function() {
  return function(input, quantity) {
    if (quantity > 0) {
      return input.substr(0, quantity).toUpperCase() + input.slice(quantity);
    } else {
      return input.toUpperCase();
    }
  };
});
```

If quantity is bigger than 0, we uppercase the first `quantity` characters, if there is no quantity or it is not a number, we just uppercase everything. Does it work?

![](/images/posts/introtest/filters/image4.png)

Of course it does :D

Now we need to support uppercasing backwards. Let's test it:

```javascript
it('can uppercase the last x characters of an input', function() {
  expect(upperFilter('hello', -2)).toBe('helLO');
  expect(upperFilter('hello world', -5)).toBe('hello WORLD');
});
```

![](/images/posts/introtest/filters/image5.png)

Ok, here is the implementation:

```javascript
angular.module('app').filter('upper', function() {
  return function(input, quantity) {
    if (quantity > 0) {
      return input.substr(0, quantity).toUpperCase() + input.slice(quantity);
    } else if (quantity < 0) {
      return input.substr(0, input.length + quantity) +
                  input.slice(input.length + quantity).toUpperCase();
    } else {
      return input.toUpperCase();
    }
  };
});
```

We added another branch to see if quantity is less than 0 and if so, we just uppercase the last `quantity` characters.

Good, our `upperFilter` is now feature complete. That doesn't mean it is finished yet. What happens if the `quantity` is longer than the input? Let's test it:

```javascript
it('works with a quantity longer than the input', function() {
  expect(upperFilter('hello', 10)).toBe('HELLO');
  expect(upperFilter('hello', -10)).toBe('HELLO');
});
```

See the error:

![](/images/posts/introtest/filters/image6.png)

Wait... there is no error. Indeed. In TDD you also need to test some corner cases like this one. Luckily for us, there is no work to be done here. It works perfect by default. Still, we proved that that behavior is not problematic.

You can see this working [here](http://plnkr.co/edit/A30YLsXFNxzRXWBVlqIH?p=preview).
