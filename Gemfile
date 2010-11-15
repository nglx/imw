#!/usr/bin/env ruby
source :gemcutter
gem 'activesupport', '2.3.5', :require => 'active_support'
gem 'addressable', :require => 'addressable/uri'
gem 'uuidtools'
gem 'rake'

# The following Gems qre required for specific transport schemes and
# are not used by core IMW functions.
group :schemes do
  gem 'aws-s3', :require => 'aws/s3'
  gem 'dbi'
  gem 'rest-client', '>= 1.6.1', :require => 'restclient'
end

# The following Gems qre required for specific data formats and are
# not used by core IMW functions.
group :formats do
  gem 'fastercsv'
  gem 'hpricot'
  gem 'json'
  gem 'pdf-reader', :require => 'pdf/reader'
  gem 'spreadsheet'
end

group :test do
  gem "rspec", '1.3.0', :require => 'spec'
end
