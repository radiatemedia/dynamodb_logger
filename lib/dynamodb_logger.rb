#libraries
require "fog"

#internal requires
require "dynamodb_logger/version"
require "dynamodb_logger/formatter"
require "dynamodb_logger/configuration"

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
      connection = DynamodbLogger::Connection.open(config.aws_access_key_id, config.aws_secret_access_key, config.table_name)
      logger = Logger.new connection

      formatter = DynamodbLogger::Formatter.new
      formatter.primary_key_name = config.primary_key_name
      formatter.primary_key_type = config.primary_key_type
      formatter.primary_key_value = config.primary_key_value
      formatter.timestamp_name = config.timestamp_name
      formatter.server_name = config.server_name

      logger.formatter = formatter

      logger
    end
  end
end