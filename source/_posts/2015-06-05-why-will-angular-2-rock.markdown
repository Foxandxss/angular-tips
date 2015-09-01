---
layout: post
title: "Why will Angular 2 rock?"
date: 2015-06-05 13:12
comments: true
categories: [angular2]
---

**This article has been update in September 1st. Now it is using TypeScript and angular 2.0.0-alpha.36**

**Note**: If the "foo" alerts from the plunkers starts popping out without reason, please leave a comment and I will look for a different solution.

**DISCLAIMER:** Angular 2 is still in Alpha stage so the syntax I present in here is subject to be changed and|or simplified. I am using Angular 2.0.0-alpha.36. Also, what I write in here is just my opinion and I could be *wrong*.

Angular 2 is around the corner and there are mixed opinions about it. Some people can't wait for it and other people are not any happy with it. Why is that? People are afraid to change, thinking that they wasted their time learning something that is now going to change in a radical way.

Angular is a great framework, but it is 6 years old, and that for a framework is too much. The web evolved a lot since Angular inception in 2009 and the Angular team can't simply implement those new stuff without breaking half of the actual implementation.

So if they have to break Angular to be able to make it "modern", it is better to write it from scratch. How so? Angular itself has other problems like the complex syntax for directives, 5 types of services that confuses new users, writing stuff in the wrong scope...

They decided to kill 2 birds with one stone. A new simplified Angular with all the new stuff like shadow dom and also none of the Angular 1 problems.

So my friend, don't worry, Angular 2 will rock.
<!--more-->
## Module loader

In Angular until recently, we always had a problem with module loaders. What should I use? Maybe the classic way of endless script tags? `Require.js`? `Browserify / webpack?`... Angular 2 uses the standard `System.js` which is a universal module loader that loads ES6 modules, AMD, Common JS...

Now with this module loader, we just need to import the file where we bootstrap our app, and we are good to go:

```html
System.import('main');
```

Now inside our `main` file, we just need to:

```javascript
import {bootstrap} from 'angular2/angular2';
import {App} from 'app';

bootstrap(App);
```

Thanks to our module loader, we now see where this `bootstrap` and `App` comes from and also, we don't need to create a `<script>` tag for every javascript file in our application. Ah, this also means, no more `ng-app`.

There are more advantages that we will see soon.

## Components

In Angular 2, we don't have controllers nor scope anymore. So... what do we use to create a page like `login` or `home` ? We use a `Component`. What's a `component`? In Angular 2 we have two types of directives. The ones that adds behavior to a DOM element and the ones that has an embedded view (template). The first one are called `directives` and the second one are called `components`.

Ok, so a `component` is a directive that has a template and that is what we use to represent a *page* in Angular 2. A `component` is simply a class:

```javascript
class MyComponent {

}
```

What makes this class a `component`? In Angular 2 we have annotations. Annotations are a way to add metadata to a class. So there is an annotation called `Component` which we can use to say that a particular class is a `Component`:

```javascript
@Component({
  selector: 'my-component'
})
class MyComponent {

}
```

So here we are saying: Hey MyComponent, you're now a component which is going to respond to the "my-component" selector. Meaning that we can now do:

```html
<div id="content">
  <my-component></my-component>
</div>
```

Yay, now our component is usable in our html using the `selector` name we gave to it. And please notice that we didn't use `myComponent` as the selector. That is useful.

Ok, but a `Component` needs a template. There is another annotation called `View` which is used for the template:

```javascript
@Component({
  selector: 'my-component'
})
@View({
  template: `<div>Hello, World</div>`
})
class MyComponent {

}
```

So now `MyComponent` is a component that responds to `my-component` selector and outputs a template with a `Hello, World`.

We can have more than 1 `View` annotation in a component. We could define a template for desktop, one for tablets, one for mobile, one for tv...

We can also use data binding:
{% raw %}
```javascript
@Component({
  selector: 'my-component'
})
@View({
  template: `<div>Hello, {{message}}</div>`
})
class MyComponent {
  message: string;

  constructor() {
    this.message = 'World';
  }
}
```
{% endraw %}
We used the class constructor to set a message. No more scopes.

<iframe src="http://embed.plnkr.co/wKeLHZshhPprbQxJ2Km6/preview" style="width:100%; height:320px" frameborder="0"></iframe>

