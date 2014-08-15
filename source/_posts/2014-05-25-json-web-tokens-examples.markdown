---
layout: post
title: "Json Web Tokens: Examples"
date: 2014-05-25 23:14
comments: true
categories: [authentication]
---

So you liked my article about [JWT](/blog/2014/05/json-web-tokens-introduction) and you want to see some examples right?

I have you covered with two basic but functional implementations of it both in `Sails` and `Rails` which you can adapt to you own framework of choice without hassle.
<!--more-->
## Sails implementation

First, I created a service to handle the `encode` / `decode` (this JWT implementation calls those methods `sign` and `verify` respectively), let's see it:

```javascript api/services/sailsTokenAuth.js
var jwt = require('jsonwebtoken');

module.exports.issueToken = function(payload) {
  var token = jwt.sign(payload, process.env.TOKEN_SECRET || "our biggest secret");
  return token;
};

module.exports.verifyToken = function(token, verified) {
  return jwt.verify(token, process.env.TOKEN_SECRET || "our biggest secret", {}, verified);
};
```

We export two functions, one that will issue a token and one that will verify it. Here you can see how we pass our payload and the secret key. I suggest you to use an `ENV` variable to hold our secret, much better than a simple string. Also, a large random string is much harder to crack.

For the decoding, we pass there our token, our secret, no options (for advanced usages of JWT) and a callback that will be fired when the verifying is done.

Good, let's see our `AuthController`:

First the `authenticate` method:

```javascript api/controllers/AuthController.js
authenticate: function(req, res) {
  var email = req.param('email');
  var password = req.param('password');

  if (!email || !password) {
    return res.json(401, {err: 'email and password required'});
  }

  User.findOneByEmail(email, function(err, user) {
    if (!user) {
      return res.json(401, {err: 'invalid email or password'});
    }

    User.validPassword(password, user, function(err, valid) {
      if (err) {
        return res.json(403, {err: 'forbidden'});
      }

      if (!valid) {
        return res.json(401, {err: 'invalid email or password'});
      } else {
        res.json({user: user, token: sailsTokenAuth.issueToken(user.id)});
      }
    });
  })
}
```

We check that we passed credentials, then we find our user and we call a custom `validPassword` function (not interesting for this article but you can check it on the demo) to see if our user / pass combination is correct. So if our credentials are valid, we issue a token using our `user.id` as a payload and we also pass the complete user on the json (so `angular` can have it without hassle).

So: We send our credentials > we check its validity and if they are ok > we receive our user and a token via json.

Nothing fancy right? No special session stuff or code, just a normal function that returns a token.

The register method is not fancy either:

```javascript api/controllers/AuthController.js
register: function(req, res) {
  //TODO: Do some validation on the input
  if (req.body.password !== req.body.confirmPassword) {
    return res.json(401, {err: 'Password doesn\'t match'});
  }

  User.create({email: req.body.email, password: req.body.password}).exec(function(err, user) {
    if (err) {
      res.json(err.status, {err: err});
      return;
    }
    if (user) {
      res.json({user: user, token: sailsTokenAuth.issueToken(user.id)});
    }
  });
}
```

We just create a user with those new credentials and if they are valid, we issue a token like we did on the `authenticate` method. We do that so the user doesn't need to login by hand after registering.

So, how we manage incoming requests? Sails has a concept called `Policies` which are basically middlewares that runs before a controller. There we can check for our token, let's see:

```javascript api/policies/tokenAuth.js
module.exports = function(req, res, next) {
  var token;

  if (req.headers && req.headers.authorization) {
    var parts = req.headers.authorization.split(' ');
    if (parts.length == 2) {
      var scheme = parts[0],
        credentials = parts[1];

      if (/^Bearer$/i.test(scheme)) {
        token = credentials;
      }
    } else {
      return res.json(401, {err: 'Format is Authorization: Bearer [token]'});
    }
  } else if (req.param('token')) {
    token = req.param('token');
    // We delete the token from param to not mess with blueprints
    delete req.query.token;
  } else {
    return res.json(401, {err: 'No Authorization header was found'});
  }

  sailsTokenAuth.verifyToken(token, function(err, token) {
    if (err) return res.json(401, {err: 'The token is not valid'});

    req.token = token;

    next();
  });
};
```

