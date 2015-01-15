require 'socket' #just to get the host name
require 'logger'

module DynamodbLogger
  class Formatter < Logger::Formatter

    attr_accessor :primary_key_name
    attr_accessor :primary_key_type
    attr_accessor :primary_key_value
    attr_accessor :timestamp_name
    attr_accessor :server_name

    def message_to_hash(message)
      (message.respond_to?(:merge) ? message : {'message' => message}).inject({}) do |cleaned_hash, item|
        key, value = item

        #make sure our key is valid
        key = key.to_s

        if !key.empty? && value && (!value.respond_to?(:empty?) || !value.empty?)
          cleaned_hash[key] = value
        end

        cleaned_hash
      end
    end

    def call(severity, time, progname, msg)
      key = @primary_key_value.call
      message = message_to_hash(msg || progname)
      message[@primary_key_name] = key
      message[@timestamp_name || 'timestamp'] = time.to_f
      message['severity'] ||= severity.to_s
      message['pid'] ||= $$
      message['server_name'] ||= (@server_name || Socket::gethostname).to_s
      message['progname'] ||= progname.to_s if progname
      message
    end
  end
end
