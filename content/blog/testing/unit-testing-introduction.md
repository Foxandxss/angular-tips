---
title: 'Unit testing - Introduction'
description: 'introduction to unit testing in angular'
date: 2021-07-22T17:45:06+02:00
draft: false
categories: []
tags: ["unit test"]
---

Let's talk about unit testing our applications.

### What is unit testing and why should I care?

Unit tests are a bunch of Typescript files that we create to make sure that every part of our application works as it is expected to work. That means that we need to write hundred of lines of code to assert that our code does what is supposed to do.

* **Isn't that a waste of time?** The boss is always telling us that we need to be faster and hundred of lines doesn't sound like *fast*. Au contraire, that bunch of code will save us **HOURS**. Don't believe me? I have proofs.
<!--more-->
* **Extra code**: How many times did you end with code that is not used? Maybe we added some extra loops that are not needed or some function to do something and then realize that we are not using it. When we code our modules before any test, we don't actually know what we are going to need or if our algorithm is going to support any kind of input (that could lead to those extra loops). More code means more stuff to maintain which also means, more money.

* **Bad API design**: Maybe we need to create a new service to do something, and then we start writing functions to do the work and we put some of them public to define the service's API. Good, that is the idea isn't it? Some time after we get complaints about our really poor API that well, it is not as intuitive as we expected. In this category also goes those API functions that are not really needed (which is also *extra code*).

* **Refactor**: What happens when we want to refactor our code? We are in big trouble. Even when we decide to not break the API, maybe that internal change is not working properly on some edge cases where it worked in the past. That will break the application for some people and they won't be happy at all (and those kind of bugs are normally a pain to debug).

* **Will it work**: That is the end goal and probably the biggest time waster of anything you have to do in your applicaton.  Something as simple as a *calendar*, involves some maths and some magic numbers to make it work. We really need to be sure it works. How? We open a certain date, we manually check with our OS calendar to see if it matches. We repeat that for some random dates (old ones, future ones). Then we change something in our service and well, we need to check the dates again to assert that nothing is broken. Repeat that 20 times for a normal service development.

### How does the unit test help?

Ok, you convinced me that maybe I was wrong about not doing unit testing. But how can it help with those problems? What if we see a really simple example? (General example, not Angular related and it will be in a really slow peace to make the point).

Let's say I want an object which will be able to do some basic maths (Addition and Division). Your first thought is to start writing a class with some methods to do some math. We will end doing something like that, but what we are going to do is to test it first. Test it first? Why? Bear with me.

