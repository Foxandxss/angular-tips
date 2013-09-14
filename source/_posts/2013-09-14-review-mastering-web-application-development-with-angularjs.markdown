---
layout: post
title: "Review: Mastering Web Application Development with AngularJS"
date: 2013-09-14 20:28
comments: true
categories: [review]
---

In my old blogs I had a reviews section, so let's start with `Mastering Web Application Development with AngularJS`

{% img https://dgdsbygo8mp3h.cloudfront.net/sites/default/files/imagecache/productview_larger/1820OS.jpg %}
<!--more-->

It is awesome, period.

Ok ok, let's me review it properly :P

### Prologue

This book is written by two awesome Angular.js developers, `Pawel Kozlowski` and `Peter Bacon Darwin`. They did an amazing work explaining all the best practices to learn Angular.js. Let's review the book content.

### Book content

The first chapter is just an overview of what's Angular.js which just tries to sold Angular.js to you. Explains a little bit all the pieces that composes Angular.js.

For me, it is in the second chapter where you start to love the book, it introduces you on `angular-app` which is probably one of the best little examples of code that has a lot of best practices in one place. So they made this application as the sample application for this book and to be honest, they did an awesome work because people is really interested in this `angular-app` and now they have all the answers they need in the book.

The authors explained all the reasons behind the decisions they made to build the application. The `persistence store`, the `build system`, `tools`... and they also did a really good job explaining how the organized the files and folders of their application. I personally find their way really interesting, maybe a bit overkill sometimes but I really like it, and since there is always people asking about how to organize your applications, here is one good solution.

The chapter doesn't end there, they also explain how to test your application and why. People still code without doing tests and I think that everything we can do to encourage others developers to do testing is good enough. The downside here is that they explains how to do some `end-to-end testing` and that part has changed a little bit since the book was written and on the other hand, the `end-to-end` tests has disappeared from the `angular-app` too.

The 3rd chapter talks about server side communication and it is pretty interesting. It talks about how we can use the `$http` service to communicate with out backend. Everything (and when I say everything, it is everything) from how to use `$http` to what's `CORS`. It also explains what are promises and how can we use them with the `$q` service. On the other hand, if you want to use `RESTful endpoints` they explain how to use `$resource` which is a wrapper around `$http` to make this kind of communication easier.

Chapter 4 talks about how to display and format our data. It explains all the ways we have to display data on the screen, conditionally display, rendering collections using `ng-repeat`, and a really really interesting chapter about filters. Apart of the explanations of what is a filter and how can we write a custom one, it has the **BEST** explanation I ever seen about the `filter` filter, I think I knew like the 10% of what can that filter do.

I hate forms and if I make a club, I will get hundred of members. Yes, that is what chapter 5 is all about. The good part about it is that it explains everything we need to know about forms. Remember when I said everything in chapter 3? There is a known bug involving dynamic inputs with names, well, they even explain how to workaround that. Isn't it great? Yes it is.

The chapter contains what you expect. Validations, what directives we have regarding forms and how to work with them. It also has a outstanding explanation of how to use `ngModelController` which is a thing that a lot of people ignores and it is very very interesting.

Chapter 6, navigation around or application. It talks about the `$route` and `$location` services. The thing I like the most from this book is that they explain everything (yes I know, I am repeating myself) and I am the kind of guy that likes to do that. There is not a missing piece on this chapter. Want to  know how to configure `HTML5 mode`? They explain that to you but they also explains how to configure the server side to support that, I appreciate that on a book. Apart from this, explanations of how both services works and a bunch of tips and tricks. I missed some `ui-router` explanation which is on fire right now.

Securing our applications, that is what the chapter 7 is about. This is an important chapter because a bad security can be really problematic for our business. The chapter is divided in two parts. One of them explains the types of malicious attacks we can get and how to prevent them, the other parts explains how we can provide support to our security system in the client side. As everybody knows, Javascript is not secure, but that doesn't mean that we should skip the client side security. It provides the right experience for our end users. Pretty good chapters that explains how they implemented their security support using some advanced stuff that are pretty interesting.

Chapters 8 and 9, directives. They explain every... Alright, you know what I mean :P. Taking advantage of Pawel work on `ui-bootstrap` he explains a lot of things about directives and the best part of it? Always with tests, so you can write the tests yourself and then implement the directive to learn more. Directives are a complex beast but I promise that them did their best explaining all that involves directives. The chapter 9 is more about advanced stuff that is rarely found in the internet. My suggestion here is to dive into `ui-bootstrap` when you finish the chapter or just stay tunned for my upcoming articles about them :).

Chapter 10 is all about internationalization. I like the chapter because it also talks about the drawbacks that some of the current i18n solutions out there in the internet has. They just explain all the solutions we have and also the problems they have.

Chapter 11 is more than enough to buy this book, seriously. I thought that my explanation of how the data binding works is good, but their explanation is better than mine, I have to admit that. They also explain **A LOT** of tricks to keep our application fast. Everyone knows that angular could be a little bit problematic when we have a lot of watches but the real thing about this is that the 90% of the times the problem is our. Bad code tends to a bad performance. After you read this chapter, all of yours applications will be much faster.

Chapter 12 and the last chapter is like in other books reserved for final tricks and deployment. They explain what any decent workflow like [lineman](http://www.linemanjs.com) does for you, AKA minification safe code, `$templateCache`, etc.

### Conclusions

I thought that I gave my conclusions at the beginning of this review :P. This is an outstanding book, with an outstanding quality. One of the best book I have read in my entire career and the number is big enough.

Angular needed a book like this because I get a lot of questions everyday and I really think that this book address the 90% of them with a cheap price.

The bad part is that it doesn't cover Angular.js 1.2. Well, it has like 3-4 things (no more than that) which has been improved now but the book is still explains the 100% of things you need even if you start right away in 1.2.

**Good things**:

+ It covers everything (last time I say it, I promise :P) about Angular, good parts, bad parts, workarounds...
+ Awesome chapters about directives, this will end the excuse of: *There is no good docs about directives*.
+ The chapter about data-binding and how to improve the performance is a master piece.
+ Testing, there is a lot of tests in the book, I appreciate that.
+ Much of the examples has a live preview in *Plunker* so you can try them right away in your browser.

**Bad things**:

- As I said, there are little things that has been improved in the new version, but nothing problematic.
- I missed some stuff about `ui-router`

My final score is **9,7** because nothing is perfect and I haven't released a book yet! :P

Buy it [here](https://www.packtpub.com/angularjs-web-application-development/book)