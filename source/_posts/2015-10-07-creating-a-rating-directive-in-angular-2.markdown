---
layout: post
title: "Creating a rating directive in Angular 2"
date: 2015-10-07 18:50
comments: true
categories: [angular2, directives]
---

**Disclaimer: I am not an Angular 2 expert at this point, so I could be wrong with a few things, please comment if I made a mistake.**

I want to tackle some points on this article and a simple rating directives will do the work. Let's build the simplest rating directive ever!

I need a directive where I can rate something and better than a simple input, we want to see 5 stars where I can click on them to get a rating.

Before jumping into code, I want to analyze it and how could we resolve this with Angular 1.
<!--more-->

## Angular 1 way
What's the input we need for this directive? We need some kind of model that represents a rating (a number). For output we want to give back the updated rate. So that means that we give it a model and by clicking on the stars, that model gets updated.

Now for the implementation. What to use? `=` or `@`? If we use `@`, the changes we do inside the directive won't update the parent, so there is no output. That means that we need to use `=` and thanks to that, we have our input and our output:

```html
<rating rate="rate"></rating>
```

To implement it, we can code:

```javascript rating.js
.directive('rating', function() {
  return {
    scope: {
      rate: '='
    },
    templateUrl: 'rating.html',
    link: function(scope, element, attrs) {
      scope.range = [1,2,3,4,5];

      scope.update = function(value) {
        scope.rate = value;
      };
    }
  };
});
```
{% raw %}
```html rating.html
<span tabindex="0">
    <span ng-repeat-start="r in range track by $index" class="sr-only">({{ $index < rate ? '*' : ' ' }})</span>
    <i ng-repeat-end ng-click="update($index + 1)" class="glyphicon" ng-class="$index < rate ? 'glyphicon-star' : 'glyphicon-star-empty'"></i>
</span>
```
{% endraw %}
Simple directive. We use `ng-repeat` to generate as many stars as we need which in this case, we have it hardcoded to 5. When we click on a star, we call the `update` method that will assign a new value on `scope.rate` and thanks to the `$watch` that the `=` creates, our parent gets updated as well.

**NOTE:** The inner span is for accessibility purposes.

