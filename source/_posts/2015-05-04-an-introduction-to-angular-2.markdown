---
layout: post
title: "An introduction to Angular 2"
date: 2015-05-04 20:26
comments: true
categories: [angular2, authentication]
---

**DISCLAIMER**: Angular 2 is still on a developer preview, so it has a lot of missing features, broken stuff and it is also subject to change.

Ready for Angular 2? You bet!

For this demo, we are going to code an application which requests german words. The word will also come with its translation if the user is authenticated.

First, grab the KOA backend from [here](https://github.com/angular-tips/GermanWords-backend-koa), then:

```
$ npm install
$ node server.js
```
<!--more-->
**NOTE**: You need node 0.12 or io.js to work with koa.

Leave it running and clone [this repo](https://github.com/angular-tips/GermanWords-frontend-angular-2). Here we are going to work on the `before` folder. To use it:

```
$ npm install
$ npm start
```

I got this boilerplate from my friend [Pawel](https://github.com/pkozlowski-opensource) and I updated thanks to [mgonto](https://github.com/mgonto) and [gdi2290](https://github.com/gdi2290).

Let me explain it a bit:

Since `Angular 2` is still not final, it needs a lot of boilerplate to be setup, and this boilerplate do it for you.

On one hand, we have the `gulpfile` where apart from the classic tasks to process javascript and css, we have tasks to build both angular and its router from the sources.
On the other hand, we have the `index.html` file where we load all the needed libraries for `Angular 2`. As I said before, since `Angular 2` is still not final, we have to load a lot of libraries to make it work, but worry not, on the final version it won't need that.

Another interesting thing here is `System`. `System` is the module loader of `ES6` and it is the one which will start our application. Yay, no more hundreds of script tags!

Also, there is no more `ng-app` :)

Alright! `System` is going to load `index` which is supposed to bootstrap our app, right? How do we do that? To bootstrap an `Angular 2` application we need to use the `boostrap` method passing our main component. Component? Yeah, we will see in a bit :)

```javascript
bootstrap(OurMainComponent);
```

For our app, we will have an `App` component so to bootstrap our application, we can do:

```javascript index.js
import { App } from './app/app';

boostrap(App);
```

We just need to import our `App` component and then use it to bootstrap the app. Another thing we need to do here is load the router. The router is external to angular 2, so we need to load it as a dependency. As today (2015-05-04) the router is not exporting the needed injectable to make this easy, so we need to construct a new instance of the router and inject it:

```javascript index.js
import { bootstrap } from 'angular2/angular2';
import { RootRouter } from 'angular2/src/router/router';
import { Pipeline } from 'angular2/src/router/pipeline';
import { bind } from 'angular2/di';
import { Router } from 'angular2/router';

import { App } from './app/app';

bootstrap(App, [
  bind(Router).toValue(new RootRouter(new Pipeline()))
]);
```

We loaded all the needed dependencies to construct the router and also the `bind` service to create a Binding for the router. Hopefully this will be fixed really soon.

Okey, let's code the App component. But what's a component? A component is a just a class which can be used to represent a page like `home`, `login`, `users`... or even used to create a `directive` like `datepicker`, `tabs`, etc.

```javascript app/app.js
export class App {

}
```

As I said, the component is just a class (we export it to be able to import it from other files like we did in `index`). So far it is not doing anything, so let fix that.

In `Angular 2` we can use annotations. Think about annotations as a way to add metadata to our classes. Let's go step by step. First import the two annotations we need:

```javascript app/app.js
import {View, Component} from 'angular2/angular2';
```

Then we just need to use them. `Component` is an annotation to add metadata about the component itself, that includes its selector, or what services we need to inject. On the other hand, the `View` annotation is used for the HTML templates. Here we can specify the template we want to use with the component, if we need to use directives in it, etc. We can have more than one `View` annotation (mobile view, desktop view, etc).

Let's use them:

```javascript app/app.js
@Component({
  selector: 'words-app'
})
@View({
  template: `<h1>Hello angular 2</h1>`
})
export class App {

}
```

For `Component` we specified that the selector for this component will be `words-app` (look mum, no more `camelCase` vs `snake-case` like `Angular 1`), that means that to use this component, we just need to drop a `<words-app></words-app>` somewhere!

For `View` we created a simple template (notice the quotes).

**NOTE**: Don't put semicolons after each annotation, that will make `Angular 2` cry :)

So you said we can drop that selector somewhere? Yeah, let's modify the `index.html`:

```html index.html
<body>
    <div class="container">
        <words-app>
            Loading...
        </words-app>
    </div>
</body>
```

Ok, here we used our new component. Let's go to `localhost:3000`

{% img /images/posts/angular2intro/1.png %}

So far so good, isn't it? Inside `App` we are going to configure the router that we got injected from the `bootstrap` function:

```javascript app/app.js
export class App {
  constructor(router: Router) {

  }
}
```

The class constructor will receive a `router` parameter of the type `Router`. Let's use it:

```javascript app/app.js
export class App {
  constructor(router: Router) {
    router
      .config('/home', Home)
      .then(() => router.navigate('/home'));
  }
}
```

The `router` has a `config` method where we pass the `path` and what `component` to use for that path. We chain the promise it returns to immediately navigate to that `/home` route.

Soon we will be able to configure the routes of each component as an annotation, but for the time being, we will use this way of configuring the router.

When we load a new route, where do we put the component? We need an `ng-view` which is called `router-outlet` in this new router.

Let's change our `View` annotation like:

```javascript app/app.js
@View({
  template: `<router-outlet></router-outlet>`,
  directives: [RouterOutlet]
})
```

There is something important here: If our template uses a directive/component, we need to import it explicitly and that is the case of `RouterOutlet`. Notice that on the `directives` array we put the component object we are importing. Talking about imports... we need to add a few. Our imports are now like:

```javascript app/app.js
import {View, Component} from 'angular2/angular2';
import {Router, RouterOutlet} from 'angular2/router';
import {Home} from '../home/home';
```

We loaded the `Router`, the `RouterOutlet` component and also the `Home` component.

Now our app will navigate directly to that `Home` component. Let's create it:

```javascript home/home.js
import {View, Component} from 'angular2/angular2';

@Component({
  selector: 'home'
})
@View({
  templateUrl: 'home/home.html'
})
export class Home {

}
```

This time instead of embedding our template directly on the annotation, we will create an external file for it where we put:

```html home/home.html
<h1>This is home</h1>
```

Before running our app, let's add bootstrap to our `index.css`:

```css index.css
@import 'bootstrap';
```

Now we have something like:

{% img /images/posts/angular2intro/2.png %}

Let's do something real, shall we? On this home component, we want to grab a new word every time we click a button. To abstract `Home` from requests and stuff, let's create a service for that, called `Words`:

```javascript services/words.js
export class Words {
  getWord() {
    var jwt = localStorage.getItem('jwt');

    return fetch('http://localhost:3001/api/random-word', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + jwt
      }
    })
    .then((response) => {
      return response.text();
    })
    .then((text) => {
      return JSON.parse(text);
    })
  }
}
```

A service in `Angular 2` is just a class and for this one, we just need a method to grab a word. As today, `Angular 2` doesn't have anything like `$http` so we are going to use a library called `fetch`.

With `fetch` we make a request to our backend, passing the `JWT` token if there is any, we extract the text from the response and we parse it so the next time we create a new `.then` we will receive the final object.

Let's import this service in `Home`:

```javascript home/home.js
import {Words} from '../services/words';
```

Now we need to tell our component that we want to inject the service:

```javascript home/home.js
@Component({
  selector: 'home',
  injectables: [Words]
})
```

Finally, we receive a new instance of the service in the constructor:

```javascript home/home.js
export class Home {
  constructor(words: Words) {
    this.words = words;
  }
}
```

Like with the router, we receive a `words` instance of the type `Words`.

With our service in place, let's code the template:
{% raw %}
```html home/home.html
<div class="jumbotron centered">
  <h1>German words demo!</h1>
  <p>Click the button below to get a random German word with its translation:</p>
  <p><a class="btn btn-primary" role="button" (click)="getRandomWord()">Give me a word!</a></p>
  <div *if="word">
    <pre>Word: {{word.german}}</pre>
  </div>
</div>
```
{% endraw %}
There is a couple of new stuff in `Angular 2`. Instead of `ng-click` we use `(click)`, the parenthesis means that it is an event (click event). On the other hand, we have that `*if` which is our classic `ng-if`. The star means that it is a template, basically a shorter version of doing:

```html
<template [if]="word">
```

Is that `if` a directive? Yes, and what we said about using directives inside our templates? That we need to import them:

```javascript home/home.js
import {View, Component, If} from 'angular2/angular2';
```

And then:

```javascript home/home.js
@View({
  templateUrl: 'home/home.html',
  directives: [If]
})
```

Next, we need that button working so we can show the words:

```javascript home/home.js
getRandomWord() {
  this.words.getWord().then((response) => {
    this.word = response;
  });
}
```

If we now try the app, we can see something like:

{% img /images/posts/angular2intro/3.png %}

Alright, it is getting shape!

Let's move to the authentication. A service you said? Right on!

```javascript services/auth.js
export class Auth {
  constructor() {
    this.token = localStorage.getItem('jwt');
    this.user = this.token && jwt_decode(this.token);
  }

  isAuth() {
    return !!this.token;
  }

  getUser() {
    return this.user;
  }

  login(username, password) {
    return fetch('http://localhost:3001/sessions/create', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        username, password
      })
    })
    .then((response) => {
      return response.text();
    })
    .then((text) => {
      this.token = JSON.parse(text).id_token;
      localStorage.setItem('jwt', this.token);
    });
  }

  logout() {
    localStorage.removeItem('jwt');
    this.token = null;
    this.user = null;
  }
}
```

We store two items, the token and the decoded token, then we have a method to login and a method to logout. Nothing really special. Both `localStorage` and `jwt_decode` are globals so we don't need to import that. Again, we are using `fetch` to do the request to the backend.

On the other hand, when we talk about login and stuff, we need a way to actually login, right? Let's create a component for login:

```javascript login/login.js
import {Component, View} from 'angular2/angular2';
import {Router} from 'angular2/router';
import {Auth} from '../services/auth';

@Component({
  selector: 'login',
  injectables: [Auth]
})
@View({
  templateUrl: 'login/login.html'
})
export class Login {
  constructor(router: Router, auth: Auth) {
    this.router = router;
    this.auth = auth;
  }

  login(event, username, password) {
    event.preventDefault();
    this.auth.login(username, password).then(() => {
      this.router.parent.navigate('/home');
    })
    .catch((error) => {
      alert(error);
    });
  }
}
```

Like the other components, we have our `Component` and `View` annotations and we also specified that the new `Auth` service is going to be injected into the component.

This component only have one method were we use the `Auth` service to login and set the `jwt` token in the `localStorage`. If we succeed, we just navigate to the `/home` page.

For the template, we have:

```html login/login.html
<div class="login jumbotron center-block">
  <h1>Login</h1>
  <form role="form" (submit)="login($event, username.value, password.value)">
    <div class="form-group">
      <label for="username">Username</label>
      <input type="text" #username class="form-control" id="username" placeholder="Username">
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input type="password" #password class="form-control" id="password" placeholder="Password">
    </div>
    <button type="submit" class="btn btn-default">Submit</button>
  </form>
</div>
```

Notice how we have stuff like `#username` instead of `ng-click="username"`. That is how `Angular 2` binds our stuff.

As a last step, let's modify the css a bit because the form is a bit wide:

```css login/login.css
.login {
  width: 40%;
}
```

We also need to import this `.css` file:

```html index.css
@import 'bootstrap';
@import './src/login/login.css';
```

Having the login in place, we need a link for it in our `Home` component:

```html home/home.html
<div class="jumbotron centered">
  <h1>German words demo!</h1>
  <p>Click the button below to get a random German word with its translation:</p>
  <p><a class="btn btn-primary" role="button" (click)="getRandomWord()">Give me a word!</a></p>
  <div *if="word">
    <pre>Word: {{word.german}}</pre>
  </div>
</div>
<div *if="isAuth">
  <p>Welcome back {{user.username}}</p>
  <a href="#" (click)="logout($event)">Logout</a>
</div>
<div *if="!isAuth">
  <a href="#" (click)="login($event)">Login</a>
</div>
```

So having a flag called `isAuth`, we will switch between to divs.

We will need the `Auth` service here as well, so let's import it:

```javascript home/home.js
import {Auth} from '../services/auth';

@Component({
  selector: 'home',
  injectables: [Words, Auth]
})
```

On the other hand, we need a `login` and `logout` methods, the `isAuth` flag and also a reference to the user. Our component is now like:

```javascript home/home.js
export class Home {
  constructor(router: Router, words: Words, auth: Auth) {
    this.router = router;
    this.auth = auth;
    this.words = words;

    this.isAuth = auth.isAuth();

    if (this.isAuth) {
      this.user = this.auth.getUser();
    }
  }

  getRandomWord() {
    this.words.getWord().then((response) => {
      this.word = response;
    });
  }

  login(event) {
    event.preventDefault();
    this.router.parent.navigate('/login');
  }

  logout(event) {
    event.preventDefault();
    this.auth.logout();
    this.isAuth = false;
    this.user = null;
  }
}
```

In the near future, we can avoid that `login` method thanks to the `RouteLink` component which is basically like `ui-sref`.

Alright, now we have the link to the `login` page:

{% img /images/posts/angular2intro/4.png %}

And if we click it, we... Oh wait, it is not working. Ah, we forgot to add the route for it back at `app.js`:

```javascript app/app.js


export class App {
  constructor(router: Router) {
    router
      .config('/home', Home)
      .then(() => router.config('/login', Login))
      .then(() => router.navigate('/home'));
  }
}
```

Now it works:

{% img /images/posts/angular2intro/5.png %}

And if we login with the demo credentials (demo / 12345) we see:

{% img /images/posts/angular2intro/6.png %}

That's great!

The last step is showing the translation if we are logged in and that is easy to do! We are already grabbing the words from the server and now that the server sees that we are authenticated, it will send the translation as well. That means that we just need to update our template:

```html home/home.html
<div class="jumbotron centered">
  <h1>German words demo!</h1>
  <p>Click the button below to get a random German word with its translation:</p>
  <p><a class="btn btn-primary" role="button" (click)="getRandomWord()">Give me a word!</a></p>
  <div *if="word">
    <pre>Word: {{word.german}}</pre>
    <pre *if="isAuth">Translation: {{word.english}}</pre>
    <p *if="!isAuth">Please login below to see the translation</p>
  </div>
</div>
<div *if="isAuth">
  <p>Welcome back {{user.username}}</p>
  <a href="#" (click)="logout($event)">Logout</a>
</div>
<div *if="!isAuth">
  <a href="#" (click)="login($event)">Login</a>
</div>
```

Now we have our app completed:

{% img /images/posts/angular2intro/7.png %}

Oh wait, I forgot to log in:

{% img /images/posts/angular2intro/8.png %}

I bet you can learn `Angular 2` faster than the word on the image :)

Before closing this article and as a curiosity, you can import the `Login` component in `Home`, add it as a used directive in the `View` component and then add `<login></login>` at the bottom of the template. Doing that, you will attach the entire login form and its functionality to the `Home` component, yay!

I want to thanks [Matias Gontovnikas](https://github.com/mgonto) and [PatrickJS](https://github.com/gdi2290) for their demo [angular2-authentication-sample](https://github.com/auth0/angular2-authentication-sample) and explanations which helped me a lot understanding the whole process.