First we check if we have the token on the header which basically is a header called `authorization` with the content `Bearer token_string`. If we have this kind of header we store the `token_string` part. If there is no header, we also check if we have it on the query string like: `/api/foo?token=token_string`.

When we finally have the token, we just verify it, extract its payload and assign it to `req.token` so we can access it from a controller. If there is no token, we just send an error json.

Now that we have our token verified and saved on the request object, we could do stuff like (this is not in the demo because `Sails` generates a virtual REST for you):

```javascript
index: function(req, res) {
  User.findOne(req.token).exec(function(err, message) {
    // Work with the user here
  });
};
```

Since our token is just our user id, we can use it to query it when needed.

There is nothing more to add. Surprised? We just needed a simple library to manage the encoding/decoding of the token and just issue it when we register or login and check for its existence before each request.

## Rails implementation

You will be surprised to see that this implementation is almost the same (if we ignore my Rails ignorance this days). I created a lib for the encoding/decoding:

```ruby lib/auth_token.rb
module AuthToken
  def AuthToken.issue_token(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def AuthToken.valid?(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base)
    rescue
      false
    end
  end
end
```

Basically it does the same as the sails one. The secret we are using here is the one that comes with the rails instalation. We can use what we want, I just took the advantage of having a good one already created.

So for the `AuthController`, let's begin with register:

```ruby app/controllers/auth_controller.rb
def register
  user = User.new(user_params)
  if user.save
    token = AuthToken.issue_token({ user_id: user.id })
    render json: { user: user,
                   token: token }
  else
    render json: { errors: user.errors }
  end
end
```

We create an user and if all is correct, we issue a new token which we will return with our user via json.

For the authenticate method:

```ruby app/controllers/auth_controller.rb
def authenticate
  user = User.find_by(email: params[:email].downcase)
  if user && user.authenticate(params[:password])
    token = AuthToken.issue_token({ user_id: user.id })
    render json: { user: user,
                   token: token }
  else
    render json: { error: "Invalid email/password combination" }, status: :unauthorized
  end
end
```

No surprises here. If the credentials are valid, we issue the token and return it via json with our user.

How do we manage the request here? I created a base controller for all the API controllers (which I assume that all of them needs authentication) and there I created a method like:

```ruby app/controllers/api/base_controller.rb
before_action :authenticate

def authenticate
  begin
    token = request.headers['Authorization'].split(' ').last
    payload, header = AuthToken.valid?(token)
    @current_user = User.find_by(id: payload['user_id'])
  rescue
    render json: { error: 'Authorization header not valid'}, status: :unauthorized
  end
end
```

To be honest, my `Sails` implementation is far more complete, and we can certainly do all those checkings here, but for the demo I was simple. We split the header, we get the token and we verify it. If it is valid, we create our `@current_user` based on the payload we had on the token. We could just store the id as we did in `Sails` but I decided to always have our user ready too show you that all of this implementation is really flexible.

And that is all! We don't need anything else. Of course we assume we have a `User` model with some password digest system like `has_secure_password` but that is really up to you. You can issue a token when you want to but the most common way is the login/pass. Nothing stops you of writing valid tokens on paper and give them away on the street like propaganda.

## Angular consumption

Well, how we decide to work with the token on angular is really personal and I won't lie, this is the first time I do auth on angular but I am quite happy with my approach.

I decided to store the token on the local storage, so I don't need to login everytime I enter the page, but that is based on your personal use case.

Let's see the auth service:

