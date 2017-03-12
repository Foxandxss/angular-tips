+++
title = "Introduction to unit test: directives"
date = "2014-06-08T13:30:28+01:00"
categories = []
tags = ["unit test"]
description = ""

+++

Time for the last piece of unit testing, directives.

Directives sounds like a hard piece to test but actually is not bad at all. Of course a big and complex directive is more harder to test but if we stick to TDD, we won't have any problem.
<!--more-->
Before we start, I have a suggestion: Use jQuery for the directive tests, this could sound weird here in Angular, but I assure you that it will save you infinite pain at minimum cost.

> jQuery on tests could led on false positives. It's not common at all, but there is the possibility. On `ui-bootstrap` we didn't find any false positive yet.

Alright, what are we going to build here? I am going crazy for this one and we are going to create a directive that will generate `svg` circles.

Generate svg circles? Yeah, we give it a size, and two colors, one to fill it and one for its stroke. With that parameters we do some computation on the size and well, we put a circle on the screen. We can also observe the changes of its size to update it realtime.

Shall we begin? Let's do the test's skeleton:

```javascript
describe('directive: svg-circle', function() {
  var element, scope;
  
  beforeEach(module('app'));
  
  beforeEach(inject(function($rootScope, $compile) {
    scope = $rootScope.$new();
    
    element =
        '<svg-circle size="{{size}}" stroke="black" fill="blue"></svg-circle>';
    
    scope.size = 100;
    
    element = $compile(element)(scope);
    scope.$digest();
  }));
});
```

To test a directive we need to create and compile it, one way is creating an string that contains our directive. Here you can see how we created a `svg-circle` element (which will be our directive) and that we also defined our three attributes. This is one of the good things about TDD, we don't have our directive created yet but we already know how we want to use it, isn't that cool?

We see that all three attributes receives a simple string that could be interpolated from a scope variable like the `size` one. If we want, we could put the other attributes to use interpolation too, but a static value for them is good enough for the test.

Since our `size` attribute is interpolated, we create a `size` property on our scope with the value of 100.

Then we need to `$compile` our directive and link it to the scope provided. That will return the compiled directive, that means that `element` will contain the compiled directive now instead of the previous string.

Last, but not least, we fire a `$digest` which is completely needed for directive testing.

Just that, all we need now is to make proper tests.

Let's test how the directive should respond with the first values given:

```javascript
describe('with the first given value', function() {
  it("should compute the size to create other values", function() {
    var isolated = element.isolateScope();
    expect(isolated.values.canvas).toBe(250);
    expect(isolated.values.center).toBe(125);
    expect(isolated.values.radius).toBe(100);
  });
  
  it("should contain a svg tag with proper size", function() {
    expect(element.attr('height')).toBe('250');
    expect(element.attr('width')).toBe('250');
  });
  
  it("should contain a circle with proper attributes", function() {
    expect(element.find('circle').attr('cx')).toBe('125');
    expect(element.find('circle').attr('cy')).toBe('125');
    expect(element.find('circle').attr('r')).toBe('100');
    expect(element.find('circle').attr('stroke')).toBe('black');
    expect(element.find('circle').attr('fill')).toBe('blue');
  });
});
```

Before analyzing this tests, let me explain the different values we need to create a circle:

* **radius**: The radius size is the size we put onto the directive.
* **canvasSize**: The canvas size is the size of the canvas were we put our circle. It is always 2.5 times bigger than the radius.
* **center**: The center of the circle is always on the middle of the canvas, that means that it is equal to the half of the canvas size.

Now that we know how to the computations are done, let's continue with the tests themselves:

On the first one, we want to be sure that the computations are done correctly. For that we grab the isolated scope of the directive and we just need to expect that the different computations are done correctly. Since we put 100 as the size, the radius should be also **100**, the canvas should be 100 * 2.5 == **250** and the center 250 / 2 == **100**.

For the second test, we want to assert that there is a `svg` element on the DOM which contains two attributes, `height` and `width` with the correct values (canvas size).

Lastly, that `svg` element should contain a `circle` element with a bunch of attributes and all of them have the correct values (values we got on our computations and also the colors we passed as attributes).

Now we want to test that if we change the size on the controller's scope, we also change the circle's size:

```javascript
describe('when changing the initial value to a different one', function() {
    
    beforeEach(function() {
      scope.size = 160;
      scope.$digest();
    });
    
    it("should compute the size to create other values", function() {
      var isolated = element.isolateScope();
      expect(isolated.values.canvas).toBe(400);
      expect(isolated.values.center).toBe(200);
      expect(isolated.values.radius).toBe(160);
    });
    
    it("should contain a svg tag with proper size", function() {
      expect(element.attr('height')).toBe('400');
      expect(element.attr('width')).toBe('400');
    });
    
    it("should contain a circle with proper attributes", function() {
      expect(element.find('circle').attr('cx')).toBe('200');
      expect(element.find('circle').attr('cy')).toBe('200');
      expect(element.find('circle').attr('r')).toBe('160');
      expect(element.find('circle').attr('stroke')).toBe('black');
      expect(element.find('circle').attr('fill')).toBe('blue');
    });
  });
```

On the `beforeEach` block we just need to change the size (and also to $digest so this change will be processed). The rest of the tests are the same as before but this time we check that the computations are done with the new value.

Testing directives is not much more than this. We create our directive element, we compile it and we test it. To test it, some times we need to check its scope status and also the resulting DOM to check that everything is in place as we expect.

The directive can be written like this:

```javascript
angular.module('app').directive('svgCircle', function() {
  return {
    restrict: 'E',
    scope: {
      size: "@",
      stroke: "@",
      fill: "@"
    },
    replace: true,
    template: '<svg ng-attr-height="{{values.canvas}}" ng-attr-width="{{values.canvas}}" class="gray">' +
                  '<circle ng-attr-cx="{{values.center}}" ng-attr-cy="{{values.center}}"' +
                          'ng-attr-r="{{values.radius}}" stroke="{{stroke}}"' +
                          'stroke-width="3" fill="{{fill}}" />' +
                '</svg>',
    link: function(scope, element, attr) {
      var calculateValues = function(size) {
        var canvasSize = size * 2.5;
      
        scope.values = {
          canvas: canvasSize,
          radius: size,
          center: canvasSize / 2
        };
      };
      
      var size = parseInt(attr.size, 0);
      
      attr.$observe('size', function(newSize) {
        calculateValues(parseInt(newSize, 0));
      });
    }
  };
});
```

Running example [here](http://plnkr.co/edit/tirhLwFEXLKSzukbsW1q?p=preview)

Directives are the hardest part of angular so testing it could be also a little bit cumbersome but with TDD we can make the curve a little bit less steep.
