# DynamodbLogger

Use this gem to easily use DynamoDB with a standard Ruby Logger object, without worrying about API complexity beneath.

## Installation

Add this line to your application's Gemfile:

    gem 'dynamodb_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamodb_logger

## Usage

#require the library
require 'dynamodb_logger'

#configure
DynamodbLogger.configure do |config|
  config.aws_access_key_id = AWS_ACCESS_KEY_ID
  config.aws_secret_access_key = AWS_SECRET_ACCESS_KEY
  config.aws_region = AWS_REGION
  config.table_name = TABLE_NAME
  config.primary_key_name = PRIMARY_KEY_COLUMN
  config.primary_key_type = 'N'

  #configure the primary key value with a proc,
  #which is useful in cases where it may only be known at runtime
  config.primary_key_value = Proc.new do
    #something from the current environment is fetched here
  end
end

#instantiate
your_object.logger = DynamodbLogger.logger.tap {|logger| logger.level = Logger::DEBUG}

#you are good to go!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
