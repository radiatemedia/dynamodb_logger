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
        next if !value || (value.respond_to?(:empty?) && value.empty?)

        #the V2 AWS API handles the typing automatically
=begin
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
=end
        cleaned_hash[key] = value

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
