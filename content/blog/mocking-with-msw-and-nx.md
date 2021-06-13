---
title: 'Mocking with MSW and Nx'
description: ''
date: 2021-06-13T16:27:30+02:00
categories: []
tags: ["mocking", "msw", "nx"]
---

We are sitting in front of our new project and we need to start coding some new screens but the backend is just not ready yet. Isn't that familiar?

It is a good practice to have some sort of mocking mechanism so we can start coding as soon as we can and also make our unit testing less error prone by using well known data.

Yes, but that sounds overly complicated to achieve. We need to turn off and on the backend, swap modules around to enable or disable the mocking and be careful to not deploy any of that the production.

Well, not anymore.

## Introducing MSW

[MSW](https://mswjs.io/) as they say, is the API mocking of the next generation. Right, but what does that mean? It works by intercepting requests on the network level or in other words, by using a service worker.

The interesting part is that it is invisible for us, developers. Isn't that great?

## Creating our project using NX

There is no other reason of using [NX](https://nx.dev/) other than it being awesome. Everything we are going to see here works with `Angular CLI` as well.

Let's create a new workspace with an `Angular + Nest` projects. The fact we are going to mock the backend doesn't mean we don't need a backend... eventually.

```bash
$ npx create-nx-workspace msw-tutorial
```

When asked, select `angular-nest` and call the application whatever you want, I used `spa`. Then choose `CSS` (we are not going to do styles here) and `No` for the cloud.

Open the workspace in your ~~favorite editor~~ `vscode` and also run both the `spa` and the `api`:

```bash
$ npx nx serve
```

```bash
$ npx nx serve api
```

> You need two terminal open for this.

Once it finish, we can navigate to `http://localhost:4200` and then see:

![](/images/posts/mswnx/1.png)

That `Message` at the bottom is a message from our API. We can open `apps/api/src/app/app.controller.ts` if we want to take a look.

## Setting up the environment for MSW

With our app working, let's set up `MSW`.

First, let's install it:

```bash
$ npm i -D msw
```

`MSW` depends on a service worker being installed, so let's create it first:

```bash
$ npx msw init apps/spa/src
```

This will copy the `mockServiceWorker.js` inside the `spa` project. You can copy it in a different place if needed, but for the sake of this tutorial, let's assume we installed it there. If asked to save the directory in the package.json, feel free to say no. We don't need it.

Our next step is register this `mockServiceWorker.js` within Angular. For that, open `angular.json` and update it:

```json {linenos=inline, linenostart=46, hl_lines=[10]}
"options": {
  "outputPath": "dist/apps/spa",
  "index": "apps/spa/src/index.html",
  "main": "apps/spa/src/main.ts",
  "polyfills": "apps/spa/src/polyfills.ts",
  "tsConfig": "apps/spa/tsconfig.app.json",
  "assets": [
    "apps/spa/src/favicon.ico",
    "apps/spa/src/assets",
    "apps/spa/src/mockServiceWorker.js"
  ],
  "styles": [
    "apps/spa/src/styles.css"
  ],
  "scripts": []
},
```

Now when `MSW` ask for this service worker to be installed, Angular will be able to locale it.

Our next question is: When do we want to use mocking? Certainly not in production and sometimes at development. A common pattern is to create another environment called *mock*.

First, let's update again our `angular.json` to add a new configuration:

```json {linenos=inline, linenostart=92, hl_lines=["9-22"]}
"development": {
  "buildOptimizer": false,
  "optimization": false,
  "vendorChunk": true,
  "extractLicenses": false,
  "sourceMap": true,
  "namedChunks": true
},
"mock": {
  "buildOptimizer": false,
  "optimization": false,
  "vendorChunk": true,
  "extractLicenses": false,
  "sourceMap": true,
  "namedChunks": true,
  "fileReplacements": [
    {
      "replace": "apps/spa/src/environments/environment.ts",
      "with": "apps/spa/src/environments/environment.mock.ts"
    }
  ]
}
```

It is a copy of development but adding a new `environment.mock.ts` file. So let's add it to `apps/spa/src/environments`:

File: `environment.mock.ts`
```typescript
export const environment = {
  production: false,
};
```

To make things easier, let's create a new `script`:

File: `package.json`
```json {hl_lines=[6]}
"scripts": {
    "ng": "nx",
    "postinstall": "node ./decorate-angular-cli.js && ngcc --properties es2015 browser module main",
    "nx": "nx",
    "start": "ng serve",
    "start-mock": "ng serve spa --configuration mock",
    "build": "ng build",
```

To be able to `serve` the app with this new `mock` configuration, we have to add it to the `angular.json`:

```json {linenos=inline, hl_lines=["4-6"], linenostart=115}
"development": {
  "browserTarget": "spa:build:development"
},
"mock": {
  "browserTarget": "spa:build:mock"
}
```

## Creating our MSW configuration

Now with our environment set up, the next thing is create our actual mock, right? Since we are using `NX`, let's create a new library:

```bash
$ npx nx g @nrwl/workspace:library --name=mock-api --skipBabelrc --unitTestRunner=none
```

Let's delete `libs/mock-api/src/lib/mock-api.ts` and create there:

File: `handlers.ts`
```typescript
export const handlers = [];
```

File: `browser.ts`
```typescript
import { setupWorker } from 'msw';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

Also update `libs/mock-api/src/index.ts`:

```typescript {linenos=inline}
export * from './lib/browser';
```

At `handlers` we configure all the network calls we want to mock and at `browser.ts` we create a `worker` object that we can use to start `MSW` with our handlers.

Where should we start `MSW`? Since we only want to run it in `mock` mode, let's update `apps/spa/src/environments/environments.mock.ts`:

```typescript {hl_lines=["1-5"]}
import { worker } from '@msw-tutorial/mock-api';

worker.start({
  onUnhandledRequest: 'bypass',
});

export const environment = {
  production: false,
};
```

Here we made an important decision. What do we do with all those requests that are **not** handled by our mock? We `bypass` it to the real deal. By doing this, we can be selective with the mocks we want to have.

Now, we run our `backend` and `frontend` again:

```bash
$ npm run start-mock
```

```bash
$ npx nx serve api
```

Only that this time we are using our new `start-mock` script.

If we now open our site again at `http://localhost:4200` we see, well, the exact same page:

![](/images/posts/mswnx/1.png)

But if we open the console, we can see:

![](/images/posts/mswnx/2.png)

MSW seems to be enabled and working. It is just that we haven't create a mock handler yet.

Before we move on, you may notice a warning in the console about one file that `depends on 'debug'`. If that is the case, open the `angular.json` and update it as follows:

```json {linenos=inline, linenostart=46, hl_lines=["12-14"]}
"options": {
  "outputPath": "dist/apps/spa",
  "index": "apps/spa/src/index.html",
  "main": "apps/spa/src/main.ts",
  "polyfills": "apps/spa/src/polyfills.ts",
  "tsConfig": "apps/spa/tsconfig.app.json",
  "assets": [
    "apps/spa/src/favicon.ico",
    "apps/spa/src/assets",
    "apps/spa/src/mockServiceWorker.js"
  ],
  "allowedCommonJsDependencies": [
    "debug"
  ],
```

In any case, let's create our first mock route. If we check our `app.component` we can see:

```typescript
@Component({
  selector: 'msw-tutorial-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  hello$ = this.http.get<Message>('/api/hello');
  constructor(private http: HttpClient) {}
}
```

We see, first, very bad practices by including a HTTP call here, but then we see that it is calling `/api/hello`.

Let's add a handler:

File: `handlers.ts`

```typescript {linenos=inline}
import { rest } from 'msw';

export const handlers = [
  rest.get('/api/hello', async (req, res, ctx) => {
    return res(ctx.json({ message: 'Msw works like a charm!' }));
  }),
];
```

This looks like pretty much like `express`.

If now we open our page again, we see:

![](/images/posts/mswnx/3.png)

That is our mock!!

And if we check the console, we can see:

![](/images/posts/mswnx/4.png)

This is just, perfect.

Go ahead and restart your app in development mode:

```bash
$ npx nx serve
```

What do we see? No mock trace anywhere at all.

## Conclusion

`MSW` is an easy way to add a mocking layer in an application. We can deliberately decide if we want to mock everything or just part of the application.

Once configured, we just need to add as many `handlers` as we need for our mocking purposes and we can go as complex as we need there. We can have a json "database" with fake data, or use faker for example.

But the best part is that it is completely invisible for Angular. We don't need to mock any service to make it work or be sure that we are not leaving any "flag" on before we deploy to production.

We can also leverage this mocking in our e2e without having to do anything at all. Since e2e depends on a running app, as long as we run it using our mock configuration, our e2e tests will use this mock data.

For unit test, we can use our mock as well, but I still think that unit test shouldn't bother with real calls, whether or not they are mock or real.

You can grab the final example from [github](https://github.com/Foxandxss/msw-tutorial).