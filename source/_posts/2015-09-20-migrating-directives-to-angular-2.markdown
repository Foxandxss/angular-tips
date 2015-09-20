---
layout: post
title: "Migrating directives to Angular 2"
date: 2015-09-20 17:53
comments: true
categories: [angular2, directives]
---

`Angular 2` it is just around the corner and people are still afraid because `Angular 2` changes too much and it will hard to migrate. That is not true at all, in fact you will see how easy is `Angular 2`.

Let's migrate a directive from Angular 1 to Angular 2. I love accordions, everybody love accordions! Let's migrate `ui-bootstrap` accordion to `Angular 2`. I can't assume that you're familiar with it, so we are code both at the same time, explaining the differences along the way. I highly recommend you to, at least, replicate yourself the `Angular 2` one.

Use this [plunker](http://plnkr.co/edit/A9czCqlltHcd4jx8aUdY?p=catalogue) to code the `Angular 1` version.

Use this [plunker](http://plnkr.co/edit/yEEt0pXjAtMivUa0keYe?p=catalogue) to code the `Angular 2` version.
<!--more-->
## Designing our accordion

Our accordion will be composed of 2 directives. The first one will be an element called `<accordion>` which will host one or many `<accordion-group>`. Each `<accordion-group>` will contain a `heading` which is the clickable area that will allow us to toggle each group. The content that we put inside the `<accordion-group>`, will be its content. So without messing too much with the syntax now, the idea is to have something like:

```html
<accordion>
  <accordion-group heading="First one">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```

The `<accordion>` will contain an option to force other groups to close (to just leave one open) and each `<accordion-group>` can be toggle by code. Sounds like a plan.

## Coding the accordion directive in Angular 1

First we need to code the `<accordion>` directive that will wrap all our groups. Let's code the basic skeleton:

```javascript accordion.js
angular.module('app')

  .directive('accordion', function() {
    return {
      templateUrl: 'accordion.html'
    };
  });
```

The objective of the `<accordion>` directive is to be a "wrapper" of groups, so for now we just need a template to put those groups. What does `bootstrap` say about this template? It needs to be a `<div>` with the `panel-group` class. Something like:

```html
<div class="panel-group"></div>
```

The problem is that we need to grab all those `<accordion-group>` elements and move them inside our accordion's template. How do we do that? Transclusion. That means that we need to set a tranclusion point in that template:

```html accordion.html
<div class="panel-group" ng-transclude></div>
```

Good, since we are using transclusion, we need to activate it on the directive:

```javascript accordion.js
angular.module('app')

  .directive('accordion', function() {
    return {
      transclude: true,
      templateUrl: 'accordion.html'
    };
  });
```

Perfect! Let's use it:

```html index.html
<body ng-controller="MainCtrl">
  <accordion>

  </accordion>
</body>
```

If we execute it now, we just get an empty `<div>`.

## Coding the accordion directive in Angular 2

We are used to code directives for everything. In Angular a directive is something we add to our HTML, it doesn't matter if it is an element that generates some content (like an accordion or an alert box) or if it is an attribute to add / modify some behavior (like a validation directive, ng-model, etc).

In `Angular 2` we have several types of directives, the most common one is the `Component` directive which is type of directive that has a view. Here we don't have a `.directive` function like in `Angular 1`, instead we have simple classes that gets annotated to give them a certain behavior. Let's import the annotations we need for a `Component`:

```javascript accordion.ts
import {Component, View} from 'angular2/angular2';
```

For a `Component`, we need both the `Component` and `View` annotations. First, we will create our Component class:

```javascript accordion.ts
export class Accordion {}
```

Nothing fancy, we create (and export) a class named Accordion. As I said before, this is not a component yet, so we need to annotate it with:

```javascript accordion.ts
@Component({

})
export class Accordion {}
```

Now our `Accordion` class is a `Component`. We need to customize the annotation using properties. One of them is `selector` which will define *how* can we use the `Component` in our HTML. Some options are:

* **foo**: that will restrict for an element.
* **[foo]**: that will restrict for an attribute.
* **.class**: that will restrict for a class.
* **input[type=text]**: that will apply this directive only in a `<input type="text">`.

This serves the same purpose as the `restrict` option in `Angular 1`, but here we have more flexibility. We can not only restrict it by element or attributes like we used to, but also restrict it to certain types of elements or give a different name depending in where we use it. There are more options apart from those 4, but that is outside the scope of the article.

Ok, so we want to restrict it to elements and attributes and both with the same name:

```javascript accordion.ts
@Component({
  selector: 'accordion, [accordion]'
})
export class Accordion {}
```

To define the view of our component, we will use the `View` annotation:

```javascript accordion.ts
import {Component, View} from 'angular2/angular2';

@Component({
  selector: 'accordion, [accordion]'
})
@View({
  templateUrl: 'src/accordion.html'
})
export class Accordion {}
```

We can both have our template inline (with `template`) or in a external file (with `templateUrl`).

A component needs to have one `Component` annotation and one or *more* `View` annotations. Wait, one or more? Yes, you can have a `View` for desktop, a `View` for mobiles, etc.

All we need now is to code write our template to be able to transclude our stuff. Wait, transclude?

## "Transclusion" in Angular 2

First thing first, go to all your dictionaries and delete the "Transclusion" entry that you added long time ago. There is no more transclusion in Angular 2. As you might now, Angular 2 directives are `web components` and with web components we have a concept called `Shadow DOM`. I won't go into details (you can learn more about that [here](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom/)), but basically it allows us to create reusable components which encapsulates some content and behavior (Like our directives, right? :)). Thanks to the `Shadow DOM` we can "project" (transclude) the content we need from our `Component` element into its template with `<content>`. That means that when in the past we had to use `ng-transclude`, we use `<content>` now:

```html
<div class="panel-group">
  <content></content>
</div>
```

Now if we do something like:

```html
<accordion>Foo</accordion>
```

The `<content>` element in the template will be replaced with `Foo`. Since not all browsers supports `Shadow DOM` as today, `Angular 2` has a `<ng-content>` element that does the same work. Once the browsers gets proper `Shadow DOM` support, you can switch to `<content>` without any problem.

The good thing about `<content>`/`<ng-content>` is that in contrast to `ng-transclude`, you can have several of them in one template. For example:

```html
<ng-content select=".foo"></ng-content>
<ng-content select="[foo]"></ng-content>
```

There it will project all the elements with the `foo` class into the first `ng-content` and the elements with the `foo` directive. That gives much much flexibility versus `ng-transclude`. No more dummy directives to create extra transclusion points!

## Coding the accordion template

Now that we have more knowledge about `<ng-content>`, we can write our template:

```html accordion.html
<div class="panel-group">
  <ng-content></ng-content>
</div>
```

Thanks to this, our groups will be projected into that `<ng-content>`.

Something important in here is that we cannot add attributes like classes to the `<ng-content>` and that is because it will be replaced. No point to add stuff to something that will disappear, right? Because of that, we had to create a `div` wrapper because we really need that `panel-group` class.

The problem with this is that we are going to end with:

```html
<accordion class="ng-binding">
  <div class="panel-group">
    ...
  </div>
</accordion>
```

Would be nice if we could apply that class directly to the host element (the `accordion` one). The thing is, we can! The `Component` annotation allows us to modify that host element, so we can tell it to add a `panel-group` class to it like:

```javascript accordion.ts
@Component({
  selector: 'accordion',
  host: {
    'class': 'panel-group'
  }
})
```

Then we can remove the div wrapper from the template:

```html accordion.html
<ng-content></ng-content>
```

And now we get:

```html
<accordion class="ng-binding panel-group">
  ...
</accordion>
```

Fantastic!

To try it, we modify our application html to use the accordion:

```html app.html
<accordion>

</accordion>
```

It won't work yet because our application is not aware of the accordion directive yet. To fix that, we need first to import it:

```javascript app.ts
import {Accordion} from './accordion';
```

That alone won't do the job, because now in Angular 2, we need to specify which directives are we using in our component. We can do that thanks to the `directives` property of the `View` annotation:

```javascript app.ts
@View({
  templateUrl: 'src/app.html',
  directives: [Accordion]
})
```

It is more manual than Angular 1, but this gives us much more flexibility and we won't have more directives' name conflicts.

## Coding the accordion-group directive in Angular 1

Now we need the directive that we are going to transclude into that parent `accordion`. Let's create it:

```javascript accordion.js
.directive('accordionGroup', function() {
  return {
    transclude: true,
    templateUrl: 'accordion-group.html',
    scope: {
      heading: '@'
    },
    link: function(scope, element, attrs) {
      scope.toggleOpen = function() {
        scope.isOpen = !scope.isOpen;
      }
    }
  };
});
```

Our groups needs a `heading` string and also we need to transclude the group content into the template. Also, we need a function that will toggle our `isOpen` variable. For the template:
{% raw %}
```html accordion-group.html
<div class="panel panel-default">
  <div class="panel-heading" ng-click="toggleOpen()">
    <h4 class="panel-title">
      <a href tabindex="0" class="accordion-toggle"><span>{{heading}}</span></a>
    </h4>
  </div>
  <div class="panel-collapse" ng-show="isOpen">
	  <div class="panel-body" ng-transclude></div>
  </div>
</div>
```
{% endraw %}
The template is pretty simple. It follows bootstrap conventions for the accordion. The `ui-bootstrap` version uses the `collapse` directive to hide the content, but a simple `ng-show` works for us here.

If we try it now with:

```html index.html
<accordion>
  <accordion-group heading="First one">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```

Yikes, we have a fully operational accordion!

One thing before we move forward. Imagine that we don't write proper documentation and we see that `heading` attribute. What does it receive? A string? a scope property? I have no idea. Perhaps I want to send the content of `$scope.foo` so I try:

```html
<accordion-group heading="foo"></accordion-group>
```

Just to realize that this failed miserably. So I try:
{% raw %}
```html
<accordion-group heading="{{foo}}"></accordion-group>
```
{% endraw %}
And now I see it working. Not really clear.

## Coding the accordion-group directive in Angular 2

We won't have much problem migrating this to Angular 2. Let's see it:

```javascript accordion.ts
@Component({
  selector: 'accordion-group, [accordion-group]',
  properties: ['heading']
})
@View({
  templateUrl: 'src/accordion-group.html',
  directives: [NgClass]
})
export class AccordionGroup {
  toggleOpen(event) {
    event.preventDefault();
    this.isOpen = !this.isOpen;
  }
}
```

We have our `Component` annotation but this time it also has a `properties` property. There we can specify that we can use a *heading* attribute in our component and that will be mapped to a `heading` variable in our Component. We can see this `properties` a bit like our `scope` in the Angular 1 version. Only that this time we don't have those weird `=` / `@` and `&`. Simple.

In our `View` annotation, we specify the template to use, and since that template will use the `ng-class` directive, we need to add it to the array.

Back in the Angular 1 version, we had to create a `link` function to add the `toggleOpen` function. In Angular 2 we just need to create a method in our class.

Before we forget, we need to import the `NgClass` directive:

```javascript accordion.ts
import {Component, View, NgClass} from 'angular2/angular2';
```

The template is pretty much the same:
{% raw %}
```html accordion-group.html
<div class="panel panel-default" [ng-class]="{'panel-open': isOpen}">
  <div class="panel-heading" (click)="toggleOpen($event)">
    <h4 class="panel-title">
      <a href tabindex="0"><span>{{heading}}</span></a>
    </h4>
  </div>
  <div class="panel-collapse" [hidden]="!isOpen">
    <div class="panel-body">
	    <ng-content></ng-content>
    </div>
  </div>
</div>
```
{% endraw %}
Here we have that `ng-class` that we declared on our `View` (more on the syntax in a bit), a `click` event for the toggle, a `hidden` property (which substitutes the `ng-show` we had) and again, an `<ng-content>` to project our group's content.

We can now use it in our app. First, we need to import the new component:

```javascript app.ts
import {Accordion, AccordionGroup} from './accordion';
```

And tell our `View` annotation that we are going to use it:

```javascript app.ts
@View({
  templateUrl: 'src/app.html',
  directives: [Accordion, AccordionGroup]
})
```

Finally, we just need to use it:

```html app.html
<accordion>
  <accordion-group heading="First one">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```

If we run it, we get the exact same behavior.

But now, we don't need to ask ourselves what does that `heading` receive. If we use it like in the previous snippet, it will receive a string for sure. If we want to pass some variable from our application, we can simply do:

```html
<accordion-group [heading]="foo"></accordion-group>
```

We get both behavior now without any extra code. That means, no more asking ourselves how to use the directive anymore! To learn more about the `[]` syntax used here and before with `ng-class` and `hidden`, please read the "Properties" section in my [previous article](/blog/2015/06/why-will-angular-2-rock/).

## Opening groups dynamically in Angular 1

We want an `is-open` attribute for the groups so we can open or close them via code. First, we need to ask ourselves: What is the most common way of using an attribute like that? Uhm, we would like to be able to pass a boolean to it and also a variable from the scope. That means that we need to use `=` because `@` would make our `ng-show` to be open with *any* string we pass to it.

With those insights, we just need to add a new property to the `scope`:

```javascript accordion.js
scope: {
  heading: '@',
  isOpen: '='
}
```

Just that. We can now do:

```html index.html
<accordion>
  <accordion-group heading="First one" is-open="isOpen">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```

Now if we set a `isScope` variable in our controller:

```javascript app.js
.controller('MainCtrl', function($scope) {
  $scope.isOpen = true;
});
```

That will make our first group to open at startup.

The issue with this again is the syntax is that we need to decide beforehand how do we want that attribute to be used so we can code it. The problem is that end users could have different ideas and use it wrong. Not their fault tho.

## Opening groups dynamically in Angular 2

In Angular 2, we don't need to make any question. You want a `isOpen` attribute? Put it on the `Component`:

```javascript accordion.ts
@Component({
  selector: 'accordion-group, [accordion-group]',
  properties: ['heading', 'isOpen']
})
```

Now we can do:

```html app.html
<accordion>
  <accordion-group heading="First one" is-open="true">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```

You say you would like to send a property from your component? Sure:

```html
<accordion-group heading="First one" [is-open]="isOpen"></accordion-group>
```

Now it will look for a `isOpen` attribute on the `MyApp` component:

```javascript app.ts
export class MyApp {
  isOpen:string = true;
}
```

Much easier, isn't it?

## Closing other groups in Angular 1

The most common behavior on an accordion is to close the other groups when we open one. Ok, how can we code that? A group doesn't see another group, but the accordion itself has all children within. Can we use that? Sure.

This is a two parts idea. First we need to be able to somehow register all our groups within the accordion. In Angular, we can `require` a parent directive. By doing that, we are actually getting access to that directive's controller. Alright, let's create a controller for the accordion that is able to register groups:

```javascript accordion.js
.directive('accordion', function() {
  return {
    ...
    controller: function() {
      var groups = [];

      this.addGroup = function(groupScope) {
        groups.push(groupScope);
      }
    }
  }
}
```

Ideally this controller would be "external" but this works for the demo. We just need a groups array and a method to add groups. We just need a reference to their scope to make this work.

Now the groups needs to call this method on startup:

```javascript accordion.js
.directive('accordionGroup', function() {
  return {
    ...
    require: '^accordion',
    link: function(scope, element, attrs, ctrl) {
      ctrl.addGroup(scope);

      scope.toggleOpen = function() {
        scope.isOpen = !scope.isOpen;
      }
    }
  };
});
```


Noticed that we had to `require` our `accordion` directive in order to be able to access its controller. Now, we need a method on that controller that will close all groups except the one being opened:

```javascript accordion.js
controller: function() {
  ...

  this.closeOthers = function(openGroup) {
    angular.forEach(groups, function(group) {
      if (group !== openGroup) {
        group.isOpen = false;
      }
    });
  }
}
```

Simple loop that will set the `isOpen` attribute on the groups to false. Now, we simply need to call that method when we click on a header or when isOpen changes by other means. That is fixed with a `$watch` in the group's link function:

```javascript accordion.js
scope.$watch('isOpen', function(value) {
  if (value) {
    ctrl.closeOthers(scope);
  }
});
```

Now that function will be called when `isOpen` changes and it will close the other groups successfully.

## Closing other groups in Angular 2

In Angular this is done a bit simpler. We need to be able to register groups as well, but in this case we don't have controllers, so the code goes inside the `Accordion` class:

```javascript accordion.ts
export class Accordion {
  private groups:Array<AccordionGroup> = [];

  addGroup(group:AccordionGroup) {
    this.groups.push(group);
  }
}
```

First we create our groups array and thanks to TypeScript typing, we get real intellisense on our editors (not plunker tho). Nothing fancy in here.

Then we need to register our groups in it. How? We used to `require` the accordion to give us access to its controller. Now what? You can inject the parent accordion now:

```javascript accordion.ts
export class AccordionGroup {

  constructor(private accordion:Accordion): void {
    this.accordion.addGroup(this);
  }

  ...
}
```

By injecting it, we get access to it so we just need to call its `addGroup` method.

For the close others, another method on the `Accordion` class:

```javascript accordion.ts
export class Accordion {
  ...

  closeOthers(openGroup:AccordionGroup): void {
    this.groups.forEach((group:AccordionGroup) => {
      if (group !== openGroup) {
        group.isOpen = false;
      }
    });
  }
}
```

This time we don't have `$watch` anymore, so what we need to do is to rely on standard getters and setters (yay!):

```javascript accordion.ts
export class AccordionGroup {
  private _isOpen:boolean = false;

  ...

  public get isOpen(): boolean {
    return this._isOpen;
  }

  public set isOpen(value:boolean): void {
    this._isOpen = value;
    if (value) {
      this.accordion.closeOthers(this);
    }
  }
}
```

Here, we initialize a private `isOpen` variable to false, and every time we set `isOpen` (in any way), the setter will be called and it will call `closeOthers`.

Works like a charm. The good part in here is that we don't have anymore those `link` vs `controller` wars. When to use `link`, when to use `controller`. We just have our class and nothing else.

# Removing groups in Angular 1

Our last feature (or I will need to turn this monster into a book). Being able to remove groups. Why do we need that? Imagine we have an array of groups and a function to delete groups:

```javascript app.js
$scope.groups = [
  {
    heading: 'Dynamic 1',
    content: 'This is dynamic'
  },
  {
    heading: 'Dynamic 2',
    content: 'This is also dynamic'
  }
];

$scope.closeDynamic = function() {
  $scope.groups.pop();
};
```

Now we decide we want to create dynamic groups like:
{% raw %}
```html index.html
<accordion>
  <accordion-group heading="First one" is-open="isOpen">
    Lot of content in here.
  </accordion-group>
  <accordion-group heading="{{group.heading}}" ng-repeat="group in groups">
    {{group.content}}
  </accordion-group>
  <accordion-group heading="Another group">
    More interesting stuff.
  </accordion-group>
</accordion>
```
{% endraw %}
If we start calling that `closeDynamic` function, we will see the group disappearing as expected, but our accordion will still have a reference to a dead scope. That could cause some leaks.

To fix that, we just need to listen to the `$destroy` event that every scope fires when it gets killed and with that, we just remove that group from the list:

```javascript accordion.js
controller: function() {
  ...

  this.addGroup = function(groupScope) {
    groups.push(groupScope);

    groupScope.$on('$destroy', function() {
      removeGroup(groupScope);
    })
  }

  var removeGroup = function(group) {
    var index = groups.indexOf(group);
    if (index !== -1) {
      groups.splice(index, 1);
    }
  }
}
```

That is easily done. We listen to it, we remove it.

# Removing groups in Angular 2

In Angular 2, we need to take a different approach. Angular 2 directives have lifecycle hooks, so we can do stuff `OnInit`, `OnDestroy`, etc.

First, let's code the `removeGroup` method on the `Accordion` class:

```javascript accordion.ts
export class Accordion {
  ...

  removeGroup(group:AccordionGroup): void {
    const index = this.groups.indexOf(group);
    if (index !== -1) {
      this.groups.splice(index, 1);
    }
  }
}
```

Now we need to call that `OnDestroy`. To do that, we simply need to implement create a `onDestroy` method:

```javascript accordion.ts
onDestroy(): void {
  this.accordion.removeGroup(this);
}
```

To see this in action, let's modify our `MyApp` component to have a list of dynamic groups:

```javascript app.ts
import {Component, View, bootstrap, NgFor} from 'angular2/angular2';

import {Accordion, AccordionGroup} from './accordion';

@Component({
  selector: 'my-app'
})
@View({
  templateUrl: 'src/app.html'
  directives: [Accordion, AccordionGroup, NgFor]
})
export class MyApp {
  isOpen:boolean = false;

  groups:Array<any> = [
    {
      heading: 'Dynamic 1',
      content: 'I am dynamic!'
    },
    {
      heading: 'Dynamic 2',
      content: 'Dynamic as well'
    }
  ];

  removeDynamic() {
    this.groups.pop();
  }
}

bootstrap(MyApp);
```

And its html:
{% raw %}
```html app.html
<p>
  <button type="button" class="btn btn-default" (click)="removeDynamic()">
    Remove last dynamic
  </button>
</p>

<accordion close-others="true">
  <accordion-group heading="This is the header" is-open="true">
    This is the content
  </accordion-group>
  <accordion-group [heading]="group.heading" *ng-for="#group of groups">
    {{group.content}}
  </accordion-group>
  <accordion-group heading="Another group" [is-open]="isOpen">
    More content
  </accordion-group>
</accordion>
```
{% endraw %}
Notice that nice `ng-for` in there to generate multiple groups. The syntax is a bit different from what we used in here, but that is a topic for another article ;)

## Conclusions

We have seen that migrating an Angular directive to Angular 2 is not that problematic. We just need to learn a couple of new things, but at the end, we can see how Angular 2 simplifies lot of stuff:

* No more `Controllers` or `Link` functions.
* Even when the new html syntax is weird at first, makes our directive really straightforward to use.
* No more `=`, `@` and `&`.
* Using a parent directive is as easy as injecting it.
* Lot of lifecycle hooks to customize easily our directives.
* Much more variety of selectors types.
* Saying goodbye to... isolated scope or not?
* "Transclusion" makes much much sense now.

And we only covered the tip of the iceberg. There are lots and lots of new cool things, like dynamic loading a directive.

On the other hand, TypeScript, even when it adds a bit of verbosity to our code, it really shines when we use it with a nice editor.

Check the end result of the [ng1 version](http://plnkr.co/edit/tYPUDDJwFMsjWjyDznwt).

Check the end result of the [ng2 version](http://plnkr.co/edit/PvKuiBon0PpM6sNSehc6).

I have also a much more complete version of the ng2 one, but the article was getting too long to cover them all. Still, be sure to check [it](http://plnkr.co/edit/XuH7mXBycODO7KYgNSbH) time to time while I update it with new features.
