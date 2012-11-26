require 'dynamodb_logger'

describe DynamodbLogger do
  describe '::configure' do
    DynamodbLogger::Configuration.members.each do |config_option|
      it "should allow #{config_option} to be configured" do
        DynamodbLogger.configure do |config|
          config.send("#{config_option}=", "testing #{config_option} value")
        end

        DynamodbLogger.config.send(config_option).should == "testing #{config_option} value"
      end
    end
  end

  describe '::logger' do
    it "should initialize properly" do
      mock_connection = mock DynamodbLogger::Connection
      mock_connection.stub!(:write) #to get respond_to? for Logger
      mock_connection.stub!(:close) # get respond_to? for Logger
      DynamodbLogger::Connection.should_receive(:open).exactly(:once).and_return(mock_connection)
      mock_formatter = mock DynamodbLogger::Formatter
      DynamodbLogger::Formatter.should_receive(:new).and_return mock_formatter
      [:primary_key_name=, :primary_key_type=, :primary_key_value=, :timestamp_name=, :server_name=].each do |config_option|
        mock_formatter.should_receive(config_option).exactly(:once)
      end

      logger = DynamodbLogger.logger

      logger.should be_a(Logger)
    end
  end
end
