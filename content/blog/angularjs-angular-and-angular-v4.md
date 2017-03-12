+++
description = ""
title = "AngularJS, Angular and Angular v4"
date = "2017-03-12T13:22:31+01:00"
categories = []
tags = ["angular"]

+++

A lot is happening in the Angular world. There is a brand rename so what used to be called Angular 2 is now just Angular, people talking about something called SEMVER.
There is a weird Angular v4 to be soon released... Yikes, all of that is really confusing.

The goal of this article is to clarify all those points. When you read it, you will understand the reasoning of all this changes and how they affect you.

## AngularJS

The first version of Angular. Its official name is `AngularJS`. So when we refer to a concrete version, we would say `AngularJS 1.x`.

The latest version of AngularJS at the time of writing this, is the version `1.6.3`. Which is the release number 187.

So what is the problem in here? I remember back at versions `1.2.x - 1.4.x`, there was no convention in what is allowed to do in a update so perhaps when updating to the next version, you would get
a nice **Breaking Change**, that means a change that could potentially break your application (more on breaking changes later).

That is so wrong, because updates should be predictable. We need to know beforehand what is coming on an update. If we have 100 dependencies in our project and we decide to update them, it would be nice
to know which updates are safe and which are dangerous.

If we are using say `AngularJS 1.4.4` and we see an `AngularJS 1.4.5`, we think that is a minor update, we install it and boom, we get unexpected errors in unexpected places.

Imagine if this happens with any of the other 100 dependencies we have.

