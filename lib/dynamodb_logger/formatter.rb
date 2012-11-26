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
        next if key.empty?

        cleaned_value = case value
        when Numeric
          {'N' => value.to_s} #numeric
        when Array
          if value.all? {|v| Numeric === v}
            {'NS' => value.collect {|v| v.to_s}} #numeric set
          else
            {'SS' => value.collect {|v| v.to_s}.select {|v| !v.empty?}} #string set
          end
        else
          {'S' => value.to_s} #string
        end

        cleaned_hash[key] = cleaned_value unless cleaned_value.values[0].empty?

        cleaned_hash
      end
    end

    def call(severity, time, progname, msg)
      key = @primary_key_value.call.to_s
      message = message_to_hash(msg || progname)
      message[@primary_key_name] = {@primary_key_type || 'S' => key}
      message[@timestamp_name || 'timestamp'] = {'N' => time.to_f.to_s}
      message['severity'] ||= {'S' => severity.to_s}
      message['pid'] ||= {'N' => $$.to_s}
      message['server_name'] ||= {'S' => (@server_name || Socket::gethostname).to_s}
      message['progname'] ||= {'S' => progname.to_s} if progname
      message
    end
  end
end