And that is how we create our pages. When we use the new router, we just need to pass a component to it instead of the old template+controller.

## Directives

So how do we create a directive in Angular 2?

```javascript
@Directive({

})
class Tooltip {

}
```

As we did with `Component`, we use an annotation to define our directive.

In Angular 1 we had the DDO (directive definition objects) which we used to develop our directive. The problem with the `DDO` is that it is a bit confusing with stuff like:

* **transclusion**: What does that word even mean?
* **controller vs link**: When to use link and when to use a controller?
* **compile**: What should I do in there?
* **scope**: scope: false, scope: true, scope: {}. Which one to use and why?

Directives in Angular 2 are much simpler and straightforward. Let's create a simple `tooltip` (it will just log into the console instead of showing a popup).

First, what do we need to actually use a directive? a selector. In Angular 1 we had the `restrict` property, in Angular 2 is way more flexible. We can use:

* **foo**: that will restrict for an element.
* **[foo]**: that will restrict for an attribute.
* **.class**: that will restrict for a class.
* **input[type=text]**: that will apply this directive only in `<input type="text">`

There are more ways to define a selector than those 4.

Alright, we just need it to be an attribute, so:

```javascript
@Directive({
  selector: '[tooltip]'
})
class Tooltip {

}
```

A tooltip needs a text do display, right? Makes sense to just use the `tooltip` attribute to pass the text, something like:

```html
<div tooltip="foo">...</div>
```

In Angular 1 we could use an isolated scope or maybe grab the `tooltip` attribute in the `link` function and assign it to the scope.

In Angular 2, we have a `properties` array where we define those:

```javascript
@Directive({
  selector: '[tooltip]',
  properties: [
    'text: tooltip'
  ]
})
class Tooltip {

}
```

Here, we are saying that we want the `tooltip` attribute to be mapped to `this.text`. A cool thing we can do here is something like:

```javascript
properties: [
  'text: tooltip | capitalize'
]
```

We can use pipes (our classic filters) in here as well.

Lastly, it needs to trigger on `mouseover`. Alright, so a `.on` call on the element like we used to do? No. We just need to set a listener for the directive:

```javascript
@Directive({
  selector: '[tooltip]',
  properties: [
    'text: tooltip'
  ],
  host: {
    '(mouseover)': 'show()'
  }
})
class Tooltip {
  text: string;

  show() {
    console.log(this.text);
  }
}
```

I think it is pretty clear, isn't it? On mouse over, we call the `show` function. And that is it. That is our first directive. We will explain why the parens around `mouseover` in a bit.

They require you to define some properties, but they are much easier to understand than the counterpart in Angular 1:

```javascript
angular.module('app')
  .directive('tooltip', function() {
    restrict: 'A',
    scope: {
      text: '@tooltip'
    },
    link: function(scope, element, attrs) {
      element.on('mouseover', function() {
        console.log(scope.text);
      });
    }
  });
```

Alright, you know this syntax pretty well, but explain to a novice what `link` is, why we have a `scope` property, what is that weird `@`...

Back to Angular 2, we can use this directive in our preview example like:
{% raw %}
```html
<div tooltip="foo">Hello, {{message}}</div>
```
{% endraw %}
Try it. Does it work? No.

There is one of the biggest features in Angular 2 for me. No directive will run in our template if we don't specify it explicity. How?
{% raw %}
```javascript
import {Tooltip} from './tooltip';

@Component({
  selector: 'my-component'
})
@View({
  template: `<div tooltip="foo">Hello, {{message}}</div>`,
  directives: [Tooltip]
})
class MyComponent {
  message: string;

  constructor() {
    this.message = 'World';
  }
}
```
{% endraw %}
The `View` annotation has an array called `directives` where we list all the directives we want to use in our template. Here we imported the class `Tooltip` and we listed it on `directives`.

<iframe src="http://embed.plnkr.co/4XhUCGMIV2dUUJjRv3km/preview" style="width:100%; height:320px" frameborder="0"></iframe>

Wait a second... does that mean that if I use 10 directives on my template, I need to list all of them? Yes. How is that cool? We won't have more collisions. Let me put an example: In Angular 1 we have two implementations of `Twitter Bootstrap`, `ui-bootstrap` and `AngularStrap`. They both have their issues. Imagine you use `ui-bootstrap` on a daily basis but then find that the `tooltip` is not enough for our purposes and then we discover that `AngularStrap` has a better `tooltip`. You pull that library in and you use its tooltip.