I remember at `ui-bootstrap`. NPM was installing any `AngularJS 1.x.x` (more on how NPM works later). One day [Travis](http://travis.ci.org) was giving us 200~ failing tests with a PR that was changing just a typo in the docs.

How can a typo make 200 failing tests? After one hour we discovered something important. AngularJS was updated a few hours ago. Aha! There was something different. What was it? An unexpected (and not documented) breaking change
related with animation. [Here is the proof](https://github.com/angular-ui/bootstrap/pull/4303).

Things like that happened a few times, luckily things are better in the latest versions.

## Introducing Semantic Versioning

So this problem we had with `AngularJS` wasn't a remote case, that happened (and sadly, still happens) in hundred of libraries.

How is the community fixing the issue? With Semantic Versioning (SEMVER). It is a convention that dictates how a library should be versioned. In other words, what version number should we put on our new release based on the changes we have done.

![](/images/posts/angularv4semver/01.png)

Now, we have **major**, **minor** and **patch** versions. What does that mean? Let's go backwards.

Imagine we are maintaining a bootstrap library, we make the first release `1.0.0`. Suddenly we discover that there is a bug on the datepicker. We forgot about leap years, so February 2016 didn't have 29 days.

Sounds like a pretty big issue, so we want to make a release right now. What kind of changes will contain this new release? Only **bug fixes** right? So it is a **patch** version. We release a `1.0.1` version.

When someone says: Hey, new `ng-bootstrap` release, it is `1.0.1`. We know beforehand that the release **only contains bug fixes** so it is safe to update. That is what we call, a predicatable release.

More issues? We release `1.0.2`, `1.0.3`, and so on.

Our datepicker is so famous that we added a bunch of features _and fixed some remaining bugs_. Time to make a release. What kind of changes will contain this new release? **New features** and some **bug fixes**. So this is a **minor** version. We release a `1.1.0` version.

When an update only contains fixes, we release a **patch** version, but when an update contains at least **one** new feature, it should be a **minor** version. A minor version can optionally, contains bug fixes as well.

The good part, is that neither a patch nor a minor version is going to break your application. They just fix bugs or release new features, so they will never change how the library works. That means that you can install the `1.0.0` version and a year later, you can update it to `1.23.15` and be 100% sure that you won't need to make any changes to your app. It will continue working as before.

## Major versions, also known as Breaking changes

Not all changes are new features or bug fixes. Sometimes we discover that to make the library better, we need to do breaking changes. So... what is exactly a **Breaking Change**?

Back to our example, we are at `1.1.0` and we turn our attention to our modal. Our modal has a simple API:

```typescript
const element = `<div>.....</div>`;

new Modal(element).open();
```

One day, after a couple of beers we decided that our super simple modal would be so cool if we added a `blink` option. It would make our modal to blink and annoy our users. The API will change to:

```typescript
const element = `<div>.....</div>`;
const blink = true;

new Modal(element, blink).open();
```

New feature? Yes, let's release a `1.2.0`. We have one million user base and only one person liked the option. Man, I should go with beers with that person, we like the same stuff.

Was a bad idea? Probably, but there it is.

Our library keeps evolving, we are now at `1.4.5`, new cool features and we decided to revisit the modal. Our users ask for a close button on the corner of the modal. So we think, uhmmm, what if we do:

```typescript
const element = `<div>.....</div>`;
const blink = true;
const closeButton = true;

new Modal(element, blink, closeButton).open();
```

Sounds good, but we are going to get so many request like this, that we don't want our Modal API to contain 20 parameters, right? So we are going to change the API to:

```typescript
new Modal(element, { options });
```

So we can use it like:

```typescript
const element = `<div>.....</div>`;
const options = {
  blink: false,
  closeButton: true
};

new Modal(element, options).open();
```

That is way better than the former idea. What is the problem in here? This is a breaking change. 99.99% of our users won't be affected by it, they were using the `Modal` with just one parameter. Adding new parameters won't break existing applications.

The problem is that 1 user that liked the blink will know find that his application is broken. He is not getting any more blink, unless he updates his code. That is a **Breaking Change**.

A **Breaking Change** is a change that forces the users to update their usage of the library on their application. Even if that change is going to affect a 1% of the users.

Now, we are forced to create a new major version, that means `2.0.0`. Since this is also a predictable release, the users will double check the changelog to see what breaking changes exist and what do they need to do in order to update.

Even if this is a major release, a shiny `2.0.0` version, our changelog would be as simple as:

> ### Features
> * Ability to close modals with a close button in the corner
>
> ### BREAKING CHANGES
> * The second parameter of the modal is not the blink anymore, but an object with the different options to apply.

That breaking changes IN UPPER CASE sounds like a big problem, but in reality, it is a problem that affects to less than 1% of the users and even so, it is a 1 minute change. They just need to change their code to:

```typescript
const element = `<div>.....</div>`;
const options = { blink: true };

new Modal(element, options).open();
```

It is not terrible, isn't it? We were forced to create a major version for such a little change, but that is what SEMVER dictates.

In the real world, breaking changes are not often that silly. But at least we know beforehand that we probably need to make changes to our application in order to update. A good documentation will make those updates an easy ride :)

## NPM and SEMVER

When installing dependencies via NPM, we have different choices. We can install one concrete version of a library:

```json
"a-cool-lobrary": "1.3.5"
```

Any patch version:

```json
"a-cool-lobrary": "~1.3.5"
```

Or any major and patch versions (which is also the default):

```json
"a-cool-lobrary": "^1.3.5"
```

So if we use this latter way. Our application will use the latest `1.x.y` version of `a-cool-library`. And that is fine! Since they only contain new features and bug fixes, we can assure that new updates won't break our application.

That is exactly why we had the error at `ui-bootstrap`, we had:

```json
"angular": "^1.4.0"
```

And when `1.4.5` was released, Travis, which always install new packages when it runs a build, installed the new `1.4.5` which contained that breaking change. That is bad, but `AngularJS` is not following SEMVER.


## Angular v2

We all agree that calling the new framework, `Angular 2` was a bad idea. What should make Angular, a version 2 is a breaking change, not a complete rewrite from the ground up of the framework. That confused so many people and that is the reason of why are we here.

We are going to forget about that decision and concentrate on the present. We have now a library called `Angular` which started on the version **2**.

With the lesson learnt, Angular v2 follows SEMVER, so all the new releases under the `2.x.y` are only new features and bug fixes. That means that if we created an application using `2.0.0`, we can update it to the latest minor version (`2.4.9` at the time of this article) and be 100% sure that our application will continue working as good as before. The only difference is that now you have access to `i18n` stuff, better `animations` and so on. But again, no breaking change.

`Angular`, as any other library out there needs to make breaking changes time to time. Either because they found a better way of doing something that requires a minimum breaking change or because there was something not working out and they needed to fix it by doing a breaking change.

Since updating a big application is not an easy task, the Angular team decided to make breaking changes every 6 months. That means that a new major version is going to be released following that schedule. That gives more than enough time to update our applications.

![](https://3.bp.blogspot.com/-VuJatyMNo9c/WFmGL3nMX1I/AAAAAAAEMGg/9ZRfX7hK-L0tWWNx3Cb74qjYV0z89RzbQCLcB/s1600/release-cycle.png)

## Angular v4

Version 4? What happened with version 3?

Angular is composed of several libraries. We have several pacakges `core`, `http`, `upgrade`, `router`. etc. That way, you can install only those parts you need.

The issue here is that the first router (formerly known as router v1) wasn't meeting the expectations, so they decided to rewrite it. That originated the router v2. That router was also discarded so the actual router v3 was created.

Now we have:

```json
"@angular/core": "2.4.9",
"@angular/http": "2.4.9",
"@angular/router": "3.4.9"
```

You see the problem? All packages have the same version except the router, so if Angular were to move to v3, what would happen?

```json
"@angular/core": "3.0.0",
"@angular/http": "3.0.0",
"@angular/router": "?"
```

How should we version the router? `4.0.0`? That doesn't make sense.

The final decision was to simply make everything `4.0.0` and continue from there. With the problem solved, a future version can be named `5.0.0` and so on.

Will `Angular v4` be different? Of course not, as we learnt in here, `Angular v4` will contain a few breaking changes that will force the users to double check the changelog before updating.

The most notable breaking change is that lifecycle hooks are no longer abstract classes but interfaces. That will force our applications to change from:

```typescript
@Component()
class SomeComponent extends OnInit {}
```

to:

```typescript
@Component()
class SomeComponent implements OnInit {}
```

Is not a big deal, isn't it? A simple regex can change that in your entire application in 10 seconds.

Another notable change is that now `Angular v4` needs minimum `Typescript 2.1`. That is 2 seconds change on the package.json.

There are others breaking changes, but they will only affect a minimal number of applications, if any.

That wasn't that bad, isn't it?

## Conclusions

There is a lot of fuss around `Angular v4`. People scared that `Angular v4` was a complete rewrite, again.

We have seen in here that the reality is way different and that updating our applications to v4 shouldn't take more than an afternoon.
