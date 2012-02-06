# Sourcery

[Website](http://rubyworks.github.com/sourcery) /
[API](http://rubydoc.info/gems/sourcery) /
[Source](http://github.com/proutils/sourcery) /
[Forum](http://googlegroups.com/group/rubyworks-mailinglist)


## DESCRIPTION

Sourcery is a simple project-oriented eRuby-based template system
using POM metadata.


## FEATURES

* Easy to use.
* Used eRuby. Easy.
* Uses POM metadata. Easy.
* Templates go where the file goes. Easy.
* Did I mention it was easy?


## INSTRUCTION

Create an template file, such as README.sourcery.

In your Ruby project add a `src/`  directory, or if you have
a prexisting `lib` directory copy it to `src/` instead. From
now on only edit the files in `src/`, NEVER edit the `lib` files.

After editing `src/` files run:

  $ sourcery

All the `src` files will be rendered and saved to lib.


## INSTALLATION

To install with RubyGems simply open a console and type:

  $ gem install sourcery


## COPYRIGHT & LICENSE

Copyright (c) 2009 Rubyworks

This program is ditributable in accorance with the **BSD-2-Clause** license.

See COPYING.rdoc file for details.

