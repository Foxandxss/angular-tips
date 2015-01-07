---
layout: post
title: "A Backend-less plunker"
date: 2015-01-07 11:59
comments: true
categories: [plunker]
---

So you are asking for help and someone says... hey plunk it so we can see it.

Right, even when we should be able to reproduce **any** problem in a small example, there are some difficult ones.

Imagine this conversation:

* Hey I am creating a todo list but when I try to update a `todo` it changes and then immediately changes back.
* Good, can you make a plunker for that?
* Uhm no, it uses my (insert here a backend) and I can't use it on a plunker.

It is not an uncommon issue at all. What could be a good solution? Swap our service that talks with the backend with a different one swapping the `$http` calls with fake data? Yeah, we could, but if you start modifying your **original implementation**, it will be harder to debug, because the problem could lie on that `original` service and it is not there to test.
<!--more-->
Ok... so what to do?

First, we are going to plunk what we have:

```javascript
angular.module('plunker', [])

  .factory('Todos', function($http) {
    return {
      all: function() {
        return $http.get('/api/todos');
      }
    };
  })

  .controller('MainCtrl', function($scope, Todos) {
    Todos.all().then(function(result) {
      $scope.todos = result.data;
    });
  });
```

And:

```html
<h2>Our list of Todos</h2>
<ul>
  <li ng-repeat="todo in todos">
    <input type="checkbox" ng-model="todo.completed" />{{ todo.title }}
  </li>
</ul>
```

<iframe src="http://embed.plnkr.co/diIilSPApTNw9XuY98UO/preview" style="width:100%; height:320px" frameborder="0"></iframe>

So we get nothing, well lies, we get a `GET http://run.plnkr.co/api/todos 404 (Not Found)` in the console. That was expected, the `$http` service is trying to reach and non existent route to fetch our data.

So again, what can we do?

Angular folks created the framework with testability in mind and we can certainly use that in our advantage here.

The `$http` service which is also used by `$resource` and `restangular`, does not talk with your backend directly, in fact there is another layer called `$httpBackend` which is the one that does all the real stuff. We can use that layer to create a fake backend for our example.

The first thing we need to do, is to add `angular-mocks.js` as a dependency in our plunker. `Angular mocks` will swap the original `$httpBackend` with a fake one that we can use for testing or to simulate a backend. Oh, simulate a backend, just what we need.

Before we proceed, there is something important to keep in mind: When we swap the `$httpBackend`, it will swallow **every** `$http` request.

Right, we create a `backend.js` file on our plunker (and its script tag after the app.js file) so we can start coding our fake backend:

```javascript
angular.module('plunker')
  .run(function($httpBackend) {
    
  });
```

So on application start, we will add our backend logic starting with some fake data:

```javascript
var things = [
  {
    id: 0,
    title: 'Finish fake backend',
    completed: true
  },
  {
    id: 1,
    title: 'Make some cool stuff',
    completed: false
  },
  {
    id: 2,
    title: 'Brainstorm new projects',
    completed: false
  }
];
```

Good, we have a couple of `things` for our `todo list` so now we need a way to `GET` them:

```javascript
$httpBackend.whenGET('/api/todos').respond(200, things);
```

The mocked `$httpBackend` provides a couple of `whenXXX` methods that we can use to catch all those requests and process them.

In this case we are using `whenGET` which receives an URL as parameter (which is the URL of the request) and then we use the `.respond` method on it where we pass the status code and the data we want to send back.

This can be read like: When we do a `GET` on `/api/todos` please respond with a status 200 (OK) and this list of todo items.

For a starter, that should be enough for our little demo, isn't it? Sure, try it out...

Nah, it doesn't work yet, how so? We are still working with the original `$httpBackend` because we haven't told `Angular` to use the `Angular mocks` one. We can do that in two ways:

* We can add `ngMockE2E` as a dependency on our `plunker` module.
* Or we can swap the `$httpBackend` manually with a decorator.

The first approach is easier, but the second one is better because we can have all our fake backend stuff in one file so we can plug it in any plunker easily.

Alright, how can we do that? Just add a `.config` method inside `backend.js` like this:

```javascript
.config(function($provide) {
  $provide.decorator('$httpBackend', angular.mock.e2e.$httpBackendDecorator);
})
```

With that we are doing something like... get the `$httpBackend` service and change it for this one from `Angular mocks`.

If we try our example now... it works!

<iframe src="http://embed.plnkr.co/qD5y3cvxwCZduqpWoUdI/preview" style="width:100%; height:320px" frameborder="0"></iframe>

So, to recap here: We have our **original implementation** angular implementation and also we have a pluggable fake backend which we can just use in any plunker without hassle or extra configuration.

Still a backend with just support `GET` requests is not a backend, so let's finish the `backend.js` implementation.

`POST` requests:

```javascript
$httpBackend.whenPOST('/api/todos').respond(function(method, url, data, headers) {
    var newItem = JSON.parse(data);
    newItem.id = things.length;
    things.push(newItem);
    
    return [201, newItem];
  });
```

