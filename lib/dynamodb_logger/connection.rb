module DynamodbLogger
  class Connection
    class << self
      attr_accessor :aws_access_key_id, :aws_secret_access_key, :table_name

      def open(aws_access_key_id, aws_secret_access_key, table_name)
        @aws_access_key_id = aws_access_key_id
        @aws_secret_access_key = aws_secret_access_key
        @table_name = table_name
      end
    end

    #it is assumed that the message is a hash
    #preformatted by the DynamodbLogger::Formatter class
    def write(message)
      raw_connection.put_item self.class.table_name, message
    end

    def close
      #does nothing for now, but is needed for compatibility with IO
    end

    protected
    def raw_connection
      Fog::AWS::DynamoDB.new(
        :aws_access_key_id => self.class.aws_access_key_id,
        :aws_secret_access_key => self.class.aws_secret_access_key
      )
    end
  end
end
