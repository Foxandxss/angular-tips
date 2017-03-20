+++
description = ""
title = "AngularJS, Angular and Angular v4"
date = "2017-03-12T13:22:31+01:00"
categories = []
tags = ["angular"]

+++

A lot is happening in the Angular world. A few years ago Angular split into the "Old World" of Angular v.1.x and the "New World" of Angular v.2. Both worlds carry the "Angular" label, which is almost as confusing today as it was when the split happened.

What's up with the _re-branding_ of Angular v.2 as "Angular"? What is _SemVer_? And just as we were getting used to Angular v.1 and Angular v.2, along comes Angular v.4. Is that a _third_ "New World"? What happened to Angular v.3? 
 
Yikes, all of this is really confusing!

This article aims to bring clairity to the confusion. 
At the end, you'll understand what's going on, why, and how these changes affect you.

## Two Angular Worlds

There are two "Angulars" ... and _only_ two "Angulars".

Angular v.2 was a decisive break from Angular v.1.
It's a new architecture, a new platform, a completely different product with its own approach to building a web client.

Every Angular version from v.2 forward is a step in the evolution of this new product. There will never again be a completely new product called "Angular".

It might have been better to give the new product an entirely new name.
But the Angular team wanted it to inherit the market position, momentum, and fantastic community of the original Angular.
To be fair, the same Google team was building the new platform and there is enough conceptual continuity to justify keeping "Angular" in the name.

We were getting used to the idea of calling the old product "Angular 1" and the new product "Angular 2". 
But there is a problem. 
The new product must evolve. 
Each new release needs a version number.
For valid reasons to be explained, for certain releases, the team wants to be able to change the first digit in the version number.

It's impossibly confusing to refer to the product as "Angular 2" when its version numbers become v.4, v.5, v.6, etc.

The old and new Angular products need names that are fixed and independent of the version number.
So they've been re-branded.

`AngularJS` is the official name of the "Old World" product, once known as "Angular 1".

`Angular` is the official name of the "New World" product, briefly known as "Angular 2".

No more "Angular 1" or "Angular 2". 

To understand what's behind the version numbering scheme that drove this re-branding effort, let's look at the old product, `AngularJS`.

## AngularJS

`AngularJS` remains a great product with over a million developers.
There are hundreds of thousands of applications written in `AngularJS`.
They aren't going away overnight, nor should they.

However, `AngularJS` is essentially frozen. The Angular team won't add new capabilities. New web client applications should be built in `Angular`.

Some `AngularJS` development continues in order to fix bugs and make it easier to migrate to "New World" `Angular`. The new release with these changes will all have version numbers that begin with `1`. 
You refer to a concrete version by saying, "I'm using `AngularJS 1.x.y`".

As I write this, the latest version of `AngularJS` is `1.6.3`.

## Breaking changes

I've been watching Angular evolve, release to release, since at least version `1.2`.
It was never obvious if it was safe to update my application to a new release.

There is no clear convention that governs the `AngularJS` version numbering scheme. 
Any update can break your application (more on breaking changes below). You must read the change log, understand what it says, and hope for the best.

Suppose your app is on `AngularJS v.1.4.4`. 
You see the next one is called `AngularJS v.1.4.5`.
That seems like a minor update. You install it and, boom, you get unexpected errors in unexpected places.

That is so wrong. Updates should be clear and predictable. We should know at a glance if an update can break our code. 

Today's applications can have hundreds of dependencies. 
No one can be an expert in every dependency. No one has time to read all of the change-logs. We need a simple way to quickly identify which updates are safe and which could be dangerous.

