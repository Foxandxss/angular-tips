---
title: 'Unit testing - Spies and Mocks'
description: ''
date: 2021-07-25T17:12:25+02:00
draft: false
categories: ["unit test"]
tags: []
---

We have done a unit test of a calculator in the previous [part](/blog/2021/07/unit-testing-introduction/). But we never mentioned what does **unit** means in unit test.

There are several ways to test our application:

**Unit Test**: We test one piece of code in isolation. That means, without its dependencies. A component without its services or the other components used in the template. A service without other services, etc.

**Integration Test**: Here we test that a several pieces works in conjunction. Some people agrees that testing that a component works with its template is considered an integration testing. But more on that in later parts.

**End to End**: In a end to end (e2e), we assert that our use cases works from start to finish. That means server calls, authentication and other stuff. We might talk about this in a different series.

In angular we want to do as many `Unit Tests` as possible because they are cheaper (to do and to maintain).

![testing pyramid](/images/posts/testing/mocks/1.png "https://product.spotahome.com/qa-spotahome-part-2-testing-our-backend-platform-907687c42fcf")

Let's see a new example. This time, we will focus on the tests.

(If you want to follow this, I have a [codesandbox](https://codesandbox.io/s/unittesting-mocks-nfyv0) for you to work.)

This is a very contrived example but is what we need to keep learning.

Here we have a recipe service:

File: `src/recipe.service.ts`

```typescript
export interface Recipe {
  name: string;
  ingredients: string[];
  cookTemperature: number;
  temperatureUnit: string;
  steps: string;
}

export class RecipeService {
  getRecipes() {
    // In a real world, this is calling some backend
    // through an API call
    return [
      {
        name: "Pizza",
        ingredients: ["Tomato", "Mozarella", "Basil"],
        cookTemperature: 500,
        temperatureUnit: 'F',
        steps: "Put in oven until it gets your desired doneness"
      }
    ];
  }
}
```

It has a method called `getRecipes` that returns a list of well, recipes. In a real world scenario this would be a real HTTP call. We don't need that here.

We also have a service that converts Fahrenheit to Celsius:

File: `src/temperature.service.ts`

```typescript
export class TemperatureService {
  fahrenheitToCelsius(temperature: number): number {
    return ((temperature - 32) * 5) / 9;
  }
}
```

Nothing fancy.

And lastly, we have a component (again, contrived example, no template) that uses both services:

File: `src/recipe.component.ts`

```typescript
import { Recipe, RecipeService } from "./recipe.service";
import { TemperatureService } from "./temperature.service";

export class RecipeComponent {
  recipes: Recipe[];

  constructor(
    private recipeService: RecipeService,
    private temperatureService: TemperatureService
  ) {}

  fetchRecipes() {
    this.recipes = this.recipeService.getRecipes();
  }

  printRecipesInCelsius() {
    return this.recipes.map((recipe) => {
      const cookTemperature = this.temperatureService.fahrenheitToCelsius(
        recipe.cookTemperature
      );
      return {
        ...recipe,
        temperatureUnit: 'C',
        cookTemperature
      };
    });
  }
}
```

The recipe component has a reference to our two services. One method that fetch the recipes from our service to store them locally and a method that returns a new list but with the temperature in celsius.

We are asked to unit test this component class. Ok, let's open our code spec file and let's write the basic skeleton:

File: `src/recipe.component.spec.ts`

```typescript
import { RecipeComponent } from "./recipe.component";

describe("RecipeComponent", () => {
  let component: RecipeComponent;

  beforeEach(() => {
    component = /* what goes here? */
  });
});
```

Before we jump into "Obviously we need to pass an instance of both services" let's think a bit.

What does this component? It **holds a list of recipes**, a method **that fetches the recipes** and a method **that returns the recipes in celsius**.

That is it, it doesn't care where **how** the recipes are fetched in the service. It only cares that `recipeService.getRecipes()` returns a list of recipes. We have to assume that the service itself is tested. The component boundaries ends on "I call this method in the server that is supposed to return me recipes".

With that said, if we pass an instance of `RecipeService` into our `component` we are coupling our tests with a real service. If that service calls a slow third party backend to fetch recipes, our tests won't be fast nor reliable.

In other words, we can't use the *real* `RecipeService` here because it will only add complexity to our test, and as I said at the beginning, in a unit test, we need to test our piece of code in isolation.

Alright, but how do we make this code work without using the real deal?

## Mocks

A mock is an object that *mimics* another object for testing. It has the same interface as the real one but its implementation is way simpler or even empty.

That sounds extrange, so let's see it in action:

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=["4-6"]}
import { RecipeComponent } from "./recipe.component";
import { RecipeService } from "./recipe.service";

const recipeServiceMock: RecipeService = {
  getRecipes: () => []
}

describe("RecipeComponent", () => {
  let component: RecipeComponent;

  beforeEach(() => {
    // ommited for now
  });
});
```

Our `recipeServiceMock` is a mock of `RecipeService`. It has the same interface (the `getRecipes` method). It just returns an empty array. And that is perfectly fine. We just need to know that its methods are used by our SUT (subject under test, AKA the piece of code we are testing).

Now we can use that mock when creating our component for testing:

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[5]}
describe("RecipeComponent", () => {
  let component: RecipeComponent;

  beforeEach(() => {
    component = new RecipeComponent(recipeServiceMock, ...)
  });
});
```

Good, we just need to do the same with `TemperatureService`.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=["9-11", 17]}
import { RecipeComponent } from "./recipe.component";
import { RecipeService } from "./recipe.service";
import { TemperatureService } from "./temperature.service";