Wait a second... They both have a directive called `tooltip`. Which one is going to be used in our template? Both and there is no way in hell you can avoid that.

Now in Angular 2, imagining that we have a port of both libraries, we could do something like:

```javascript
import {Accordion} from 'ui-bootstrap';
import {Tooltip} from 'angularStrap';

@Component({
  ...
})
@View({
  template: `...`
  directives: [Tooltip, Accordion]
})
class MyComponent {

}
```

Isn't it much better? No collision at all.

`AngularStrap` fixed this issue long ago prefixing their directives with `bs-`, but in Angular 2 even when that is still recommended to prefix your directives, the end users won't have to deal with your bad decisions.

If you're not convinced enough at this point, you can import `CORE_DIRECTIVES` from `angular2/angular2` and use that to import all core directives in your component.

## $apply() what's that?

Dollar apply, well, I would like to apply for some dollars. Jokes aside. How many times did you forgot to use `$apply()`? Checking our code for hours to then realize that we forgot to use `$apply()` and our bindings weren't updating.

Not anymore. Imagine this component:

{% raw %}
```javascript
@Component({
  selector: 'my-component'
})
@View({
  template: `<div>Hello, {{message}}</div>`
})
class MyComponent {
  message: string;

  constructor() {
    this.message = 'World';
    setTimeout(() => this.message = 'Angular-tips', 2000);
  }
}
```
{% endraw %}

Here we are using the built-in `setTimeout` to change our message. Does it Work?

<iframe src="http://embed.plnkr.co/AI2HiH11KS3q4Pwlhc2A/preview" style="width:100%; height:320px" frameborder="0"></iframe>

Of course it does. No more fear when mixing Angular with "non angular" stuff.

