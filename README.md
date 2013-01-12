= nas-extjs

A collection of utility classes that make integrating Sencha's ExtJS into rails easier.  I've written several projects now that use Extjs with Rails and this is my attempt to extract the common code out so they can all stay in sync as I add more capabilities.

Currently it includes:
 
 * Extensions to ActiveRecord::Base to allow models to identify associations and methods that can be safely included in requests
 * A controller with the basic REST methods intended to be coupled to a custom ExtJS proxy.  It also listens for several special parameters and will export associations, methods, and query scopes provided they've been white-listed by the model using the extensions mentioned above.
 * Generators to customize an ExtJS application with custom Proxy and Stores
 * A highly customized version of the Extjs model associations that, you know *actually work*
 * Quite a few ExtJS classes, check out the generators directory

This is not polished for any kind of release.  I'm only making it public so that it may help someone out to poke around in it.  If it does prove helpful to someone I may consider a proper release, so please let me know if you'd like that.

Good Luck!

== Copyright

Original files are Copyright (c) 2013 Nathan Stitt. See LICENSE.txt for
further details.

