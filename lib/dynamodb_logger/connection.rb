module DynamodbLogger
  class Connection
    DEFAULT_REGION = 'us-east-1'
    class << self
      attr_accessor :aws_access_key_id, :aws_secret_access_key, :aws_region, :table_name

      def open(aws_access_key_id, aws_secret_access_key, aws_region, table_name)
        @aws_access_key_id = aws_access_key_id
        @aws_secret_access_key = aws_secret_access_key
        @aws_region = aws_region || DEFAULT_REGION
        @table_name = table_name

        DynamodbLogger::Connection.new
      end

      #enforce use of ::open to create connections
      protected :new
    end

    #it is assumed that the message is a hash
    #preformatted by the DynamodbLogger::Formatter class
    def write(message)
      raw_connection.put_item(
        :table_name => self.class.table_name,
        :item => message
      )
    end

    def close
      #does nothing for now, but is needed for compatibility with IO
    end

    protected
    def raw_connection
      @connection ||= Aws::DynamoDB::Client.new(
        :access_key_id => self.class.aws_access_key_id,
        :secret_access_key => self.class.aws_secret_access_key,
        :region => self.class.aws_region || DEFAULT_REGION
      )
    end
  end
end
