---
layout: post
title: "Aenean posuere"
date: 2012-10-02 06:29
comments: true
categories:
---

## Aenean posuere

odio eget imperdiet ullamcorper, nulla libero auctor dui, at adipiscing tortor neque nec lacus. Donec [ac mi luctus](http://foo.com) nisi vestibulum scelerisque. Integer congue metus in nisi venenatis sit amet sagittis tortor sodales. Phasellus lobortis sollicitudin porttitor. Integer vel enim eu nunc laoreet pharetra eget nec nibh. Nam [orci quam](http://github.com), facilisis a accumsan vel, ultricies at felis. Nullam erat ipsum, tempor a viverra id, pulvinar non odio. Suspendisse eu turpis ligula, quis mattis dolor. Ut pellentesque mattis ipsum in ornare. Nullam non metus lacus. Vivamus sed euismod mi. Sed sed tellus dui, molestie dignissim turpis.

<!-- more -->

## Morbi tincidunt

urna eget volutpat vestibulum, est nunc eleifend diam, quis interdum quam erat nec risus. Etiam tincidunt cursus tortor, in aliquam orci interdum euismod. Curabitur nibh enim, fermentum eget placerat id

``` ruby
# Public: Makes a GET request to Mega API
#
# shop   - The Shop instance
# url    - The String which is the URL to query for
# params - The Hash of attributes to pass in to the query
#
# Examples
#
#   MegaApps::Interface.get(shop, '/foo', {bar: 'bar'})
#   # => {...}
#
# Returns the Hash
#
# Signature
#
#   <mtd>(args)
#
# mtd - Either of the get, post or put HTTP methods
%w(get put post).each do |mtd|
  define_method mtd do |shop, url, params={}|
    pre_setup
    Mega::Request.send(mtd, url, access_params(shop, params)).to_hash
  end
end
```

, rutrum ut urna. Morbi in odio nibh, vitae viverra tortor. Etiam sed massa elit. Integer non massa in urna accumsan adipiscing vitae sit amet ante. Vivamus urna metus, sollicitudin eu interdum ut, laoreet mattis tortor. Sed sed tortor nunc. In hac habitasse platea dictumst. Suspendisse vel quam mi, nec tristique orci.

``` ruby interface.rb http://coo.com sometext
# Public: Makes a GET request to Mega API
#
# shop   - The Shop instance
# url    - The String which is the URL to query for
# params - The Hash of attributes to pass in to the query
#
# Examples
#
#   MegaApps::Interface.get(shop, '/foo', {bar: 'bar'})
#   # => {...}
#
# Returns the Hash
#
# Signature
#
#   <mtd>(args)
#
# mtd - Either of the get, post or put HTTP methods
%w(get put post).each do |mtd|
  define_method mtd do |shop, url, params={}|
    pre_setup
    Mega::Request.send(mtd, url, access_params(shop, params)).to_hash
  end
end
```

## Fusce aliquam

{% gist 996818 %}

congue dictum. Nam dignissim eros commodo eros rutrum cursus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis posuere, est at dictum malesuada, urna lectus condimentum dui, sit amet aliquet risus velit sed dolor. Pellentesque laoreet nulla blandit lectus pulvinar laoreet. Maecenas lorem dolor, gravida ac vulputate eget, lacinia ut nunc. Sed consequat semper quam, quis sodales arcu congue a. Nullam ac urna elit. Ut vel elit diam, vel luctus nisi. Phasellus porta scelerisque nisi quis consequat. Integer a

{% pullquote %}
commodo dolor. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. {" Sed eget orci vel"} lectus vulputate ullamcorper quis quis orci. Morbi mollis sapien in tortor ullamcorper sit
{% endpullquote %}

 amet lacinia justo vulputate. Nam eget mauris elit, at lobortis tellus. Fusce ligula odio, mollis sit amet dignissim vitae, imperdiet et nisi.

## Vestibulum facilisis

accumsan fringilla. Proin justo magna, cursus sit amet suscipit eu, euismod in mi. Ut malesuada nisi nec turpis pretium dictum sit amet nec nisi. Proin in urna sapien. Quisque lobortis auctor nibh non aliquet. Donec bibendum cursus dolor, in hendrerit neque lacinia a. Mauris arcu ipsum, interdum sit amet sagittis in, rutrum consequat lorem. Aenean dictum odio et lacus molestie quis placerat nunc laoreet. Ut consectetur porttitor lacinia. Mauris hendrerit dui id erat vestibulum ut consectetur felis hendrerit. Duis enim ligula, ultricies non cursus sit amet, sollicitudin vel mauris. Cras tellus nulla, mollis quis rhoncus vitae, consectetur eu erat. Maecenas et diam nec mauris lacinia egestas condimentum ac lectus. Donec consectetur, diam congue volutpat volutpat, sem enim mollis dolor, quis tempus metus ipsum nec lacus.

## Duis consequat

pharetra nunc, quis fringilla orci semper ut. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum nunc est, pulvinar sed imperdiet scelerisque, fermentum eu dolor. Quisque vel mi nunc. Curabitur congue consectetur lacinia. Curabitur id dui tortor, et pretium lorem. Nullam metus mi, venenatis at gravida ut, consequat in risus. Cras tristique gravida magna, eget rhoncus nisl blandit vitae. Sed id tellus enim. Quisque sed orci nisi. Nunc id felis ullamcorper metus cursus tristique et non quam.