(If you want to follow this, I have a [codesandbox](https://codesandbox.io/s/testing-tutorial-starter-q2skc) for you to work.)

This codesandbox (and the Angular app that we will test in the next sections) uses `Jest`. [Jest](https://jestjs.io/) is a testing framework that can be used for any Javascript / Typescript project.

Our object should be able to sum `5` and `3`and get `8`. Let's test that.

File: `src/calculator.spec.ts`

```typescript
describe('Calculator', () => {
  it('should be able to sum 5 and 3 to return 8', () => {
    // Arrange
    const calc = new Calculator();
    
    // Act
    const result = calc.sum(5, 3);

    // Assert
    expect(result).toBe(8);
  });
});
```

Before we even look at the `Tests` tab at `codesandbox`, let's talk about this piece of code.

First we see that this looks like something between English and Typescript. Testing is meant to be something that is easy to read and easy to understand and just by reading the code, we get an idea of what it does:

"`Describe` a calculator. `It` should be able to run 5 and 3 to return 8. Create a calculator object, call a method and `expect` the result `to be` 8.".

Now back to technical details, tests are wrapped into `describe` functions. They are used to group our tests. The actual tests are functions called `it` where we actually code our tests.

Inside those `it` functions, we follow a pattern called **AAA** (Arrange, Act, Assert). With those 3 steps, we successfully write a test.

In this example, we are *Arranging* by creating a `Calculator` object, then *Acting* by calling it's `sum` method and *Asserting* by checking its result with our expected result.

Alright, but what is the result of this test?

![](/images/posts/testing/introduction/1.png)

Kind of expected, isn't it? We wrote our test before we even created our `Calculator` class.

Something interesting to notice here is how are we **designing our API** before we even coded it. We say that we want a `sum` method before we created the class.

Let's fix this, Shall we?

File: `src/calculator.ts`

```typescript
export class Calculator {
  sum(num1: number, num2: number): number {
    return 8;
  }
}
```

And also let's import it to our spec file:

File: `src/Calculator.spec.ts`
```typescript {hl_lines=[1]}
import { Calculator } from './calculator';

describe('Calculator', () => {
  ...
});
```

What does our test says now?

![](/images/posts/testing/introduction/2.png)

But... That is definitely not right, isn't it? We hardcoded the result *8* into the method. That way our tests surely pass.

We have to code the minimum possible code to make our tests pass. I understand that this is a contrived example and we already know that this implementation is not enough, but in a real world scenario (as we will see in the next sections) you may not know when an implementation is enough or not, so our job is to make a test pass as simple as possible, as we did in here.

Since we may not be sure that this implementation is enough, we have to write more tests:

File: `src/calculator.spec.ts`

```typescript
it('should be able to sum a number with 0', () => {
  const calc = new Calculator();

  const result = calc.sum(7, 0);

  expect(result).toBe(7);
});
```

If we see the test tab we see:

![](/images/posts/testing/introduction/3.png)

**1 test failed, 1 test passed**. And we can see where it failed and why. We expected the result of 7 but we got 8. That means that something is wrong with our code.

This solves our **Will it work?** dilemma. We can immediately see that our code doesn't really work, so we need to fix it so all our test passes.

Let's fix it:

File: `src/calculator.ts`

```typescript {hl_lines=[3]}
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }
}
```

Now our tests says:

![](/images/posts/testing/introduction/4.png)

Before we move on, let's take a peek to our current spec file:

```typescript {hl_lines=[6,16]}
import { Calculator } from './calculator';

describe('Calculator', () => {
  it('should be able to sum 5 and 3 to return 8', () => {
    // Arrange
    const calc = new Calculator();
    
    // Act
    const result = calc.sum(5, 3);

    // Assert
    expect(result).toBe(8);
  });

  it('should be able to sum a number with 0', () => {
    const calc = new Calculator();

    const result = calc.sum(7, 0);

    expect(result).toBe(7);
  });
});
```

First, notice here that **every** `it` in our spec file is completely independent of the others. They run independently and you should never ever rely on the way they are ordered to "start something in one one them" and "assert in the other". In fact, Jest may run the `it` in a random order to avoid dependency between them.

Also, look at the code. There is some repetition in it. The DRY (don't repeat yourself) principle doesn't apply as strongly as it does in our application code. We are allowed to repeat some code for the sake of testing, but that doesn't mean that we should repeat *all* our code.

In this case we are repeating our `Arrange` part in those two tests, and if we have 20 of them, we are going to repeat it 20 times. We can do better.

There is a method called `beforeEach` that runs before each `it` function. There we can setup whatever we need for each test. Let's **Arrange** our code there so we have access to `calc` in each test.

Let's look at the new code:

File: `src/calculator.spec.ts`:

```typescript {hl_lines=["4-9"]}
import { Calculator } from './calculator';

describe('Calculator', () => {
  let calc: Calculator;

  beforeEach(() => {
    // Arrange
    calc = new Calculator();
  });

  it('should be able to sum 5 and 3 to return 8', () => {
    // Act
    const result = calc.sum(5, 3);

    // Assert
    expect(result).toBe(8);
  });

  it('should be able to sum a number with 0', () => {
    const result = calc.sum(7, 0);

    expect(result).toBe(7);
  });
});
```

This is a test **refactor**. We should only do them when all our tests are green, to be sure that it doesn't break anything.

So far so good, let's throw more different scenarios to see it behaves correctly:

```typescript
it('should be able to sum a negative number for a positive result', () => {
  const result = calc.sum(7, -3);

  expect(result).toBe(4);
});

it('should be able to rum a negatrive number for a negative result', () => {
  expect(calc.sum(-20, 7)).toBe(-13);
});
```

Notice how I wrote two lines in one in the last example. It is still readable so it is good in my book.

![](/images/posts/testing/introduction/5.png)

Seems like our code handles this two use cases correctly.

Now, let's move to `division`, but before we do that, we could group or `sum` test in their own `describe` like this:

File: `src/calculator.spec.ts`:

```typescript
import { Calculator } from './calculator';

describe('Calculator', () => {
  let calc: Calculator;

  beforeEach(() => {
    // Arrange
    calc = new Calculator();
  });

  describe('#sum', () => {
    it('should be able to sum 5 and 3 to return 8', () => {
      // Act
      const result = calc.sum(5, 3);
  
      // Assert
      expect(result).toBe(8);
    });
  
    it('should be able to sum a number with 0', () => {
      const result = calc.sum(7, 0);
  
      expect(result).toBe(7);
    });
  
    it('should be able to sum a negative number for a positive result', () => {
      const result = calc.sum(7, -3);
  
      expect(result).toBe(4);
    });
  
    it('should be able to rum a negatrive number for a negative result', () => {
      expect(calc.sum(-20, 7)).toBe(-13);
    });
  });
});
```

We can anidate as many `describe` as we need. Also notice the `#` at `#sum`. It is a convention that says that we are testing a method.

Now let's create a new `describe` for a division with a simple test:

File: `src/calculator.spec.ts`:

```typescript {hl_lines=["6-12"]}
    it('should be able to rum a negatrive number for a negative result', () => {
      expect(calc.sum(-20, 7)).toBe(-13);
    });
  });

describe('#division', () => {
  it('should be able to do an exact division', () => {
    const result = calc.division(20, 2);

    expect(result).toBe(10);
  });
});
```

It fails:

![](/images/posts/testing/introduction/6.png)

What a surprise. Let's fix it real quick:

File: `src/calculator.ts`:

```typescript {hl_lines=["6-8"]}
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }
  
  division(num1: number, num2: number): number {
    return num1 / num2;
  }
}
```

![](/images/posts/testing/introduction/7.png)

This time with the application requisites a bit clearer, we wrote a better `division` method.

We don't want or `Calculator` to deal with decimals, because who likes decimal anyway?

File: `src/calculator.spec.ts`:

```typescript
it('returns a rounded result for a non exact division', () => {
  expect(calc.division(20, 3)).toBe(7)
});
```
![](/images/posts/testing/introduction/8.png)

Apparently Typescript does like them.

Let's fix *that*.

File: `src/calculator.spec.ts`:

```typescript {hl_lines=["7"]}
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }
  
  division(num1: number, num2: number): number {
    return Math.round(num1 / num2);
  }
}
```

![](/images/posts/testing/introduction/9.png)

Yay, not only in rounds numbers now, but our other test still works as expected.

Now we want to throw an exception if we divide something by 0.

File: `src/calculator.spec.ts`:

```typescript
it('throws an exception if we divide by 0', () => {
  expect(() => 
    calc.division(5, 0)
  ).toThrow('Division by 0 not allowed.');
});
```

This test looks different. Instead of passing a variable to `expect`, we are passing a function. The idea is something like "We expect that when running this function, an exception will be thrown". Since `division` won't be able to return anything if it throws an exception, we cannot test the `result` as we previously did.

This test obviously fails:

![](/images/posts/testing/introduction/10.png)

Let's see our code before we change it:

File: `spec/calculator.ts`:

```typescript
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }
  
  division(num1: number, num2: number): number {
    return Math.round(num1 / num2);
  }
}
```

Division by 0 happened when divisor is 0 but... which is which in our code? Let's refactor our code, but before we do that, we need our tests to pass and we have one that is failing. What we can do is "skip" the test until we refactor:

File: `src/calculator.spec.ts`:

```typescript {hl_lines=[1]}
xit('throws an exception if we divide by 0', () => {
  expect(() => 
    calc.division(5, 0)
  ).toThrow('Division by 0 not allowed.');
});
```

Notice the `xit`. We use this as a way to "ignore" a test. We can always comment out the code, but that way we may forget that we had a test to fix. With `xit` we can see that it exist but that it was skipped.

> NOTE: codesandbox doesn't manage this `xit` very well, but at least it says that there are no failing tests

Now we our broken test ignored, let's refactor our code:

```typescript {hl_lines=["6-8"]}
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }

  division(dividend: number, divisor: number): number {
    return Math.round(dividend / divisor);
  }
}
```

Much better and tests still pass:

![](/images/posts/testing/introduction/9.png)

>NOTE: As mentioned, codesandbox doesn't manage this well and you may see a red X saying failed but all correct in the summary, that is fine.

That is a code **refactor** without the fear of breaking any feature.

Now swap the `xit` for `it` again:

File: `src/calculator.spec.ts`:

```typescript {hl_lines=[1]}
it('throws an exception if we divide by 0', () => {
  expect(() => 
    calc.division(5, 0)
  ).toThrow('Division by 0 not allowed.');
});
```

And let's fix the code:

```typescript {hl_lines=["6-11"]}
export class Calculator {
  sum(num1: number, num2: number): number {
    return num1 + num2;
  }

  division(dividend: number, divisor: number): number {
    if (divisor === 0) {
      throw new Error('Division by 0 not allowed.');
    }
    return Math.round(dividend / divisor);
  }
}

```

![](/images/posts/testing/introduction/11.png)

And that is it! Congratulations, you just wrote your first test suite.

### Conclusions of this example

Even when it is really really simple example. We already saw how we can address those problems I described earlier:

Our calculator doesn't have any **extra code** because we coded just what we needed to make our calculator work. Its **API design** is good enough, that is because we used it as we would like to use it on the real world. **Will it work?** Sure, I have a bunch of tests that proves that. What about **refactor**? Go ahead, if the tests still pass, then you're doing good.

Maybe you won't notice it with this example, but with proper tests, you will save a lot of hours maintaining **extra code**, dealing with **API design** with hopefully won't end on breaking changes, **refactor**ing code without fear and of course being sure that your code **will work**.

Testing is your friend, and with little effort on it, will save us real pain.

See you in the next section where we will dive into mock and spies to then test an Angular component from scratch.