```javascript
app.factory('Auth', function($http, LocalService, AccessLevels) {
  return {
    authorize: function(access) {
      if (access === AccessLevels.user) {
        return this.isAuthenticated();
      } else {
        return true;
      }
    },
    isAuthenticated: function() {
      return LocalService.get('auth_token');
    },
    login: function(credentials) {
      var login = $http.post('/auth/authenticate', credentials);
      login.success(function(result) {
        LocalService.set('auth_token', JSON.stringify(result));
      });
      return login;
    },
    logout: function() {
      // The backend doesn't care about logouts, delete the token and you're good to go.
      LocalService.unset('auth_token');
    },
    register: function(formData) {
      LocalService.unset('auth_token');
      var register = $http.post('/auth/register', formData);
      register.success(function(result) {
        LocalService.set('auth_token', JSON.stringify(result));
      });
      return register;
    }
  };
});
```

For the login, we make a post with our credentials and if it succeds, we store the token (and also the user, I got lazy here) into the localstorage. For the registering, we remove the token if any and well, same thing as login.

To see if we are authenticated I decided to check for the token existence. Since the backend doens't know about logins, having the token means that we can query our stuff so if the token exist, we are "logged in". Of course the server can reject it on the next request if the user no longer exist, it expired or we used the "rotate tokens" technique.

Look how the logout works! We just need to delete the token because as I said, the backend is not concerned about logins as there is no sessions or stuff like that.

The authorize method is a helper method I use to check if a user is authenticated or not before I enter a route (more on this later).

I also created a `AuthInterceptor` to handle the request/response:

```javascript
app.factory('AuthInterceptor', function($q, $injector) {
  return {
    request: function(config) {
      var LocalService = $injector.get('LocalService');
      var token;
      if (LocalService.get('auth_token')) {
        token = angular.fromJson(LocalService.get('auth_token')).token;
      }
      if (token) {
        config.headers.Authorization = 'Bearer ' + token;
      }
      return config;
    },
    responseError: function(response) {
      if (response.status === 401 || response.status === 403) {
        LocalService.unset('auth_token');
        $injector.get('$state').go('anon.login');
      }
      return $q.reject(response);
    }
  };
});
```

If there is a token saved, put it on a header so every request we make, will have it (just what we need!). For the response, if we get a 401 or 403, redirect me to login and delete the token if any.

The routes are like:

```javascript
app.config(function($stateProvider, $urlRouterProvider, AccessLevels) {

  $stateProvider
    .state('anon', {
      abstract: true,
      template: '<ui-view/>',
      data: {
        access: AccessLevels.anon
      }
    })
    .state('anon.home', {
      url: '/',
      templateUrl: 'home.html'
    })
    .state('anon.login', {
      url: '/login',
      templateUrl: 'auth/login.html',
      controller: 'LoginController'
    })
    .state('anon.register', {
      url: '/register',
      templateUrl: 'auth/register.html',
      controller: 'RegisterController'
    });

  $stateProvider
    .state('user', {
      abstract: true,
      template: '<ui-view/>',
      data: {
        access: AccessLevels.user
      }
    })
    .state('user.messages', {
      url: '/messages',
      templateUrl: 'user/messages.html',
      controller: 'MessagesController'
    });

  $urlRouterProvider.otherwise('/');
  });
```

We have a parent state for anonymous routes and a parent state for authenticated users. The important part here is that we have an access data there to give a nice UX on our page.

To handle the routes I do:

```javascript
app.run(function($rootScope, $state, Auth) {
  $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
    if (!Auth.authorize(toState.data.access)) {
      event.preventDefault();

      $state.go('anon.login');
    }
  });
```

If we are not authorized to enter the page (using the access data we put on the routes) we redirect to login. Here I use the method I have on the `Auth` service to basically check if the user is authenticated for the user routes. We can expand this implementation to put more roles like an admin one.

And that is it! Since the token goes via header, we can query our backend as we normally do. There is no need to do something extra.

## Live demo

I have a live demo [here](http://quiet-inlet-7398.herokuapp.com/). You can login with `user@example.com / 123123` or create your own user. About if the live demo is sails or rails... I forgot, they behave the same :)

## Demos

[Sails demo](https://github.com/Foxandxss/sails-angular-jwt-example)
[Rails demo](https://github.com/Foxandxss/rails-angular-jwt-example)