We can use a callback function in `.respond` which receives:

* method -> `POST` in our case.
* url -> `/api/todos` here.
* data -> The object we send with the `POST`.
* headers -> The headers of the request.

For a `POST` request, we parse our `data` (a new `todo`), we assign it an `id`, we push it to our list of `things` and finally we return an array composed of the status code and the new item (like a real backend would do).

`PUT` request:

```javascript
$httpBackend.whenPUT(/^\/api\/todos\/\d+$/).respond(function(method, url, data, headers) {
  var item = JSON.parse(data);
  for (var i = 0, l = things.length; i < l; i++) {
    if (things[i].id === item.id) {
      things[i] = item;
      break;
    }
  }
  
  return [200, item];
});
```

A `PUT` request needs a parameter which in our case is the `todo` to update. You could expect us to use `/api/todos/:id` as the endpoint, but that is a syntactic sugar that we don't have here. So instead of that, we will use a regexp `/^\/api\/todos\/\d+$/` which will basically match a `PUT` request done to `/api/todos/X` where the `X` is a number.

Alright, now we have our `PUT` endpoint and all we need to do is to parse the `data` which contains the updated fields and then search the corresponding `todo` to update  it. We could use the parameter to find the correct `todo`, but it this case we have the `id` on the item as well. Finally as always we return an array with the status code and the updated item.

`DELETE` request:

```javascript
$httpBackend.whenDELETE(/^\/api\/todos\/\d+$/).respond(function(method, url, data, headers) {
    var regex = /^\/api\/todos\/(\d+)/g;
    
    var id = regex.exec(url)[1]; // First match on the second item.
    
    for (var i = 0, l = things.length; i < l; i++) {
      if (things[i].id === id) {
        var index = things.indexOf(things[id]);
        things.splice(index, 1);
        break;
      }
    }
    
    return [204];
  });
```

The difference here compared to the `PUT` one is that we don't pass any data with the `id` so we need to grab it from the URL and then find the correct `todo` to delete it. My convention on `delete` is to just return a 204 code (Everything OK but nothing get returned). You can easily grab the item before deleting it and return it as well.

With this we have our complete backend that we can simply drop where needed (it is not tied to plunker).

Still, there is something left we need to resolve. Remember when I said that this `$httpBackend` is going to swallow all requests? When we set a `templateUrl`, that is going to use `$http` to get the template and that is going to be swallowed as well, so we can simply add another rule for that:

```javascript
$httpBackend.whenGET(/\.html/).passThrough();
```

When we do a `GET` to something ending with `.html` we let the request do the real thing. That will allow plunker to use external templates.

So, our `backend.js` file will end like:

```javascript
angular.module('plunker')

  .config(function($provide) {
    $provide.decorator('$httpBackend', angular.mock.e2e.$httpBackendDecorator);
  })
  .run(function($httpBackend) {
    var things = [
      {
        id: 0,
        title: 'Finish fake backend',
        completed: true
      },
      {
        id: 1,
        title: 'Make some cool stuff',
        completed: false
      },
      {
        id: 2,
        title: 'Brainstorm new projects',
        completed: false
      }
    ];
    
    $httpBackend.whenGET('/api/todos').respond(200, things);
    
    $httpBackend.whenPOST('/api/todos').respond(function(method, url, data, headers) {
      var newItem = JSON.parse(data);
      newItem.id = things.length;
      things.push(newItem);
      
      return [201, newItem];
    });
    
    $httpBackend.whenPUT(/^\/api\/todos\/\d+$/).respond(function(method, url, data, headers) {
      var item = JSON.parse(data);
      for (var i = 0, l = things.length; i < l; i++) {
        if (things[i].id === item.id) {
          things[i] = item;
          break;
        }
      }
      
      return [200, item];
    });
    
    $httpBackend.whenDELETE(/^\/api\/todos\/\d+$/).respond(function(method, url, data, headers) {
      var regex = /^\/api\/todos\/(\d+)/g;
      
      var id = regex.exec(url)[1]; // First match on the second item.
      
      for (var i = 0, l = things.length; i < l; i++) {
        if (things[i].id === id) {
          var index = things.indexOf(things[id]);
          things.splice(index, 1);
          break;
        }
      }
      
      return [204];
    });
    
    $httpBackend.whenGET(/\.html/).passThrough();
  });
```

  As a final example, let's use the Angular example of [todomvc](www.todomvc.com) in a plunker and then plug our fake backend:

  <iframe src="http://embed.plnkr.co/l4wQnOsnFcf9zE9uLFvy/preview" style="width:100%; height:480px" frameborder="0"></iframe>

  * [Todomvc example](http://plnkr.co/edit/l4wQnOsnFcf9zE9uLFvy?p=preview)
  * [Plunker template with fake backend](http://plnkr.co/edit/tpl:4NUO1oYIWhgya50qR3vK)
  * [Gist with the backend.js](https://gist.github.com/Foxandxss/b6139d9d668c6ea3c673)