const recipeServiceMock: RecipeService = {
  getRecipes: () => []
}

const temperatureServiceMock: TemperatureService = {
  fahrenheitToCelsius: () => 0
}

describe("RecipeComponent", () => {
  let component: RecipeComponent;

  beforeEach(() => {
    component = new RecipeComponent(recipeServiceMock, temperatureServiceMock);
  });
});
```

With our skeleton ready, let's do a first test. We want to make sure that it calls the service to fetch the recipes:

File: `src/recipe.component.spec.ts`

```typescript
it("calls a service to fetch the recipes", () => {
  component.fetchRecipes();
});
```

Wait a second, we are simply calling the `fetchRecipes` method, that yes, it is supposed to call the service. But we aren't sure. How can we assert this?

## Spies

Spies allows us to record information on how a function were called. We can see how many times a function has been called, if parameters were used...

That is perfect. It is just what we need, isn't it? Jest has a method that creates an spy for us:

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=["5-11"]}
import { RecipeComponent } from "./recipe.component";
import { RecipeService } from "./recipe.service";
import { TemperatureService } from "./temperature.service";

const recipeServiceMock: RecipeService = {
  getRecipes: jest.fn()
}

const temperatureServiceMock: TemperatureService = {
  fahrenheitToCelsius: jest.fn()
}
```

Now both `getRecipes` and `fahrenheitToCelsius` are empty functions like before, but decorated with spying technology.

Thanks to that, we can update our test as follows:

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[4]}
it("calls a service to fetch the recipes", () => {
  component.fetchRecipes();
  
  expect(recipeServiceMock.getRecipes).toHaveBeenCalled();
});
```

Here we say: We call `fetchRecipes` and we expect `getRecipes` from our `RecipeService` to have been called.

Does our test pass?

![1 test pass](/images/posts/testing/mocks/2.png)

It sure does. How is the service going to fetch the recipes for us? We don't care. I just need to know that my component is calling the right method at the right time. No service's code was even executed here.

Ok, while that is true and many of our tests are as simple as that, the real implementation returns a list of recipes that we store in our component. We need to test that as well because even if the service was called, we might have forgotten to assign the result to a variable.

Let's augment our mock to both spy and return recipes.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[2, "5-12", 16]}
import { RecipeComponent } from "./recipe.component";
import { Recipe, RecipeService } from "./recipe.service";
import { TemperatureService } from "./temperature.service";

const recipes: Recipe[] = [
  {
    name: "Chicken with cream",
    ingredients: ["chicken", "whipping cream", "olives"],
    cookTemperature: 400,
    temperatureUnit: 'F',
    steps: "Cook the chicken and put in the oven for 25 minutes"
  }
];

const recipeServiceMock: RecipeService = {
  getRecipes: jest.fn().mockReturnValue(recipes)
};
```

First we created a mock recipe and then we added the `.mockReturnValue` to our spy so it also returns a value.

