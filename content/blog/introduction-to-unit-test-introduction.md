+++
title = "Introduction to unit test: introduction"
categories = []
tags = ["unit test"]
date = "2014-02-18T12:37:46+01:00"
description = ""

+++

Let's talk about unit testing our applications.

### What is unit testing and why should I care?

Unit tests are a bunch of Javascript files that we create to make sure that every part of our application works as it is expected to work. That means that we need to write hundred of lines of code to assert that our code does what is supposed to do.

* **Isn't that a waste of time?** The boss is always telling us that we need to be faster and hundred of lines doesn't sound like *fast*. Au contraire, that bunch of code will save us **HOURS**. Don't believe me? I have proofs.
<!--more-->
* **Extra code**: How many times did you end with code that is not used? Maybe we added some extra loops that are not needed or some function to do something and then realize that we are not using it. When we code our modules before any test, we don't actually know what we are going to need or if our algorithm is going to support any kind of input (that could lead to those extra loops). More code means more stuff to maintain which also means, more money.

* **Bad API design**: Maybe we need to create a new service to do something, and then we start writing functions to do the work and we put some of them public to define the service's API. Good, that is the idea isn't it? Some time after we get complaints about our really poor API that well, it is not as intuitive as we expected. In this category also goes those API functions that are not really needed (which is also *extra code*).

* **Refactor**: What happens when we want to refactor our code? We are in big trouble. Even when we decide to not break the API, maybe that internal change is not working properly on some edge cases where it worked in the past. That will break the application for some people and they won't be happy at all (and those kind of bugs are normally a pain in the ass).

* **Will it work**: That is the end goal and probably the biggest time waster of anything you have to do in your applicaton.  Something as simple as a *calendar*, involves some maths and some magic numbers to make it work. We really need to be sure it works. How? We open a certain date, we manually check with our OS calendar to see if it matches. We repeat that for some random dates (old ones, future ones). Then we change something in our service and well, we need to check the dates again to assert that nothing is broken. Repeat that 20 times for a normal service development.

### How does the unit test help?

Ok, you convinced me that maybe I was wrong about not doing unit testing. But how can it help with those problems? What if we see a really simple example? (General example, not angular related and it will be in a overly slow peace to make the point).

Let's say I want an object which will be able to do some basic maths (Addition, Subtraction, Multiplication, Division) and your first thought will be to start writing a constructor with some prototype functions to do some math. We will end doing something like that, but what we are going to do is to test it first. Test it first? Why? Bear with me.

