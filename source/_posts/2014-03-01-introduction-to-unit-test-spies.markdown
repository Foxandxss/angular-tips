---
layout: post
title: "Introduction to unit test: spies"
date: 2014-03-01 18:52
comments: true
categories: [unit test]
---

Before we deep more into `Angular` lands, I want to talk about spies. No, no that kind of spies.

When you are doing unit testing, you don't want to leave your `SUT` (subject under test) domain. If you're testing a controller in Angular and it injects 3 services, you don't care about those services, you only want to test that controller but also make sure it uses the services as intended.
<!--more-->
That means that if your controller calls a service when doing something, you only want to know that the service was called but without actually using the service. Uhm, I am confused, how can I test that I called a service without using it? And what if I need what it was supposed to return to the controller? And and and...

Jasmine has a concept called `spies`. You can `spy` functions and then you will be able to assert a couple of things about it. You can check if it was called, what parameters it had, if it returned something or even how many times it was called!

`Spies` are highly useful when writing tests, so I am going to explain how to use the most common of them here.

For the tutorial sake, we are going to use a little snippet I created earlier: (Remember you can follow along using this [plunk](http://plnkr.co/edit/tpl:BwELtfQGfM9ODbyuj9RG))

```javascript
//This is the one we don't care about
function RestService() {
}

RestService.prototype.init = function() {
  // Some init stuff
};

RestService.prototype.getAll = function() {
  return []; // Return elements
};

RestService.prototype.update = function(item) {
  console.log("Updating the item");
};

// This is our SUT (Subject under test)
function Post(rest) {
  this.rest = rest;
  rest.init();
}

Post.prototype.retrieve = function() {
  this.posts = this.rest.getAll();
};

Post.prototype.accept = function(item, callback) {
  this.rest.update(item);
  if (callback) {
    callback();
  }
};
```

We have here our `SUT` which is a `Post` constructor. It uses a `RestService` to fetch its stuff. Our `Post` will delegate all the `Rest` work to the `RestService` which will be initialized when we create a new `Post` object. Let's start testing it step by step:

```javascript
describe('Posts', function() {
  var rest, post;

  beforeEach(function() {
    rest = new RestService();
    post = new Post(rest);
  });
});
```

Nothing new here. Since we are going to need both instances in every test, we put the initialization on a `beforeEach` so we will have a new instance every time.

Upon `Post` creation, we initialize the `RestService`. We want to test that, how can we do that?:

```javascript
it('will initialize the rest service upon creation', function() {
  spyOn(rest, 'init');
  post = new Post(rest);
  expect(rest.init).toHaveBeenCalled();
});
```

We want to make sure that `init` on `rest` is being called when we create a new `Post` object. For that we use the jasmine `spyOn` function. The first parameter is the object we want to put the spy and the second parameter is a string which represent the function to spy. In this case we want to spy the function `'init'` on the `spy` object. Then we just need to create a new `Post` object that will call that `init` function. The final part is to assert that `rest.init` have been called. Easy right? Something important here is that the when you spy a function, the real function is never called. So here `rest.init` doesn't actually run.

Wait second, we already created the new `Post` object in the `beforeEach`! That is true, but here is an important concept: You can't call a function, then spy it and assert it. Since on the `beforeEach` we already called the `init` function, the spy won't work, that is why we recreate a new object for the test sake. You can also create the spy on the `beforeEach` but since we just need it once, we do it on the `it`.

Our next test is about retrieving the data from the `RestService`. Since it doesn't return anything, what we could do is to make sure that the `getAll` function have been called and also that our `this.posts` contains what `getAll` returned. Wait a second. Does the spy return stuff? Sure!

```javascript
it('will receive the list of posts from the rest service', function() {
  var posts = [
    {
      title: 'Foo',
      body: 'Foo post'
    },
    {
      title: 'Bar',
      body: 'Bar post'
    }
  ];
  
  spyOn(rest, 'getAll').and.returnValue(posts);
  post.retrieve();
  expect(rest.getAll).toHaveBeenCalled();
  expect(post.posts).toBe(posts);
});
```

We create an array of fake posts and then we call `spyOn` on the `getAll` function. We can make an spy returns something when called using `and.returnValue`, which is called with our fake posts.

Having our spy in place, all what we need to do is to call `post.retrieve` and then assert that `getAll` was called and that also `post.posts` contain our fake posts that were returned by `getAll`.

We now want to test our `accept` function. We know that it will send a post to be updated on the `RestService` so we need to be sure that the post was sent as a parameter.

```javascript
it('can accept a post to update it', function() {
  var postToAccept = {
    title: 'Title',
    body: 'Post'
  };
  spyOn(rest, 'update').and.callThrough();
  post.accept(postToAccept);
  expect(rest.update).toHaveBeenCalledWith(postToAccept);
});
```

We start with the fake post we want to update and then we create the spy. What is that `and.callThrough`? Well, as you know, the real function is never called, but if you really need to spy it and also call it, you can do it with `and.callThrough`. To see this working, you can check how `rest.update` logs a message on the dev console.

**Note**: There is no real reason to use `and.callThrough` here, I did it to show how it works.

After that, we just call `post.accept` passing our fake post and then assert that `rest.update` was indeed called with fake post as a parameter.

If you remember, we had the option to pass a callback to the `accept` function. Let's test that:

```javascript
it('can receive a callback upon accept', function() {
  var fn = jasmine.createSpy();
  var postToAccept = {
    title: 'Title',
    body: 'Post'
  };
  post.accept(postToAccept, fn);
  expect(fn).toHaveBeenCalled();
});
```

See how we created a `spy` this time. We needed a function to pass to the `accept` function as a callback method so we could perfectly create an object with a function and spy it as we used to, but we can create a spied function from scratch using `createSpy`. After that, we pass it to `accept` and as always, we assert that it was called.

In `Angular` spies are heavily used on any kind of unit test. When we are testing something, we don't care about the injected dependencies, we just need to make sure that they were used properly.

Spies are not the only solution and in fact, angular offer advanced ways to do this, ways I am going to explain later on this blog.

If you were lazy enough to not replicate this on a plunk, here it is [completed](http://plnkr.co/edit/473hGDlrLKYy9vKSPg4Z?p=preview)