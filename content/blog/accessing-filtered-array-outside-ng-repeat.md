+++
date = "2014-08-11T14:16:27+01:00"
title = "Tip: accessing filtered array outside ng-repeat"
categories = []
tags = ["tip"]
description = ""

+++

There is a common question I get time to time, so I decided to write about it here.

Let's say I have an array of people and I filter them on a `ng-repeat`, then I want to access that filtered result to do something. I can imagine a few different use cases:

* See how many items matched your search to recalculate your pagination.
* Change the template based on the number of results you have.
* Display a message if you got no results.
* Show the quantity of items returned from your search.
* Etc.

<!--more-->

Let's start with our controller:

```javascript
app.controller('MainCtrl', function($scope) {
  $scope.people = ['fox', 'rosi', 'err3', 'rob', 'cesar', 'geoff'];
});
```

And then our html:

```html
<body ng-controller="MainCtrl">
  <h2>List of people</h2>
  Search: <input type="text" ng-model="search">
  <ul>
    <li ng-repeat="person in people | filter:search">
      {{ person }}
    </li>
  </ul>
  
  Number of filtered people: {{people.length}}
</body>
```

## Try it

<iframe src="http://embed.plnkr.co/9VcesnxC9bqq3DxpcAxI/preview" style="width:100%; height:320px" frameborder="0"></iframe>

***

Uhm, it doesn't update the number of filtered people... It keeps saying 6 no matter what. Also, if there is no result, I wanted to see any message, at least to know that I got no results and it is not an error.

Ok, I hear you, but how can we achieve that? Well, we can't do a `length` on the original array, it never changes. What if we create a new array that hold only the filtered people? Yeah, why not? We could create some method on our controller to do the filtering and then iterate over it with `ng-repeat`. That is fine but that defeats the purpose of our nifty HTML with no extra code for filtering. Can't we do better? Yeah, let's see:

```html
<body ng-controller="MainCtrl">
  <h2>List of people</h2>
  Search: <input type="text" ng-model="search">
  <ul>
    <li ng-repeat="person in filteredPeople = (people | filter:search)">
      {{person}}
    </li>
  </ul>
  <p ng-hide="filteredPeople.length">There is no result</p>
  
  Number of filtered people: {{filteredPeople.length}}
</body>
```

What's going on here? We are creating that new array directly on the HTML. The idea can be read as follow: Filter our `people` array, save the result on a new `filteredPeople` array and finally, iterate over it.

What's the advantage here? That we can access our `filteredPeople` where we need it, both in our HTML and controller. Having that in mind, we can now access its `length` property to show a message if there are no results and even to count the number of filtered people.

But what are the disadvantage? `filteredPeople` is going to be evaluated in every `$digest` and on a big big list it can be problematic and then is when we should consider doing the filtering on the controller.

## Try it

<iframe src="http://embed.plnkr.co/8EqIoAFn6arDA80riY3o/preview" style="width:100%; height:320px" frameborder="0"></iframe>

***

That is all. A nice trick for a really common problem that comes useful on small to medium lists.