We get this feature thanks to Zone.js (Thanks to my good friend [Wesley Cho](https://github.com/wesleycho) for pointing that out).

## Properties

This is complex subject and I hope I can explain it properly.

When we write our html, for example:

```html
<input type="text" value="foo">
```

The browser will parse the input element and create a node object. Then it will start parsing each `attribute` to create a `property` inside that object. So we will end with a node object for the input with the type and value as properties (among others).

If we write on that input again, the `value property` will be updated but the original `value attribute` will not. That attribute was used just to initialize the node object.

If you used the `<img>` tag in the past, you found this issue:
{% raw %}
```html
<img src="{{foo}}">
```
{% endraw %}
The browser parse it, and will try to fetch the image called {% raw %}`{{foo}}`{% endraw %} and then when the angular runs, it will interpolate that {% raw %}`{{foo}}`{% endraw %} so the browser will be able to fetch the image this time. To fix that, the angular team created `ng-src`. The browser doesn't know what it is, so it is angular the one who will create the `src` property with the correct value.

We have this same issue with other directives like `ng-class`, `ng-show`, `ng-hide`, `ng-bind`, etc. Again, we have a bunch of directives that will prevent the browser from creating "broken" properties by creating the properties themselves with the correct values.

In Angular 2, we will write to those properties directly, that way, we won't need to create all those directives. How can we do that? For example:

```html
<img [src]="myImage">
<div [hidden]="isHidden">This div will be hidden if isHidden is true</div>
```

Using the `[]` we can write to those properties directly. We want define the `src` based on `this.myImage` ? we write that value directly to the property (which is exactly what `ngSrc` does). We need to hide a div conditionally? There is a `hidden` property in HTML 5 we can use for that. All of those, without any extra directive.

An attribute only accept strings, but a property accepts complex models. This mean that in the past:
{% raw %}
```html
<my-directive foo="{{something}}"></my-directive>
```
{% endraw %}
We used to do this to pass the content of `something` on the scope to the foo attribute. Now that we can write directly to properties, we can do:

```html
<my-directive [foo]="something"></my-directive>
```

No more interpolation because we are now writing to the property directly. Remember our `tooltip` directive?:

```javascript
@Directive({
  selector: '[tooltip]',
  properties: [
    'text: tooltip'
  ],
  host: {
    '(mouseover)': 'show()'
  }
})
class Tooltip {
  text: string;

  show() {
    console.log(this.text);
  }
}
```

It has a list of properties! That means that we can pass a dynamic text to it like:

```html
<div [tooltip]="foo">...</div>
```

That won't pass `foo` as the text, it will pass the content of `this.foo` as the text. And the best part, we didn't need to modify our directive.

<iframe src="http://embed.plnkr.co/DhG913Aenx7Y8SNCKUq3/preview" style="width:100%; height:320px" frameborder="0"></iframe>

Now, we won't be confused anymore of when to use interpolation or not.

## Events

With events we have another problem. Check this code:

```html
<my-directive select="user.name(name)"></my-directive>
```

What is that doing? Is it calling `user.name()` from the `scope` to assign a value to the `select` property based on a `name` parameter? Or is it a callback function that will be executed from inside our directive? We don't know and there is no way we can know that without checking `myDirective` source.

Angular 2 introduces a new syntax for this events, also called statements:

```html
<my-directive (select)="user.name(name)"></my-directive>
```

Thanks to that, we know that it is an event and not a property. If it were a property, we would have:

```html
<my-directive [select]="user.name(name)"></my-directive>
```

Also, thanks to this, we can get rid of unneeded directives like `ng-click`, `ng-blur`, `ng-change` etc. We can have something like:

```html
<my-directive (click)="doSomething()"></my-directive>
```

That will use the `click` event of the DOM, no more wrappers around that. As an extra, if that `doSomething` doesn't exist, angular will throw an error.

<iframe src="http://embed.plnkr.co/MCW90ltXoccRvWtWbQDT/preview" style="width:100%; height:320px" frameborder="0"></iframe>

For this one you will need to check the console to see that the second `<p>` will trigger an error.

Also, you will now understand this code from the tooltip:

```javascript
host: {
  '(mouseover)': 'show()'
}
```

It is an event after all ;)

## References

Imagine we want to focus an input by clicking somewhere, something like:

```html
<p (click)="...?">
  Focus the input
</p>
<input type="text">
```

How can we reference this input? In Angular 1 we could create a directive for the input that would $watch for changes in a variable to focus the input. Sounds complicated. In Angular 2 we can create a reference to a particular node which will be local to the template. For example:

```html
<input type="text" #user>
```

With `#user`, we are simply creating a reference to the input, so now we can do stuff like {% raw %}`{{user.value}}`{% endraw %} to see its value or even {% raw %}`{{user.type}}`{% endraw %} to see the type of the input. In short, we now have a reference to the node object in the template. Thanks to that we can simply do:
{% raw %}
```html
<p (click)="user.focus()">
  Grab focus
</p>
<input type="text" #user [(ng-model)]="name">
{{name}}
```
{% endraw %}
Now upon click, we call the `focus()` method on the node so it will grab the focus.

Isn't this wonderful? We are avoiding the need of creating extra directives for something as simple as this.

<iframe src="http://embed.plnkr.co/bkJNJy0Ts4qnC590wNu3/preview" style="width:100%; height:320px" frameborder="0"></iframe>

Wait a second, that example is nice, that for sure, but what is that `[(ng-model)]` syntax? Let see it step by step:

```html
<input type="text" [ng-model]="name" (ng-model)="name=$event"></input>
```

Here we are using the new `ng-model`. If we remember from an early point, with `[foo]` we set some property in our directive, and with (foo) we can fire some event (for example, send a value to the parent). With this example, we are setting `name` to be the value of the `ng-model` using `[ng-model]="name"`. Then we are creating an event to update the name in the parent with `(ng-model)="name=$event"`. That is good but verbose. Angular 2 let us mix them both like `[(ng-model)]="name"` so we are actually doing **two-way databinding!**

## Services

Let's create a service to fetch users at Github. What should we use? A Provider? Service? Factory? Value? Constant? I am just kidding. No more service vs factory or value vs constant (to this day, I don't understand why it is called a constant if it is not constant).

A service in Angular 2 is simply a...

```javascript
class GithubNames {

}
```

Class! You guessed it correctly. But this time, no annotations :)

Angular 2 has a service for http, but for the sake of showing how to use a third party library, we will use the new library taht comes with ES6 called `fetch`.

