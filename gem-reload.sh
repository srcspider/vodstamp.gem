#!/usr/bin/env sh
rm vodstamp-0.*
echo
gem build vodstamp.gemspec
echo
gem install vodstamp-0.1.0.gem