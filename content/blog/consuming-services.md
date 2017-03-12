+++
date = "2013-08-04T13:12:24+01:00"
title = "Consuming services"
tags = ["services"]

+++

Even when this sounds like something easy to do, 1 out of 3 questions we get on #angularjs (IRC channel at Freenode) are about the same problem and that is what I am going to cover in this article.

Let's write a dummy service for authentication (I promise an article about real auth services in the near future :P):

File: `auth.js`:
```javascript
app.service('Auth', function() {
  var auth = {};
  
  auth.loggedIn = false;
  
  auth.login = function() {
    auth.loggedIn = true;
  };
  
  auth.logout = function() {
    auth.loggedIn = false;
  };
  
  return auth;
});
```

<!--more-->

Nothing fancy, we have a function to "login" and one to "logout".

Now we want to consume it in our controller:

File: `mainctrl.js`:
```javascript
app.controller('MainCtrl', function($scope, Auth) {
  $scope.loggedIn = Auth.loggedIn;
  
  $scope.login = function() {
    Auth.login();
  };
  
  $scope.logout = function() {
    Auth.logout();
  };
  
  $scope.isAuthenticated = function() {
    return $scope.loggedIn;
  };
});
```

With our template:

File: `index.html`:
```html
<body ng-controller="MainCtrl">
  <div ng-switch="loggedIn">
    <span ng-switch-when="false">Hello Guest!</span>
    <span ng-switch-when="true">Welcome back User</span>
  </div>
  
  <button ng-click="login()">Login</button>
  <button ng-click="logout()">Logout</button>
</body>
```

We expect that if we click on the `login` button we are going to be logged in. Is that true?

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ajojug/5/embed?live">Consuming services</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Uhm, no matter how many times I click on the login button, nothing happens. That is weird... `$scope.loggedIn` is equal to the service's `loggedIn` but when I update the service with the buttons I get no updates.

The problem doesn't lie in Angular, this is a common misunderstanding of how Javascript works.

This is how some people think this is working:

![](/images/consumingservices/diag1.jpeg)

But what is really happening is this:

![](/images/consumingservices/diag2.jpg)

Why is this happening? Let's see an example:

```javascript
var a = 10;
var b = a;
a = 20;
console.log(b); // 10
```

What has happened here? We created two variables, `a` with the value of `10` and `b`. We assign the **value** of `a` to `b` **not a reference**, so what `b` has is a copy of the value of `a`. Then if we assign a different value to `a`, `b` won't change because what `b` contains is a primitive with the value of `10`.

So when we did:

```javascript
$scope.loggedIn = Auth.loggedIn;
```

What we did was just **copying** the value of `Auth.loggedIn`, aka `false`, to `$scope.loggedIn`, so if the `Auth` service updates, and with our current implementation, we won't notice it.

Let's see another example:

```javascript
var obj = {foo: "Foo", bar: "bar"};
var b = obj;
obj["baz"] = "baz";
console.log(b); // Object {foo: "foo", bar: "bar", baz: "baz"}
```

In this case, when `b` is assigned to `obj`, we are assigning the reference of `obj`, so if `obj` is changed, `b` will be changed too (and viceversa). This is how we want to use our services.

Notice that our service returns an object, so if we can assign it to our `$scope`, then we can update the service without fear. Let's see:

File: `mainctrl.js`:
```javascript
app.controller('MainCtrl', function($scope, Auth) {
  $scope.auth = Auth;
});
```

File: `index.html`:
```html
<body ng-controller="MainCtrl">
  <div ng-switch="auth.loggedIn">
    <span ng-switch-when="false">Hello Guest!</span>
    <span ng-switch-when="true">Welcome back User</span>
  </div>
  
  <button ng-click="auth.login()">Login</button>
  <button ng-click="auth.logout()">Logout</button>
</body>
```

We assigned a **reference** of our `Auth` service (which is an `object`) into `$scope.auth` and since it is a `reference` and not a `value` we can modify our `Auth` service without the fear of having a `$scope.auth` with "outdated" data.

See it by yourself:

## Try it

<a class="jsbin-embed" href="http://jsbin.com/ajojug/3/embed?live">Consuming services</a><script src="http://static.jsbin.com/js/embed.js"></script>

***

Now it works! And in my humble opinion, it makes more sense to have a reference to the service just once instead of having your service replicated again in the controller.

![](/images/consumingservices/diag3.jpg)

Here we see how `MainCtrl` consumes the service and `loggedIn` has a reference to the `Auth` service.

Having this in mind, this is just one way to consume your services. You may like it, or maybe not. That is not a problem because Angular is not opinionated in these things, so depending on your use case, you could need to consume it in different ways.

One of the drawbacks of this way is that you're giving the view knowledge about your service. That can be non desired in certain cases. On the other hand, you would need to do some things in the controller when you login or logout. In both cases, you could rewrite your code like this:

File: `auth.js`:
```javascript
app.service('Auth', function() {
  var loggedIn = false; // this is private
  
  return {
    login: function() {
      loggedIn = true;
    },
    logout: function() {
      loggedIn = false;
    },
    isAuthenticated: function() {
      return loggedIn;
    }
  };
});
```

File: `mainctrl.js`:
```javascript
app.controller('MainCtrl', function($scope, Auth) {
  $scope.isAuth = Auth.isAuthenticated;
  $scope.login = function() {
    // Do things before login
    Auth.login();
    // Do extra things after login
  };
  $scope.logout = Auth.logout; // No need for extra things
});
```

File: `index.html`:
```html
<body ng-controller="MainCtrl">
  <div ng-switch="isAuth()">
    <span ng-switch-when="false">Hello Guest!</span>
    <span ng-switch-when="true">Welcome back User</span>
  </div>
  <button ng-click="login()">Login</button>
  <button ng-click="logout()">Logout</button>
</body>
```

Now the view doesn't have any knowledge of the service.

As you can see, we can assign to our scope the functions we have in the service as we did with `isAuth` and `logout` or create a function that will do extra things plus the call to the `login` method of the service.

Even when this is a matter of personal design decisions, I think that there are use cases for both solutions.

And last but not least, I want to thank [PigDude](https://oinksoft.com/) because it was he who gave the solution with awesome examples and explanations, as well as all the users of `Hacker news` who were kind to point some issues that had to be fixed. Having said this, I highly recommend all of you to join us in #angularjs at Freenode. And remember, the blog is on [github](https://github.com/Foxandxss/angular-tips) so you can send your pull requests :).
