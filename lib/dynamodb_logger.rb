#libraries
require "aws-sdk"

#internal requires
require "dynamodb_logger/version"
require "dynamodb_logger/formatter"
require "dynamodb_logger/configuration"
require "dynamodb_logger/connection"

module DynamodbLogger
  class << self
    def config
      @@config ||= DynamodbLogger::Configuration.new
    end

    def configure
      yield config
    end

    #returns a new logger object
    def logger
      connection = DynamodbLogger::Connection.open(config.aws_access_key_id, config.aws_secret_access_key, config.aws_region, config.table_name)
      logger = Logger.new connection

      formatter = DynamodbLogger::Formatter.new
      formatter.primary_key_name = config.primary_key_name
      formatter.primary_key_type = config.primary_key_type
      formatter.primary_key_value = config.primary_key_value
      formatter.timestamp_name = config.timestamp_name
      formatter.server_name = config.server_name

      raise ArgumentError.new("A primary key name is required to be configured") unless formatter.primary_key_name
      raise ArgumentError.new("A primary key value (as a Proc) is required to be configured") unless formatter.primary_key_value

      logger.formatter = formatter

      logger
    end
  end
end
