+++
description = ""
title = "Json web tokens: introduction"
date = "2014-05-25T13:23:21+01:00"
categories = []
tags = ["authentication"]

+++

Even when is not directly related to `Angular`, we need to fight with authentication from time to time. So let me explain what's is this `JWT` (pronounced `jot`) which everybody is talking about.

I spent the last few weeks researching about auth methods so bear with me if I make a mistake and send a PR to amend it :P
<!--more-->
## How we used to do authentication

As we know, the HTTP protocol is *stateless* that means that it can't remember us so if we login once, on the next request it already forgot who we are. Imagine having to log in on every request... that is a pain.

What is/was the solution? A session. A session is basically composed from two parts. An object that resides on the server, like a box, and a cookie on the client's browser, like a key. When you enter on a page for the first time, it will create a session object on the server and a cookie that will be installed on your browser. With that, the web app can remember us and track what we do. For example: On a book store, it can remember what books we put on the shopping cart, so when we enter the page again, the browser sends the cookie, the web will load our session and then our items will be still there.

When we log in, we find the requested user on the database and we can store it on the session, so on the next requests, the page won't need to ask for our credentials again.

By default, when we close the browser, the cookie gets deleted, so we would need to log in again the next time we visit that page. We can modify that behavior changing the cookie expire time to some date on the future (as opposed to session cookies which are the ones that gets deleted when we close the browser). Doing that, the page will remember us even if we reboot our computer.

Alright, I like what I read, what's the problem? Well, the web is not what used to be, we now have mobiles and stuff like that and the session auth is not the best option anymore (but still an option!).

To say a few problems...

* **Sessions**: We need to store our sessions somewhere. By default they are just stored on server's memory and having thousand of them doesn't help. Redis does help but without sessions there are no problems then :P
* **Mobile**: Native mobile apps seems to have problems working with cookies so if we need to query a remote API, maybe session auth is not the best solution.
* **CSRF**: If we go down the cookies way, you really need to do `CSRF` to avoid cross site requests. That is something we can forget when using JWT as you will see.
* **CORS**: Have you fight with CORS and cookies? I hope it went right because when it doesn't, we have a problem.

There are a couple more (check the link at the bottom) but that is enough for now :P.

## Json Web Tokens, a simile

So as you guessed, JWT doesn't use sessions, has no problems with mobile, it doesn't need `CSRF` and it works like a charm with `CORS`. But how does it work? I have a lot of questions...

I have a good simile to explain JWT:

Imagine a hotel. You browse the web and you see a good offer so you fill a form and you **register** yourself. The day come, you go to the hotel's desk and you give your **credentials**. The employee gives you a card. What can you do with the card? In that concrete hotel, you can access your room, the garage, or even to go to the hotel's restaurant.

Having this in mind, we know some facts: We can go into our room but we can't use our card to go into other room. Who has the card? The hotel? No, we have. When we leave, if we don't return the card, we will have a useless piece of plastic.

Let's translate that into JWT:

Imagine a web app. You browse it and you decide you want to **register** yourself. Then you put your **credentials** on a login form. The web page will send you a token via JSON. What can you do with that token? In that concrete app, you can access your user profile, your messages or even add new friends.

The same fact applies: You can access your profile but not others profiles (Imagining they are private) and you can't certainly remove friends from your partner account :P

## How JWT works

Now that we have an idea of how JWT works, let's see it from a more technique perspective.

A JWToken is self-contained, so when we create one, it will have all the necessary pieces needed inside of it. What are those pieces? A token is divided in 3 parts:

* A header
* A payload
* A signature

The header normally contains two things: The type of the token and the algorithm name (more on the algorithm later). Something like: `{typ: 'JWT', alg: 'HS256'}`. This gets encoded into base64.

The payload is the information you want to pass into it, some examples are: `{user: 2}` or even `{user: 2, admin: true}`. This gets encoded into base64.

For the signature, we get our encoded header, encoded payload, a secret key that we provide, the algorithm (the one we have on the header) and we sign that.

At the end of the day a token is something like: `xxxxxxxxxxx.yyyy.zzzzzzzzzzzz`. Where the `x` is the encoded header, the `y` is the encoded payload and the `z` is the signature.

So on `Angular` we can decode the `yyyy` part (the payload) if we need.

So back to our example. When we login in our page, we will get the token and with that token, we can do any request we want to the server just by giving it our token (normally, on the header). Good, but how can we work with it back on the server? Because if we don't have a session to remember the user and we are not storing that token on our database, how can we identify the user?

When we do a request, we send the token back to the server. There we decode it (the library would do it for you actually) which decodes the payload and also the header to see the type and the algorithm used. With that it will verify it with the signature and if all is correct, it will return the payload. Since we stored there our `user_id`, we can query our database for our user if we need to.

So the flow is: I login > I get a token > I request my messages with my token > The token gets decoded > and with my user_id on the hand I query for all my messages which are returned back to angular via json.

I see, but if the backend is using our payload to identify us... What if I tamper it with another `user_id` or even better with an admin flag? Ha! That won't work. The signature of the token is composed of the original header and payload, so any alteration invalidates the token. The only way to tamper a token is having the secret we used to sign it, but we are not going to publish that, are we? :)

There is also something important for advanced usages. If our library allows it (the node one does, but the ruby one doesn't for now) we can set an expiry date (which will be saved in the payload) so we can force a token to be re-issued with a new expiry date. That is handy if we want to force a user to re-logging every X days.

## The conclusion

Now that we know how it works, let's see... What are the advantages? We have no session to manage and we don't need `CSRF` because if you don't have the token, you can't do anything.

On the other hand... Where do we store this token? Not on the server of course, where does the hotel's card get stored? On the client pocket, AKA in our session storage or local storage (depending if you want to force a login the next time the user opens the browser or not). We could even share our token with a friend if we want them to be able to login in our page without giving them our credentials.

There is something to have in mind thought. Having the pair `< header - payload >` the resulting token will be the same. That means that no matter how many times you log in, the token will be the same. Worry not, if you need more security, you can use a different secret per user and rotate it upon login.

We can see how this approach is different. We used to store some state on our server about us but with JWT, the concept of login / register / logout is less rigid. It is just a way to receive a token. In fact, there is no need to create a logout endpoint, we just need to delete the token from our browser.

I know that you are now thinking of how could you implement all of this in your own backends, but I have you covered. On the next article I will show you two different backends (Rails and Sails) and one angular approach to handle it.

Ah, before I forget. It is really important to use SSL with this approach because the token will be sent on every request!

You can read more about JWT [here](https://auth0.com/blog/2014/01/07/angularjs-authentication-with-cookies-vs-token/)

Also, many thanks to mt friend [robdubya](https://github.com/robwormald) for his infinite patience on my JWT learning.
