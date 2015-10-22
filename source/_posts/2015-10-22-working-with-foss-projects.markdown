---
layout: post
title: "Working with FOSS projects"
date: 2015-10-22 20:00
comments: true
categories: [Others]
---

So you found an issue on a FOSS (Free open source software) project, and you would like to send a PR. But how? That is a good question. Another question would be: I am running some small FOSS project and someone sent me a PR, what can I do with it now?

I am going to write about how we do FOSS at [ui-bootstrap](https://github.com/angular-ui/bootstrap). There are hundred of ways of working with FOSS projects, but I think that this way works like a charm. You can also use this "workflow" in private projects, but those are not that fun!
<!--more-->
### As a person that wants to collaborate

Hey, I saw this awesome [repo](https://github.com/angular-tips/FOSS-demo) but yikes, the guy left a big typo on that README:

{% blockquote %}
I will tech how to collab with open source projects and how to get collaborations.
{% endblockquote %}

I will **tech**? Ah, this guy doesn't know how to write. Let's me fix that. But how? You could certainly use the built-in editor in Github, but you probably should never use it (except for small things like typos, but let's pretend this is a huge bug in an app).

The first step is to fork the repo, for that, you click the `fork` button in the repository page.

{% img /images/posts/foss/1.png %}

Once you select where you want to fork the repo (normally in your account), the first step would be to clone it in your machine:

```
$ git clone https://github.com/yourhandle/FOSS-demo
$ cd FOSS-demo
```

The next step would be to add a "reference" to the main repo. With reference, I mean adding the original repo (called upstream) as a remote:

```
$ git remote add upstream https://github.com/angular-tips/FOSS-demo
```

The name of the `remote` is not important, but I like to call it `remote` so I know where it points to.

Now, memorize this bit: NEVER ever touch your master branch. As soon as you do any work on it, your fork and the upstream repo will be "out of sync". It doesn't matter if you want to work in master to create a PR which is going to be merged. You will be out of sync anyway.

What you have to do, is: Every time you want to create a PR, make sure that your fork is up to date with upstream, but How?:

```
$ git fetch upstream master
$ git merge upstream/master
$ git push origin master
```

First, we fetch the latest commits on upstream's master. Second, we merge those changes in our actual branch (which should be master) and last, we push those new changes to our fork in Github.

Now that we are "up to date", let's create a branch for our fix:

```
$ git checkout -b chore/readmetypo
```

The branch name is not important, but it should be something that helps you remember. I like the idea of naming the branches like type/description. Where type is (chore, fix, feat, refactor...). I stole this idea from my good friend [Wesley Cho](https://github.com/wesleycho).

**IMPORTANT**: Always create the new branch from master, never create it from another branch. Go back to master if you're in another branch, update your fork and then create a new branch.

Alright, now we just need to do the fix. We are going to change that `tech` into `teach you`. Once you fix it, you will always want to be sure that you didn't touch any other file or you're not going to commit anything weird (DS_Store, .idea folder, etc).

```
$ git status
```

{% img /images/posts/foss/2.png %}

Alright, just that one file. Let's stage it:

```
$ git add README.md
```

Now commit it (check also if the repository has some rules on commit messages):

```
$ git commit -m "chore: fix 'tech' typo on README"
```

And as the last step, we have to push it to our fork and branch, so in this case:

```
$ git push origin chore/readmetypo
```

{% img /images/posts/foss/3.png %}

Nice, now we just need to go to our fork repository or even the upstream repository and we will see:

{% img /images/posts/foss/4.png %}

If you click the green button, you will be prompted with a form where you can write the details.

{% img /images/posts/foss/5.png %}

Nice! All our hard work is now there, just waiting for someone on that team to revise it.

In another corner of the world, "Chloe", another reader of this blog, thinks that we should change "collab" into "collaborate". The repo owner haven't merged the other PR yet, so what "Chloe" sees is still the old version of the README.

She forks the repo, adds the upstream remote, updates her fork for new changes, if any, and creates a new branch:

```
$ git checkout -b chore/changecollab
```

Alright, she just changed that word (she saw that there is a PR already for the `tech` typo).

```
$ git commit -m "chore: change collab into collaborate"
$ git push origin chore/changecollab
```

She goes to the repo, creates the PR and...

{% img /images/posts/foss/6.png %}

**collaborte**?? Seriously? How can I fix that? Should I close this PR and create another one? No.

Go to the `chore/changecollab` branch if you are not there yet, and just fix your typo. Once the typo is fixed, stage the file again:

```
$ git add README.MD
```

And instead of creating a new commit, we are going to amend our previous one:

```
$ git commit --amend
```

You will end on an editor, but you just need to save and leave.

Now that we fixed our last commit, we have to push it back to our fork. Since it is already there, we need to **force** it:

```
$ git push -f origin chore/changecollab
```

**IMPORTANT**: You should never use **force** outside this context. Rewriting history on a repository is a sin.

If we go to the PR now...

{% img /images/posts/foss/7.png %}

Ha! Nobody saw.

### As the repo maintainer

Now let's change the perspective. Now we are the guy/gal behind this `FOSS-demo` project and yay, some nice people created a bunch of PRs. We open a PR, we review it and we decide that we like it and we want to merge it. What now?

{% img /images/posts/foss/8.png %}

That is what I call an appealing button! Let's click it.

{% img /images/posts/foss/9.png %}

Uh? Why two messages in history instead of just one? I don't like that. So that green button created a entry with the PR message and also one that says that a pull request was merged, bla bla bla.

Alright, we don't like that, and more importantly, we haven't even tested it on our machine! Let's do it properly.

First, we go to our pr, for example `https://github.com/angular-tips/FOSS-demo/pull/1`. The first thing we are going to do is change the url to `https://github.com/angular-tips/FOSS-demo/pull/1.patch` and click enter. Github will redirect us to a page with all the proposed changes on that PR. We copy that new link.

Now we navigate to our project and we make sure that our local copy is up to date:

```
$ cd /path/with/FOSS-demo
$ git pull
```

Now that we are in our repo and we are sure it is up to date, it is time to work with that patch. First, we create a new branch to test it out:

```
$ git checkout -b pr1
```

My convention is to call this new branch `pr` + the PR number.

Now, we apply the patch:

```
$ curl https://patch-diff.githubusercontent.com/raw/angular-tips/FOSS-demo/pull/1.patch | git am -3
```

What `git am -3` does is to apply a patch and maintain the original PR author (which is awesome).

{% img /images/posts/foss/10.png %}

Nice! Now is the time where we try the patch. If this were a `ui-bootstrap` patch, I would run grunt to generate the build, try it out, see that everything works as expected, that the tests are good...

Ok, we tested it and we like it. Now, if we want to auto close the PR when we merge it, we do:

```
$ git commit --amend
```

And we add to it: `Closes #1`

{% img /images/posts/foss/11.png %}

We save it. Now that we have the PR how we want it, it is time to merge it:

```
$ git checkout master
$ git merge pr1
$ git push origin master
$ git branch -D pr1
```

We move to master, we merge our `pr1` branch, we push the changes to the repo and optionally we delete the local branch.

Now in the PR, we can see that it is closed and:

{% img /images/posts/foss/12.png %}

Nice touch!

Also, if check the history:

{% img /images/posts/foss/13.png %}

Nice, just 1 message this time!

**NOTE:** In the case where the user who creates the PR and the user who merge it are different persons, you will see who created the PR and who merged it.

We had another PR, right? We open it and we see:

{% img /images/posts/foss/14.png %}

Uh, that doesn't sound good... Why is that happening? When this PR was created, it was created agains the _old_ README. Since we updated our README (thanks to some PRs), the changes on this PR cannot be applied automatically. Don't worry, it is easy to fix.

As before, let's create a new branch and apply the patch:

```
$ git checkout -b pr2
$ curl https://patch-diff.githubusercontent.com/raw/angular-tips/FOSS-demo/pull/2.patch | git am -3
```

But now we get:

{% img /images/posts/foss/15.png %}

Yay, that is a block of text.

The important bit in here is that `README.md` seems to have a conflict. If we open it in our editor...

{% img /images/posts/foss/16.png %}

This could be a bit confusing at first, but don't worry, I will explain it.

When a file gets some conflicts, you will see areas like that. The part inside **HEAD** is what we have NOW in our repo and the second part is what the PR wants to merge. It is our job in here to decide what to do. In this case, we want the new change (the `collaborate` part) but we also want to maintain the `teach you`, so we fix it by hand, remove all the <<<<< ==== >>>> stuff and we leave it like:

{% img /images/posts/foss/17.png %}

Fixed? Let's continue:

```
$ git add README.md
```

We stage the file we changed and:

```
$ git am --continue
```

{% img /images/posts/foss/18.png %}

Now, it is like always. We will update the commit so it auto closes the pr:

```
$ git commit --amend
```

And after we added the `Closes #2`, we just need to merge it to master and push it up:

```
$ git merge pr2
$ git push origin master
$ git branch -D pr2
```

Yay, we fixed a PR and we merged it. And the best part is that the original author is respected.

Now, if one of our lovely users decide to push more PRs, they just need to update their fork and work.

### Conclusions

This is just one way of working with FOSS, but after hundred of PRs, we like it and we still do it. There are other ways, so feel free to investigate and see which one you like the most.

There are also some advanced stuff, but I think this will get you going.

What? You don't know where to start? Let me recommend you [FOSS hackday](http://foss-hackday.github.io/) A monthly hack day where people meets to work in a certain project. Check it out!