Now we can add a new expectation to our test.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[4]}
it("calls a service to fetch the recipes", () => {
  component.fetchRecipes();
  
  expect(component.recipes).toBe(recipes);
  expect(recipeServiceMock.getRecipes).toHaveBeenCalled();
});
```

![1 test pass](/images/posts/testing/mocks/2.png)

Tests still pass. So we now assert that the service gets called and that the recipes are assigned locally.

> NOTE: We can have as many expectations as we need in a single test. It is not limited to just one.

For our second test, we want to make sure that we can get our recipes with the temperature in celsius.

File: `src/recipe.component.spec.ts`

```typescript
it('can print the recipes with celsius using a service', () => {
  component.fetchRecipes();

  expect(component.recipes[0].cookTemperature).toBe(400);
  expect(component.recipes[0].temperatureUnit).toBe('F');

  const recipesInCelsius = component.printRecipesInCelsius();

  const recipe = recipesInCelsius.pop();

  expect(recipe.cookTemperature).not.toBe(400);
  expect(recipe.temperatureUnit).toBe('C');
  
  expect(temperatureServiceMock.fahrenheitToCelsius).toHaveBeenCalledWith(400);
});
```

Let's go step by step. First we call `fetchRecipes` to populate the component's recipes. Then before we do any change, we assert that the current temperature and unit are the default ones.

Next, we call `printRecipesInCelsius` and we assert that the `cookTemperature` is no longer 400 (we don't care about the exact number in this test. We assume that is tested in the service's tests) and also that the unit is 'C'.

Lastly, we want to know that the service was called with the correct parameter.

![2 test pass](/images/posts/testing/mocks/3.png)

This test is also passing.

At this point we are really done. We have tested that our component uses the services in the correct way but we are not meddling in how they do it.

## Do we always need to mock?

Ha, good question. There are different answers depending to whom you ask. I believe that if a service is THAT simple, we shouldn't worry about mocking it. Surely the real `RecipeService` would use HTTP calls to retrieve the recipes, but the `TemperatureService` is that simple that it won't affect our tests at all.

In other words, if a service is small, has no dependencies and runs fast, we can decide not to mock it at all.

Let's update our code to not use a mock for temperature:

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[5, 11]}
const recipeServiceMock: RecipeService = {
  getRecipes: jest.fn().mockReturnValue(recipes)
};

const temperatureService = new TemperatureService();

describe("RecipeComponent", () => {
  let component: RecipeComponent;

  beforeEach(() => {
    component = new RecipeComponent(recipeServiceMock, temperatureService);
  });
```

Here we just instantiate our original `TemperatureService`. For this to work, we need to comment out a line of our test.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[14]}
it('can print the recipes with celsius using a service', () => {
  component.fetchRecipes();

  expect(component.recipes[0].cookTemperature).toBe(400);
  expect(component.recipes[0].temperatureUnit).toBe('F');

  const recipesInCelsius = component.printRecipesInCelsius();

  const recipe = recipesInCelsius.pop();

  expect(recipe.cookTemperature).not.toBe(400);
  expect(recipe.temperatureUnit).toBe('C');
  
  // expect(temperatureServiceMock.fahrenheitToCelsius).toHaveBeenCalledWith(400);
});
```

Since it is not a mock anymore, we cannot do that.

![2 test pass](/images/posts/testing/mocks/3.png)

But isn't this solution now worse? At least before we made sure that the service was called and now we cannot do that anymore. Right. We can spy on the real service as we did before.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[2, 15]}
it('can print the recipes with celsius using a service', () => {
  jest.spyOn(temperatureService, 'fahrenheitToCelsius');
  component.fetchRecipes();

  expect(component.recipes[0].cookTemperature).toBe(400);
  expect(component.recipes[0].temperatureUnit).toBe('F');

  const recipesInCelsius = component.printRecipesInCelsius();

  const recipe = recipesInCelsius.pop();

  expect(recipe.cookTemperature).not.toBe(400);
  expect(recipe.temperatureUnit).toBe('C');
  
  expect(temperatureService.fahrenheitToCelsius).toHaveBeenCalledWith(400);
});
```

![2 test pass](/images/posts/testing/mocks/3.png)

`jest.spyOn` is the same as using `jest.fn` before but applied to an existing method. In this case it will also call the real service, but as we said before, it is small and simple so it doesn't really matter.

File: `src/recipe.component.spec.ts`

```typescript {hl_lines=[2, 15]}
it('can print the recipes with celsius using a service', () => {
  jest.spyOn(temperatureService, 'fahrenheitToCelsius');
  component.fetchRecipes();

  expect(component.recipes[0].cookTemperature).toBe(400);
  expect(component.recipes[0].temperatureUnit).toBe('F');

  const recipesInCelsius = component.printRecipesInCelsius();

  const recipe = recipesInCelsius.pop();

  expect(recipe.cookTemperature).not.toBe(400);
  expect(recipe.temperatureUnit).toBe('C');
  
  expect(temperatureService.fahrenheitToCelsius).toHaveBeenCalledWith(400);
});
```

![2 test pass](/images/posts/testing/mocks/3.png)

## Conclusions

When doing unit testing, we need to mock out some of our dependencies so the focus of our testing is just the piece of code we are testing and not its dependencies.

In the tests, we make sure that our code is doing what it is supposed to do and also that it is using it's dependencies in the right way and also in the exact moment.

If one of the dependencies is too small, has no dependencies and it is fast, we could simply use the real one.

In the next section, we will start our Angular component.