```javascript
class GithubNames {
  getUsers() {
    return fetch('https://api.github.com/users').then(function(response) {
      return response.json();
    });
  }
}
```

We simply use `fetch` to grab those users and send the `json` response back. That is really simple.

How can we use it? If the service is in a different file, for example one called 'github', we have to import it:

```javascript
import {GithubNames} from './github';
```

Then, we tell our component that we want to inject that:

```javascript
@Component({
  selector: 'my-component',
  viewBindings: [GithubNames]
})
```

Then in our constructor we simply inject it:

```javascript
constructor(github: GithubNames) {
  this.github = github;
}
```

The syntax used in here, is just a syntactic sugar for the injector and it uses TypeScript typing to achieve that. It is something like: "Hey, we are injecting the class `GithubNames`, create a instance for me and call it `github`".

Alright, now we have `GithubNames` injected and saved in our class.

We just need to use it. For example, let's create a function that will populate the `users`:

```javascript
fetch() {
  this.github.getUsers().then((users) => {
    this.users = users;
  });
}
```

That will call our service and assign the `users` to `this.users`. Again, no more `$apply` even when `fetch` is not part of angular.

Let's iterate through those users:
{% raw %}
```html
<button (click)="fetch()">Fetch users</button>
<ul>
  <li *ng-for="#user of users">
    {{user.login}} <img [src]="user.avatar_url" height="50px">
  </li>
</ul>
```
{% endraw %}

Uh, that is our new `ng-repeat` and that `#user` sounds like the reference we created before. Thanks to that, we can reference `user` inside the `<li>`.

The `*` for `ng-for` is another syntactic sugar. No need to dig in that for this article.

And please, don't forget to import `NgFor` (or directly CORE_DIRECTIVES) into our file and fill the `directives` array with it, because without it, it won't work ;)

<iframe src="http://embed.plnkr.co/4MbMaKO57mNytDjJ5neV/preview" style="width:100%; height:320px" frameborder="0"></iframe>

## Overpowered outlets

In Angular 1 we have `ngView` and `uiView` to mount our views and they are cool, but now with Angular 2, we can get the new router `router-outlet` and extend it, yes, literally:

```javascript
class MyOutlet extends RouterOutlet {

}
```

No more weird $decorators.

Ok, but what's the point, what can we do in here? We can create a new outlet that will prevent unregistered users to access certain parts of our applications:

```javascript
// We specify that this outlet will be called when the `loggedin-router-outlet` tag is used.
@Directive({selector: 'loggedin-router-outlet'})
// We inherit from the default RouterOutlet
export class LoggedInOutlet extends RouterOutlet {

  // We call the parent constructor
  constructor(viewContainer, compiler, router, injector) {
    super(viewContainer, compiler, router, injector);
  }

  canActivate(instruction) {
    var url = this._router.lastNavigationAttempt;
    // If the user is going to a URL that requires authentication and is not logged in (meaning we don't have the JWT saved in localStorage), we redirect the user to the login page.
    if (url !== '/login' && !localStorage.getItem('jwt')) {
      instruction.component = Login;
    }
    return PromiseWrapper.resolve(true);
  }
}
```

So in this case, we created a new directive that will extend the `RouterOutlet` one. The interesting part in here is the `canActivate` method, in there we grab the current url and if it is not the `/login` one and we are not authenticated, we won't allow the user to go there and we mount the `Login` component instead.

Thanks to that, we have a much prettier way to manage authenticated users other than listening to route changes events.

I grabbed this example from [Auth0](https://auth0.com/blog/2015/05/14/creating-your-first-real-world-angular-2-app-from-authentication-to-calling-an-api-and-everything-in-between/)

## Conclusions

Angular 2 is the right step forward. It is way simpler than Angular 1. No more controllers, no more scope inheritance that drives us insane, the directives API is much easier to understand than the actual `DDO`. No more $apply, and the best of all things, thanks to [properties] and (events) we removed like 30 directives that are not needed anymore and apart from that, we simplified the way of consuming directives.

On the other hand, there is no more 5 "different" types of services, so we just need to create a plain ES6/TS class and write methods on it.

If you had issues understanding the properties and events, please watch Misko video at ng-conf: https://www.youtube.com/watch?v=-dMBcqwvYA0

So, do you agree with me? What do you think? Leave a comment.