(If you want to follow this, I have a [plunker](http://plnkr.co/edit/tpl:BwELtfQGfM9ODbyuj9RG?p=catalogue) for you to work.)

Our object should be able to sum `5` and `3` and get `8`. Let's test that:

File: `calculator_spec.js`
```javascript
describe('Calculator', function() {
  var calc;
  
  beforeEach(function() {
    calc = new Calculator();  
  });
  
  describe('Addition', function() {
    it('should be able to sum 5 and 3 to return 8', function() {
      var result = calc.addition(5, 3);
      expect(result).toBe(8);
    });
  });
});
```

If we put that on a spec file and run it we get:

![](/images/posts/introtest/image1.png)

It says that it can't create a new `Calculator` and it is not able to do that `addition` (surprise!). Well, we have no code. Before continuing, I am going to explain how jasmine tests work.

Jasmine is like writing English. It is something easy to read and understand (which is waay cool). Jasmine spec files are normally wrapped on a `describe` block which receives a string to define what are we describing. They are used to group tests. We can see how we have another `describe` block which is nested in the previous one with the `addition` as parameter. See how are we grouping the tests?

What we need to do to write tests is to use the `it` function. It receives the name of the test and a callback function that will contain the test itself. In this case it is testing that what we get from the `addition` function is the correct value. What about that `beforeEach`? Since we need to create a calculator in all the tests, we can just create one to not repeat ourselves. Read with me: `before each test create a new calculator`.

See how easy is to make a test. We use the expect function were we pass our result and then the `toBe` jasmine function which receives the expected value. Read with me: `expect result to be 8`.

There is an important concept in unit testing. Every test in independent of each other, that means that every test will start with a fresh state (In our case, a new `Calculator` object).

Are you starting to see what we are getting here so far? **API design**. By using our object before we coded it, we are using the `API` as we would like to use it. That is a much much better way to define our `API`.

Let's make that test pass:

File: `calculator.js`
```javascript
function Calculator() {
}

Calculator.prototype.addition = function(num1, num2) {
  return 5 + 3;
};
```

Does it pass?

![](/images/posts/introtest/image2.png)

Yes it does! This is an example of no **extra code**. We coded the minimum necessary to make it work, and well, that is what we need at this point.

Of course, we are not finished yet with our tests. We want to know if we can sum 7 and 0. We test it on a new `it` function:

File: `calculator_spec.js`
```javascript
describe('addition', function() {
  // earlier test hidden
  
  it('should be able to sum a number with 0', function() {
    var result = calc.addition(7, 0);
    expect(result).toBe(7);
  });
});
```

![](/images/posts/introtest/image3.png)

Well, that fails, and we know why. For the sake of learning we are going to do an extra step to fix it:

File: `calculator.js`
```javascript
Calculator.prototype.addition = function(num1, num2) {
  return 7 + 0;
};
```

![](/images/posts/introtest/image4.png)

Ups, we broke the last test. That is wonderful. That solves our **Will it work?** problem. We can immediately see that we broke our code when we modified our function to pass the new test.

Let's fix it for once:

File: `calculator.js`
```javascript
Calculator.prototype.addition = function(num1, num2) {
  return num1 + num2;
};
```

![](/images/posts/introtest/image5.png)

Uh, finally. Now we have a proper `addition` method which just the needed code to make it work, no extra params either. We can add some more tests (to the `addition` describe):

File: `calculator_spec.js`
```javascript
it('should be able to sum a negative number with a positive result', function() {
  var result = calc.addition(7, -3);
  expect(result).toBe(4);
});

it('should be able to sum a negative number with a negative result', function() {
  var result = calc.addition(-20, 7);
  expect(result).toBe(-13);
});
```

![](/images/posts/introtest/image6.png)

Uh, it works without any extra code! Better for us. Let's do the `division`:

File: `calculator_spec.js`
```javascript
describe('division', function() {
  it('should be able to do a exact division', function() {
    var result = calc.division(20, 2);
    expect(result).toBe(10);
  });
});
```

![](/images/posts/introtest/image7.png)

We see it fails, it doesn't have that `division` method.

File: `calculator.js`
```javascript
Calculator.prototype.division = function(num1, num2) {
  return num1 / num2;
};
```

![](/images/posts/introtest/image8.png)

We are smart enough to make a proper first version which actually passes.

Now, for non exact divisions, we want to round the result, we don't want any decimals.

File: `calculator_spec.js`
```javascript
it('returns a rounded result for a non exact division', function() {
  var result = calc.division(20, 3);
  expect(result).toBe(7);
});
```

![](/images/posts/introtest/image9.png)

Our current implementation is not rounding the result at all. Let's fix that:

File: `calculator.js`
```javascript
Calculator.prototype.division = function(num1, num2) {
  return Math.round(num1 / num2);
};
```

![](/images/posts/introtest/image10.png)

This time we didn't break our last implementation, that is something :P

What about throwing an exception if we divide something by 0? Sure:

File: `calculator_spec.js`
```javascript
it('should throw an exception if we divide by 0', function() {
  expect(function() {
    calc.division(5, 0);
  }).toThrow(new Error('Calculator does not allow division by 0'));
});
```

![](/images/posts/introtest/image11.png)

This test is a little bit different. Instead of passing a variable to `expect` we are passing a function. We expect that call to end on an exception so saving the result as we previously did won't work (We expect to never return that result but throw an exception). We also use the `toThrow` function on Jasmine.

It fails, we are not throwing any exception yet. Let's fix that:

File: `calculator.js`
```javascript
Calculator.prototype.division = function(num1, num2) {
  if (num2 === 0) {
    throw new Error('Calculator does not allow division by 0');
  }
  return Math.round(num1 / num2);
};
```

![](/images/posts/introtest/image12.png)

Well, we just need to check if `num2` is just 0 to throw the exception.

With that, we finished our `division` method... Wait a second... Those parameter names suck. I agree, let's change them:

File: `calculator.js`
```javascript
Calculator.prototype.division = function(dividend, divisor) {
  if (divisor === 0) {
    throw new Error('Calculator does not allow division by 0');
  }
  return Math.round(dividend / divisor);
};
```

![](/images/posts/introtest/image12.png)

Uh, we did a **refactor** and we didn't break anything.

I will leave the other two calculator functions as an exercise.

### Conclusions of this example

Even when it is really really simple example. We already saw how we can address those problems I described earlier:

Our calculator doesn't have any **extra code** because we coded just what we needed to make our calculator work. Its **API design** is good enough, that is because we used it as we would like to use it on the real world. **Will it work?** Sure, I have a bunch of tests that proves that. What about **refactor**? Go ahead, if the tests still pass, then you're doing good.

Maybe you won't notice it with this example, but with proper tests, you will save a lot of hours maintaining **extra code**, dealing with **API design** with hopefully won't end on breaking changes, **refactor**ing code without fear and of course being sure that your code **will work**.

Testing is your friend, and with little effort on it, will save us real pain.


### How can we test Angular.js?

Surprisingly enough, almost the same as our calculator. Since `Angular.js` is more complex than basic `Javascript` it involves a little more of work.

There is a couple of things to learn. How to work with angular `modules` and `dependency injection`. They don't work as we are used to, they need some special ways that already exists on a file called `angular-mocks.js`. It is better if we see a skeleton:

```javascript
describe('type: name', function() {
  var $scope, myService, $location

  beforeEach(module('app'));

  beforeEach(inject(function($rootScope, _myService_, _$location_) {
    $scope = $rootScope.$new();
    myService = _myService_;
    $location = _$location_;
  }));

  it('should work', function() {
    // Do something
    // Expect something
  });
});
```

It should be very familiar now, but there are some `Angular` bits. First of all, *my* convention is to put what are we testing and the name, for example: `controller: foo`. Then we need to load all the modules involved, if it is just `app`, we just need to load that one. To load it and since we need it before each test, we use the `module` function (from `angular-mocks`) to load that `app` module for us. If we have more dependencies like `ngRoute`, we also need to load it (before `app`).

The other different part is how we inject stuff. To inject we need to use the `inject` function (from `angular-mocks`) which will receive a function with all the stuff we need to inject. What about those underscores? `Angular` ignores them, so we can use that to be able to have our local variables with the original service name.

The rest is not new. Once we have our modules loaded and our services injected and saved in local variables, we just need to do some testings. For that, we need to wait for the next articles of this series.
