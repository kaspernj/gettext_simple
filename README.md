# GettextSimple

A very simple implementation of Gettext for Ruby.

# Install

Start by putting this in your Gemfile:
```ruby
gem 'gettext_simple'
```

This is how it could be initialized in Rails and take the locale from I18n.locale by placing this code in `"#{Rails.root}/config/initializers/gettext_simple.rb`:
```ruby
require "gettext_simple"
gettext_simple = GettextSimple.new(:i18n => true)
gettext_simple.load_dir("#{Rails.root}/locales_gettext")
gettext_simple.register_kernel_methods

puts _("Hello world")
```

Replacements are done this way:
```ruby
puts _("Hello %{name}", :name => "Kasper") #=> "Hello Kasper"
```

## Contributing to gettext_simple
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Kasper Johansen. See LICENSE.txt for
further details.

