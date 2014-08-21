---
layout: post
title: "introduction to unit test: controllers"
date: 2014-06-05 14:47
comments: true
categories: [unit test]
---

Testing angular controllers is not hard but a bad controller usage can make our tests a nightmare. We need to keep our controllers as lean as possible.
<!--more-->

For this example, we want a controller which will manage a list of javascript libraries where we can add new ones or do a redirect to a library's details page.

Is dealing with libraries a controller job? It is not, so we need a service for that. We don't really need to code the service, because as we did earlier with the services tests, we are going to mock it. But for the sake of the article, let's put an example of how it should look:

```javascript
angular.module('app').factory('restService', function() {
  return {
    getAll: function() {
      // We do a $http call to retrieve the stuff
    },
    create: function(itemName) {
      // We do a $http post to send the new one
    }
  }
});
```

That is all we need for this example. A method to retrieve all the libraries from an endpoint and also one to create new libraries. We guess that it will use `$http` to do the job.

Alright, we know what we want to do, so let's prepare our tests:

```javascript
describe('Controller: ListLibrariesController', function() {
  var scope, restService, $location;
});
```

What do we need to prepare here? We are going to need a mocked `restService` first. Since the real one would use `$http` and that involves `promises`, we are going to simulate that also (I planned to do that on a separate article, but here we are). Let's do it:

```javascript
beforeEach(function() {
  var mockRestService = {};
  module('app', function($provide) {
    $provide.value('restService', mockRestService);
  });
  
  inject(function($q) {
    mockRestService.data = [
      {
        id: 0,
        name: 'Angular'
      },
      {
        id: 1,
        name: 'Ember'
      },
      {
        id: 2,
        name: 'Backbone'
      },
      {
        id: 3,
        name: 'React'
      }
    ];
    
    mockRestService.getAll = function() {
      var defer = $q.defer();
      
      defer.resolve(this.data);
      
      return defer.promise;
    };
    
    mockRestService.create = function(name) {
      var defer = $q.defer();
      
      var id = this.data.length;
      
      var item = {
        id: id,
        name: name
      };
      
      this.data.push(item);
      defer.resolve(item);
      
      return defer.promise;
    };
  });
});
```

Whoa, this is not as easier as the mock we did for the [services article](/blog/2014/06/introduction-to-unit-test-services). Here we don't want to hit a real endpoint, so we are creating a mock service. This mock service contains a bunch of fake data and also two methods. One to get all our data and one to create one piece of data. As you can see, we are using `$q` to simulate the `$http`'s promise behavior. The whole idea is to create a mock service that will have the same interface.

Also, we did here a little different than the other article. In the past, we created the entire mock inside the callback of the `module` function but here we did not. We can't inject `$q` into that callback because it only allow providers and `$q` is not a provider.

What we did then is to create an empty object, load the module, mock the service and then created the rest of the mock service. Why in this order? Why don't create the mock and then load it with the module? If you try to use `module()` after we used `inject()` angular will throw an exception. So because of that, we need to do this in this concrete order.

**NOTE**: Why are we using this really big `mock` here instead of an `spy`? That is a good question. Since this service relies on `promises`, and a `spy` is not meant for complex behavior, we need a way to test our promise usage. Imagine our controller does something on promise success and on promise failure. How do you achieve that with a simple `spy` ? It is better to mock out that function to create a promise that could both resolve or reject that promise. I think that the TL;DR; here is to use `spy` when possible and mocks if we need to tests promises.

Ok, we have our mock in place. All we need now is to load the rest of the dependencies and setup the controller:

```javascript
beforeEach(inject(function($controller, $rootScope, _$location_, _restService_) {
  scope = $rootScope.$new();
  $location = _$location_;
  restService = _restService_;
}));
```

Here we inject a bunch of stuff and we assign them to our local variables. You can notice here that we are injecting the `restService` here and on the last article we did not. Both options are good. You can create a mock, save it on a variable and use it when needed (as we did on the [services article](/blog/2014/06/introduction-to-unit-test-services)) or you can create the mock and then inject it where you need it.

We need to instantiate our controller somehow, right? Indeed:

```javascript
beforeEach(inject(function($controller, $rootScope, _$location_, _restService_) {
  scope = $rootScope.$new();
  $location = _$location_;
  restService = _restService_;
  
  $controller('ListLibrariesCtrl',
                {$scope: scope, $location: $location, restService: restService });
  
  scope.$digest();
}));
```

To instantiate our controller, we use the `$controller` service. It receives the name of the controller we want and also the list of dependencies as an object. Since our controller will have access to `$scope`, `$location` and `restService` we pass it as dependencies. We could save the controller it returns, but we don't need to do that on this example.

We also run a manual `$digest` to resolve all the promises we have on the mocked service.

Let's go with the tests!

```javascript
it('should contain all the libraries at startup', function() {
  expect(scope.libraries).toEqual([
    {
      id: 0,
      name: 'Angular'
    },
    {
      id: 1,
      name: 'Ember'
    },
    {
      id: 2,
      name: 'Backbone'
    },
    {
      id: 3,
      name: 'React'
    }
  ]);
});

it('should create new libraries and append it to the list', function() {
  // We simulate we entered a new library name
  scope.newItemName = "Durandal";
  
  // And that we clicked a button or something
  scope.create();
  
  var lastLibrary = scope.libraries[scope.libraries.length - 1];
  
  expect(lastLibrary).toEqual({
    id: 4,
    name: 'Durandal'
  });
});

it('should redirect us to a library details page', function() {
  spyOn($location, 'path');
  
  var aLibrary = scope.libraries[0];
  
  // We simulate we clicked a library on the page
  scope.goToDetails(aLibrary);
  
  expect($location.path).toHaveBeenCalledWith('/libraries/0/details');
});
```

First, we expect to have our list of libraries loaded on startup. We just need to check them. Second, we want to be able to create new items so we simulate that we saved a new library name on `newItemName` and also that we fired the `create` function. Doing that, we expect our new library to be the last item of our internal collection. Third, we want to redirect to a details page if we click on a library. We simulate the click (saving a library on a local object) and then we pass it to the `goToDetails` function. Doing that, we expect `$location.path` to be called with the right route.

Our controller is pretty lean so we don't have much to test. Talking about the controller, it would look like this:

```javascript
angular.module('app').
    controller('ListLibrariesCtrl', function($scope, $location, restService) {
  restService.getAll().then(function(items) {
    $scope.libraries = items;
  });
  
  $scope.create = function() {
    restService.create($scope.newItemName).then(function(item) {
      $scope.libraries.push(item);
    });
  };
  
  $scope.goToDetails = function(library) {
    $location.path('/libraries/' + library.id + '/details');
  };
});
```

It wasn't any hard, isn't it? :)

You can see this working [here](http://plnkr.co/edit/zhh8jnXmwpdAuBbvBWYk?p=preview).