Check it [here](http://plnkr.co/edit/ESJee5FYFoAs14IjIh6f?p=preview)

It works nice, right? Sure it does.

I see some flexibility problems here. There could be use cases you don't want the "raw" output. I mean, imagine that you want to use the rating, but instead of having each star counting as "1" you want each star to be "0,2" so a 5 stars is actually 1 point. How could you do that? A `$watch` in our controller perhaps? Let's do it:

```javascript
$scope.$watch('rate', function(newVal) {
  $scope.customRate = newVal / 5;
});
```

Now every time the `rate` changes in our controller (AKA when we receive an output), we create a new variable with our custom rate. The problem in here is that now we have two watches. One that the directive creates to maintain both "rates" in sync and this one to generate our custom rate. The downside is: We are already receiving an output, why couldn't I just hook into that output and do what I want to? Also, even when I am creating this custom rate, the controller's rate is also updated nonetheless.

Could we pass a static number to this directive? Yes:

```html
<rating rate="'3'"></rating>
```

A bit of an ugly syntax but works. The problem is that we lost our ability to receive any output from the directive. We could create some kind of callback like:

```html
<rating rate="'3'" on-update="onUpdate(value)"></rating>
```

Then update our directive like:

```javascript rating.js
.directive('rating', function() {
  return {
    scope: {
      rate: '=',
      onUpdate: '&'
    },
    templateUrl: 'rating.html',
    link: function(scope, element, attrs) {
      scope.range = [1,2,3,4,5];

      scope.update = function(value) {
        scope.rate = value;
        if (scope.onUpdate) {
          scope.onUpdate({value: value});
        }
      };
    }
  };
})
```

Thanks to the weird callback syntax, it now works, both with two-way databinding and also passing a simple value.

See it [here](http://plnkr.co/edit/MSgk2h8dO4VjwEa703S4?p=preview)

Another problem I see with this approach is the side effects. If you use the first approach, you're forced to have "two-way databinding" you want it or not. Your controller's rate is going to be updated every time you click on a star. Luckily you can use bindonce `::` to fix that issue except if the third party directive is using `ng-model`. It is not an issue you will see every day, but there is always a use case for every weird problem.

## Angular 2 way

First, get this [plunker](http://plnkr.co/edit/DbgFeChA9AIUDZpA9JeJ?p=catalogue) so you can follow along.

If you read my previous article on directives, the next code will be pretty familiar:

```javascript rating.ts
import {Component, View} from 'angular2/angular2';

@Component({
  selector: 'rating',
})
@View({
  template: `<div>Rating</div>`
})
export class Rating {}
```

This is the basic skeleton of a component directive in Angular 2. We say in here that we want a component with `rating` as the element selector and a simple message on a div.

Our first step would be to print our 5 stars. To do that, we need to output some HTML for each star. In the Angular 1 version we used a `ng-repeat` and here we have the `ng-for`. There is a problem tho. In the angular 1 version we want the ng-repeat to repeat not only one element but two, the span for accessibility and the `<i>` tag for the actual stars. We managed to fix that with `ng-repeat-start` and `ng-repeat-end`.

How can we do that in Angular 2? We can use a div wrapper and stick the `ng-for` to it or we can use a `<template>` that doesn't output any markup. Let's see how can we do that:

```javascript rating.ts
@View({
  template: `
    <span tabindex="0">
      <template ng-for [ng-for-of]="range" #index="index">
        <span class="sr-only">(*)</span>
        <i class="glyphicon glyphicon-star"></i>
      </template>
    </span>
  `,
  directives: [NgFor]
})
```

So here we say that we want a `<template>` element with the `ng-for` directive in it. We give to it the collection we want to repeat (AKA `range`) and also that we want a reference to the current index on the collection. Notice that I am not getting a reference to the current item on the `range` collection, I don't need it for this basic directive, I just need that template to be repeated as many times as items in the collection. Also notice that I am telling the component that we are using `NgFor` in it (don't forget to import it too!).

Now we just need the range collection:

```javascript rating.ts
export class Rating {
  private range:Array<number> = [1,2,3,4,5];
}
```

Let's wire our directive into the app now. First we import it:

```javascript main.ts
import {Rating} from './rating';
```

And we tell our component that we want to use it:

```javascript main.ts
@View({
  templateUrl: 'src/main.html'
  directives: [Rating]
})
```

```html main.html
<rating></rating>
```

If we execute the app now, we will see our 5 stars, and if we inspect our HTML, we can see:

{% img /images/posts/ng2rating/1.png %}

Yay it works!

Let's receive some input, shall we? To do that, we just need to create an inputs array on our component:

```javascript rating.ts
@Component({
  selector: 'rating',
  inputs: ['rate']
})
```

Ah, this `inputs` is so convenient and well named. Now that we assume that we will have some kind of input, we can update our template to make use of it:
{% raw %}
```javascript rating.ts
@View({
  template: `
    <span tabindex="0">
      <template ng-for [ng-for-of]="range" #index="index">
        <span class="sr-only">({{ index < rate ? '*' : ' ' }})</span>
        <i class="glyphicon"
           [ng-class]="index < rate ? 'glyphicon-star' : 'glyphicon-star-empty'"></i>
      </template>
    </span>
  `,
  directives: [NgFor, NgClass]
})
```
{% endraw %}
We use `ng-class` to apply a star or empty start depending on our input. Easy right? If we pass `2` as input, the first two stars will be normal stars and the other 3 will be empty stars. Don't forget to import `NgClass`.

Let's try it:

```html main.html
<rating rate="2"></rating>
```

It works. Notice how we passed a literal number and our directive doesn't care. Can we pass a dynamic value that comes from our app component? Sure:

```javascript main.ts
export class MyApp {
  private rate:number = 3;
}
```

```html main.html
<rating [rate]="rate"></rating>
```

That was really really easy, no changes needed on our directive.

For our next trick, let's first update our HTML so we can see also the value of `rate` in our app component:
{% raw %}
```html main.html
<rating [rate]="rate"></rating>

<pre style="margin:15px 0;">Rate: <b>{{rate}}</b></pre>
```
{% endraw %}

Now we can see our current rate, but remember, we are seeing the value from the component that is consuming our `rating` directive and not its internal `rate`.

Now, let's make our stars clickable so we can change the rating. First, we modify our template to put a click event:

{% raw %}
```javascript rating.ts
@View({
  template: `
    <span tabindex="0">
      <template ng-for [ng-for-of]="range" #index="index">
        <span class="sr-only">({{ index < rate ? '*' : ' ' }})</span>
        <i class="glyphicon" (click)="update(index + 1)"
           [ng-class]="index < rate ? 'glyphicon-star' : 'glyphicon-star-empty'"></i>
      </template>
    </span>
  `,
  directives: [NgFor, NgClass]
})
```
{% endraw %}

And now the event handler:

```javascript rating.ts
export class Rating {
  private range:Array<number> = [1,2,3,4,5];
  private rate:number;

  update(value) {
    this.rate = value;
  }
}
```

If we click now in our stars, we can see how they get updated, but the rate property in our `my-app` component doesn't update. Why is that? What? Why should it? Our directive only has inputs but no outputs. Updating our "internal" `rate` won't make the "parent" one to get updated. That makes lots of sense to me.

Let's add some outputs:

```javascript rating.ts
@Component({
  selector: 'rating',
  inputs: ['rate'],
  outputs: ['updateRate: rate']
})
```

Again, a well named property. Here we are saying that we will have an output called `rate` (exact same name that our input) but we want to call it `updateRate` locally.

Outputs in Angular 2 are events, so now we are going to initialize it as a proper event:

```javascript rating.ts
export class Rating {
  private updateRate:EventEmitter = new EventEmitter();

  ...
}
```

Don't forget to import `EventEmitter` at the top. Now we just need to emit an event every time our rate gets updated in our `update` method:

```javascript rating.ts
update(value) {
  this.rate = value;
  this.updateRate.next(value);
}
```

The Angular 2 `EventEmitter` is using `Rx`, so this is a proper `Observable`. Here we just `push` a new value every time we click on a star. How to use it on `my-app` component?:

```html main.html
<rating [rate]="rate" (rate)="onUpdate($event)"></rating>
```

So now we specify an input (our `rate` property) and an output (the `rate` event calling a method). So we just need to define that method on our `my-app` component:

```javascript main.ts
export class MyApp {
  private rate:number = 3;

  onUpdate(value) {
    this.rate = value;
  }
}
```

If you test the application now, you can see our `my-app` rate value getting updated.

To summarize, in Angular 2 we have to define our inputs and our outputs. The inputs are properties and the outputs are events. What are the advantages in here? We don't have those flexibility problems I mentioned earlier. You want your `my-app` rate to have different values? You can do it like:

```javascript
onUpdate(value) {
  this.rate = value / 5;
}
```

You want to pass an static number as an input but still be able to manage the output? Sure you can:

```html main.html
<rating rate="2" (rate)="onUpdate($event)"></rating>
```

We get all the different behaviors without any extra code.

Let's think about:

```html main.html
<rating [rate]="rate" (rate)="onUpdate($event)"></rating>
```

Isn't it a bit verbose? If I want to "emulate" the old behavior of having some kind of "two-way databinding", I need to write more html and also a event handler. Luckily, the Angular team created some syntactic sugar for that. You can do:

```html main.html
<rating [(rate)]="rate"></rating>
```

Now we are using our `rate` as input and output at the same time. Again, the nice part of this is that you don't need to write extra code for that, this comes for free. Our users can use the default behavior of having `rate` being updated which each click on a star, we can also let our users to be able to manage the output by hand to do some extra logic (and maintaining our `rate` without changes) or even be able to send static input and still receiving nice outputs.

You can see an example of all of that [here](http://plnkr.co/edit/0lfYTAoREUD8BUtTxpS1?p=preview)

## Conclusions

The Angular team is doing a marvelous job by removing all the verbosity that the Angular 1 directives had. We have an immense flexibility with this new directives and I haven't talk about `Rx` yet, that gives more flexibility to our outputs.
