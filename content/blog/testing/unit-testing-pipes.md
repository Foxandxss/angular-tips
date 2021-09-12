---
title: "Unit Testing - Pipes"
date: 2021-09-12T15:44:04+02:00
draft: false
categories: ["unit test"]
---

(To follow along, download the project from [Github](https://github.com/Foxandxss/datepicker-tutorial) and use the master branch).

In the following sections we are going to develop a `Calendar`. It will allow us to see the current month or navigate to an specific date. As mentioned in the introduction, the Calendar is cumbersome to manually test. We need to check the current month to see that we don't have repeated or missing days. We need to check that the algorithm doesn't degrade if we generate a Calendar for a date in the future. We also need to check that the February of a leap and non leap years is generated correctly as well. Sounds like a waste of time in my book.

The first thing we are going to develop is the Calendar's header. We give it a date and we get something like `September of 2021`. Yes, we are speaking about a pipe here.

Pipes are the easiest component in Angular and they are also the easiest to test.

We are going to follow a TDD approach in this tutorials, so let's open our `calendar.spec.ts` and code a basic skeleton.

File: `libs/calendar/src/calendar.pipe.spec.ts`:

```typescript
import { CalendarPipe } from './calendar.pipe';

describe('CalendarPipe', () => {
  let pipe: CalendarPipe;

  beforeEach(() => {
    pipe = new CalendarPipe();
  });
});
```

Here we are importing our pipe and creating an instance before each test. Let's code one test:

File: `libs/calendar/src/calendar.pipe.spec.ts`:
```typescript {hl_lines=["10-12"]}
import { CalendarPipe } from './calendar.pipe';

describe('CalendarPipe', () => {
  let pipe: CalendarPipe;

  beforeEach(() => {
    pipe = new CalendarPipe();
  });

  it('transforms 2021/06 to "June of 2021"', () => {
    expect(pipe.transform('2021/06')).toBe('June of 2021');
  });
});
```

We defined our API for this pipe in the test. We use a string with the date and it returns us another string with the date in English.

> Note: To run the test, type: `npm run test:all -- --watch` so it runs all tests and enables watch mode.

This obviously fails. Even when our pipe exists, it just returns null.

![first test fails](/images/posts/testing/pipes/1.png)

Let's code it:

File: `libs/calendar/src/calendar.pipe.ts`:
```typescript {hl_lines=["7-12"]}
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'calendar',
})
export class CalendarPipe implements PipeTransform {
  transform(value: string): string {
    const dateParts = value.split('/');

    const date = new Date(+dateParts[0], +dateParts[1]);

    return `${date.toLocaleDateString('en-us', { month: 'long'})} of ${date.getFullYear()}`;
  }
}
```

We split the date in two strings that we use to create a new date object. Then we construct a string out of it. The test pass correctly:

![first test still fails](/images/posts/testing/pipes/2.png)

Ah, it doesn't. 

...

Oh, I see, dates in Javascript are 0 based, so if we send `06` it means July and not June. Since it is a good practice to provide an easy API, we are going to modify our code so the API is **not** 0-based.

File: `libs/calendar/src/calendar.pipe.ts`:
```typescript {hl_lines=["4"]}
transform(value: string): string {
  const dateParts = value.split('/');

  const date = new Date(+dateParts[0], +dateParts[1] - 1);

  return `${date.toLocaleDateString('en-us', { month: 'long'})} of ${date.getFullYear()}`;
}
```

![first test pass](/images/posts/testing/pipes/3.png)

Much better.

> Fun fact: This API is quite odd. Having to split a string in two, cast the strings into numbers and then create a date object is well, not too smart. As we follow through this course, we will see many times that this API is horrible. This is a good proof that a well tested code doesn't imply that it is better or easier to use. It just means that it works as expected.

With our first test working, let's use the API in other ways to see if it behaves:

File: `libs/calendar/src/calendar.pipe.ts`:
```typescript
it('transforms 2040/8 to "August of 2040"', () => {
  expect(pipe.transform('2040/8')).toBe('August of 2040');
});
```

![second test pass](/images/posts/testing/pipes/4.png)

Without the extra 0, it still works as expected.

What happens if we pass a malformed date?

File: `libs/calendar/src/calendar.pipe.ts`:
```typescript
it('transforms 2021 to "Unknown date"', () => {
  expect(pipe.transform('2021')).toBe('Unknown Date');
});
```

![third test fail](/images/posts/testing/pipes/5.png)

`Invalid Date of NaN`. Yeah, that is what I get when I input my holidays. Jokes aside, let's fix that:

File: `libs/calendar/src/calendar.pipe.ts`:
```typescript {hl_lines=["9"]}
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'calendar'
})
export class CalendarPipe implements PipeTransform {
  transform(value: string): string {
    const dateParts = value.split('/');

    if (dateParts.length !== 2) { return 'Unknown Date'; }

    const date = new Date(+dateParts[0], +dateParts[1] - 1);

    return `${date.toLocaleDateString('en-us', { month: 'long' })} of ${date.getFullYear()}`;
  }
}
```

We simply check if the string is malformed and if so, we return an error string.

![all test pass](/images/posts/testing/pipes/6.png)

## Conclusions

Testing pipes is really easy. It is not any different to our `Calculator example`. We instantiate it, we write some tests and that is it.

Next, we will code our Calendar's heart, the service.