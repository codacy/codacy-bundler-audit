Checking insecure gem sources is essential once they can be harmful
and susceptible to attacks.

Https should be used:
  ´source 'https://rubygems.org'´
instead of http:
  ´source 'http://rubygems.org'´

Https should be used:
 ´gem 'rails', :git => 'https://github.com/rails/rails.git'´
 instead of ssh:
 ´gem 'rails', :git => 'git@github.com:rails/rails.git'´