Here's a painful example from my personal experience working on `ui-bootstrap`. Our `package.json` was configured so that `npm` would install any `AngularJS 1.x.x` (more on how `npm` works later). 
One day, while processing a pull request to fix a typo, our [Travis](http://travis.ci.org) continuous integration system produced 200~ failing tests. 

How can a typo cause 200 failing tests? After one hour, we discovered the problem. A new version of AngularJS had been released a few hours ago.
The update contained an unexpected (and undocumented) breaking change
related to animation. [Here is the proof](https://github.com/angular-ui/bootstrap/pull/4303).

Things like that happened quite a few times. It happens less frequently now because (a) the AngularJS team is better at documenting breaking changes and (b) AngularJS has fewer breaking changes because it isn't evolving.

It's still a significant risk for an application with dependencies on other libraries that are more volatile and less carefully documented.

`AngularJS` isn't the only library with this problem.
Hundreds of other libraries release updates with breaking changes every day.

## Angular and _semantic versioning_

The new `Angular` library escapes this problem by adopting **semantic versioning**.

With semantic versioning, you can tell if a new `Angular` release is an easy install, with no breaking changes, simply by looking at the version number. If the _first digit_ is unchanged, there are no breaking changes. If the _first digit_ changes (say from `2` to `4`), the release contains a breaking change.
You have to investigate what has changed and decide when the time is ripe to upgrade.

That kind of clarity is great news. 
The downside is that breaking changes are inevitable and, therefore, new releases of Angular are bound to have version numbers like `v.4`, `v.5`, `v.6`, etc.

This realization forced the Angular team to re-brand the product so that it would be crystal clear: `Angular` is still `Angular` even as its version number rises to `4`, `5`, `6` and beyond.

 What is _semantic versioning_ and how does it work?

## Introducing Semantic Versioning

[Semantic Versioning (SemVer)](http://SemVer.org/) is a convention that dictates how the version number changes for each new release of a library. The version number of a library that conforms to SemVer tells you how each release differs from its predecessor.

A SemVer version has three parts.

![](/images/posts/angularv4semver/01.png)

We say that a release is a **major**, **minor** or **patch** release when the most significant (left-most) changed number is the major, minor, or patch digit.

### Patch release

Imagine we are maintaining a bootstrap library. We give our proud, first the version number, `1.0.0`. Suddenly we discover that there is a bug on the datepicker. We forgot about leap years, so February 2016 didn't have 29 days.

Sounds like a pretty big issue, so we want to make a fix-it release right now. 
What kind of change will this be? 

The release contains only a single **bug fix**.
We assume that no one wanted the datepicker to give the wrong date and we're confident that the mistake hasn't been in the wild long enough for anyone to have relied upon that mistake in some perverse way. So this should be a **patch** release with version `1.0.1`.

When someone says: Hey, new `ng-bootstrap` release, it is `1.0.1`. We know beforehand that the release **only contains bug fixes** so it is safe to update. That is what we call, a predicatable release.

More bugs of this kind? We release `1.0.2`, `1.0.3`, and so on.

### Feature release

When an update only contains fixes, we release a **patch** version, but when an update contains at least **one** new feature, it should increment the version's **minor** digit, making it a **minor** release. A minor version can optionally, contains bug fixes as well.

Our datepicker is hugely popular and people have requested additional features such as the ability to add custom themes.
We cut a new release with _a bunch of these features_, as well as some more bug fixes.
Because we added **new features**, we must increment the **minor** version digit. You typically re-set the patch digit to zero at the same time. 
Accordingly, we release the `1.1.0` version of the datepicker.

### Major release

Updating your app with a patch or a minor version should not break the application. It may fix bugs or introduce new features that you can exploit while updating your app. But the new release shouldn't cause your app to fail or behave differently than you intended.

You should be able to upgrade to the `1.23.15` datepicker a year from now without making any changes to your app.

Sometimes to fix a bug or add an important feature, we have to make a breaking change. 
A **breaking change** means that upgrading to the new version of the library _might_ cause your application to behave in an unexpected way that contradicts previously documented behavior or fail outright.

So... what is exactly a **Breaking Change**?

Let's return to our datepicker example.
Imagine that the `1.1.0` API allows you to configure the theme with a binding that maps to an `@Input` property like this:

```html
<datepicker theme="dark"></datepicker>
``` 

```typescript
@Component{
  selector: 'datepicker',
  templateUrl: 'Datepicker.html'
}
export class Datepicker {
  @Input() theme = ''; // default theme
  ...
}
```

One day, after a couple of beers, we decided that it would be cool to have a `blink` option that is true by default. The datepicker would flash annoyingly when the date changes.

If you don't like it, you can disable blink by configuring with another `@Input` property. Here's version `1.2.0`:

```html
<datepicker theme="dark" blink="false"></datepicker>
```

```typescript
@Component{
  selector: 'datepicker',
  templateUrl: 'Datepicker.html'
}
export class Datepicker {
  @Input() theme = ''; // default theme
  @Input() blink = true;
  ...
}
```
Among the one million datepicker users only one person like the option option. 
Man, I should go out for beers with that person because obviously we like the same stuff.
Was it a bad idea? Probably, but there it is.

The datepicker continues to evolve with more and more options, each implemented as a separate element attribute paired with its own `@Input` property. We're up to ten of these by version `1.4.5`. The list of options, the implementation, and the effort to configure a datepicker is getting way out of hand:

```html
<datepicker theme="dark" blink="false" closeBoxPostion="top-left" 
   foo="..." bar="..." baz="..." class="...">
</datepicker>
```

```typescript
@Component{
  selector: 'datepicker',
  templateUrl: 'Datepicker.html'
}
export class Datepicker {
  @Input() theme = ''; // default theme
  @Input() blink = true;
  @Input() closeBoxPosition = 'top-right'; // default position
  @Input() ... more of these ...
  ...
}
```
This has to stop.
It's hard for developers to databind to this component because it has so many separate hooks. The code is becoming a mess. Change detection is working overtime. If current trends continue it will only get worse.

You decide to consolidate the customizations into a single `DatepickerOptions` object that works like this:

```html
<datepicker options="datepickerOptions" class="..."></datepicker>
```

```typescript
@Component{
  selector: 'datepicker',
  templateUrl: 'Datepicker.html'
}
export class Datepicker implements OnChange {
  @Input() options: DatepickerOptions;

  ngOnChange() {
    this.options = { ...DefaultDatepickerOptions, ...this.options };
  }
  ...
}
```
Now the application component that displays the `Datepicker` exposes a single `datepickerOptions` property with the desired custom settings.

That's a vast improvement for everyone. 

Unfortunately, it's a **breaking change**. The 99% of users who never set an option because they liked the defaults aren't affected.

But you've broken the apps of the 1% who set the theme, or the blink, or any of the other options. 
When they upgrade to the new `Datepicker` they'll get an Angular compilation error complaining about unknown properties.

A broken app should be easy to fix. But it still _has_ to be fixed.
The 1% who set any option will have to change the way they interact with the `DatePicker`, perhaps like this:

```typescript
@Component{
  selector: 'my-component',
  template: `
    <label>Order Date:
      <datepicker options="datepickerOptions"></datepicker>
    </label>
    ...`
}
export class MyComponent {
  datepickerOptions = {
    blink: false
    closeBoxPosition: 'top-left'
  };
}
```

A **Breaking Change** is a change that forces a user to update
an application when upgrading to the new library. 
It doesn't matter how few users are affected.
It's a breaking change if it affect anyone.

According to SemVer, the new release with this change must increment the **major** version digit.
The revised `Datepicker` library version becomes `2.0.0`.

Because we follow SemVer, users of the `Datepicker` know, **simply by looking at the version number**, that this new release _might break_ their apps.

They shouldn't be surprised.
They can read the change log, find the breaking change,
and decide if and when to upgrade to the new `Datepicker`.

You do have a change log, don't you?

### Identify breaking changes in the change log

SemVer doesn't require a change log but every library should have one. The conventional change log is a [Markdown](https://daringfireball.net/projects/markdown/syntax) 
file called CHANGELOG.md.

Your change log should have a new entry for each release, whether patch, minor, or major. 
The release entry identifies what changed in that release.

It's especially important to highlight the breaking changes of a major release. 
The change log entry for `Datepicker v.2.0.0` could be as simple as:

> ### Features
> * Can visually display blackout days which the user cannot select
by setting the `blackoutDays` array. See [API documentation]().
>
> ### BREAKING CHANGES
> * All datepicker options have been consolidated into a single `DatepickerOptions` object.
You may have to change `Datepicker` bindings to use the new options object. 
> See the API documentation.
>
> * The `blink` option is now `false` by default.


## NPM and SemVer

NPM helps us manage libraries that conform to SemVer.
I'll give you the short story here.
You can get the [official story on the web](https://docs.npmjs.com/getting-started/semantic-versioning)

We tell `npm` which libraries ("packages") to install by configuring a `project.json` file.
We have different ways of specifying the library version. We can install a specific version of a library by supplying the exact version number:

```json
"cool-library": "1.3.5"
```

The `~` prefix lets `npm` install a patch version equal to or greater than specified but _not_ a higher minor or major version:

```json
"cool-library": "~1.3.5"
```

The `^` prefix lets `npm` install the latest minor and patch versions but _not_ a higher major version:

```json
"cool-library": "^1.3.5"
```

This should be your default `npm` version format because it allows you to stay current without risk of installing a major version with a breaking change.

Consider this history of recent cool library releases
* `2.1.2`
* `2.0.0`
* `1.4.3`
* `1.3.7`
* `1.3.5`

Then `npm install` delivers `cool-library v.1.3.5` with the first specification, `v.1.3.7` with the second specification, and `v.1.4.3` with the third.

It won't install either of the `2.x` versions until you manually update the version number in `package.json` so there should be no risk of accidentally installing a `cool-library` release that breaks your app &mdash; if the library author followed the rules. 

Remember that `AngularJS` doesn't follow SemVer so `npm` can't protect us. That is why I stumbled into an error when I installed dependencies for my `ui-bootstrap` library. The `package.json` allowed `npm` to install the latest version of `AngularJS` (greater than `1.4.0`):

```json
"angular": "^1.4.0"
```

The Travis CI system &mdash; which always installs fresh packages when it runs a build &mdash; installed the newly released `v.1.4.5` which contained a breaking change. 

That hurt. It took a long time for me to figure out what was wrong. 

That won't happen again with `Angular` which does follow SemVer.

## The new _Angular_

Many of us feel that calling the new framework, `Angular` was a bad idea. The new Angular wasn't the old Angular with some breaking changes. It was complete rewrite of the framework from the ground up.
It deserved a new product name, not a new version number.

Keeping the "Angular" name was confusing enough.
But we compounded the confusion by calling the new product `Angular 2`. The moment we adopted *semantic versioning*, we knew that the major version number would keep growing.

Imagine having to differentiate
* `Angular 1`
* `Angular 2`
* `Angular 2, v.2`
* `Angular 2. v.4`
* `Angular 2. v.5`

... forever.

This confusion had to be addressed, first by re-branding and then by separating the product name from the version number.

Henceforth we expect to see ...
* `AngularJS 1`
* `AngularJS 1.4.x`
* `AngularJS 1.6.x`

and ...
* `Angular v.2.4.9`
* `Angular v.4.x.y`
* `Angular v.5.x.y`

All new `Angular` releases of the form, `2.x.y`, contain new features and bug fixes to the major release that began as `Angular 2`. 

If we created an application using `2.0.0`, we can update it to the latest minor version (`2.4.9` at the time of this article) and be 100% sure that our application will continue working as it did before.

During the `v.2` era, we've gained access to `i18n` stuff, better `animations` and so on. But there have been no breaking changes.

`Angular`, like every other living library, must evolve and evolution entails breaking changes. 

There are many sources of breaking change. 

Sometimes there's a much better way to doing something that requires a minimal breaking change that affects a few people. How few doesn't matter. 

Sometimes the only way to fix a critical fix is a breaking change. 

Sometimes the cause is Angular's reliance on an upgraded dependency that itself imposes a breaking change. Angular v.4 is built with TypeScript and you'll have to upgrade to at least TypeScript v.2.2 to use all of Angular's capabilities.

You can see other examples of Angular breaking changes in the [change log for the Angular v.4 release candidates](https://github.com/angular/angular/blob/master/CHANGELOG.md).

## Scheduling breaking changes
The Angular team understands that updating a big application is not a casual or easy task.
No one _wants_ breaking changes. But it they must happen, they should be predictable.

Most organizations need to plan and find resources for an upgrade effort. They want to know, in advance, how often Angular will change and, most importantly, when an Angular release will contain breaking changes.

Accordingly, the Angular team decided on a release schedule that allows the product to take small steps forward &mdash; patch and feature releases &mdash; every few weeks and to take big steps forward &mdash; with possible breaking changes &mdash; every six months.

The schedule for 2016-2017 looks like this:

![](https://3.bp.blogspot.com/-VuJatyMNo9c/WFmGL3nMX1I/AAAAAAAEMGg/9ZRfX7hK-L0tWWNx3Cb74qjYV0z89RzbQCLcB/s1600/release-cycle.png)

## Optional upgrade

The schedule helps you plan. Upgrading is always optional.  **You do not have to upgrade** every six months just because Angular does.

## What happened to Angular v.3?

You did not miss it!  The Angular version number is jumping from `v.2` to `v.4`. There is no and never will be a `v.3`.

They're skipping `v.3` to re-align library version numbers that got out of sync in the initial `Angular v.2` release.

Angular is composed of several semi-independent module libraries: `core`, `http`, `upgrade`, `router`. etc. You can install only those modules that you actually need in your app.

During the development of `Angular v.2`, the router module went through several iterations.
At one point there was a `router v.2`.
It was replaced at the last moment by a completely different implementation which required its own version number and became `router v.3`.

When you look at the `package.json` for an `Angular v.2` app, you see:

```json
"@angular/core": "2.4.9",
"@angular/http": "2.4.9",
"@angular/router": "3.4.9"
```

You see the problem? All packages have the same version except the router, so if the next Angular release became v3, what should happen?

```json
"@angular/core": "3.0.0",
"@angular/http": "3.0.0",
"@angular/router": "?"
```

No one wants to perpetuate the _router-off-by-one_ scheme.
The simple solution was to skip `v.3` and jump all modules to `4.0.0`. 

## How different is Angular v.4?

`Angular 2.0` was released September 14, 2016, about seven months ago. `Angular v.4` is primarily a _maintenance_ release with a few breaking changes.

The most notable breaking change is that lifecycle hooks are no longer abstract classes. They're interfaces now. Most applications treated them as interfaces anyway but some app classes inherited from these classes like this:

```typescript
@Component()
class SomeComponent extends OnInit {}
```

You'll have to change the word `extends` to `implements` like this:

```typescript
@Component()
class SomeComponent implements OnInit {}
```

That's not a big deal, is it? You can fix your entire application with a simple search-and-replace in a few minutes..

`Angular v4` requires `Typescript 2.2`. That is a one-line change to the `package.json`. Animations are now an independent module library, requiring another one-line `package.json` change and some additional `import` statements.

There are others breaking changes, but they will only affect a minimal number of applications, if any.

Be sure to check the [change log](https://github.com/angular/angular/blob/master/CHANGELOG.md) before upgrading.

There are many bug fixes and improvements under the hood, particularly to the size and performance of production builds. 
There are some new features too such as "Angular Universal" (experimental), `*ngFor` micro-syntax enhancements, and `i18n` extensions. More features are in the pipeline for `4.x` such as `http` interceptors.

`Angular v.4` is a worthy upgrade that shouldn't be too difficult to install.

## Conclusion

There's been a lot of understandable concern about `Angular v4`. Some folks were afraid that `Angular v4` is yet another complete rewrite. They wondered if they should wait to explore `Angular` until `v4` landed.

We hope you can see now that the reality is much more pleasant. 
Angular is great today and steadily evolving along a predictable path to a productive future. Angular v4 is an incremental step forward.

If you haven't tried Angular yet, start today. Most of you can update your v2 applications to v4 in an afternoon.
You'll be glad you did.

This article has been written by [Jesús Rodríguez](https://github.com/Foxandxss) and [Ward Bell](https://github.com/wardbell).
