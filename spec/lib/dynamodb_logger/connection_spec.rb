require 'dynamodb_logger'

describe DynamodbLogger::Connection do
  describe '::open' do
    let(:api_key) {'test_api_key'}
    let(:api_secret) {'test_api_secret'}
    let(:table_name) {'test_table_name'}

    before(:each) do
      @connection = DynamodbLogger::Connection.open(api_key, api_secret, table_name)
    end

    it "should create a new connection object" do
      @connection.should be_a(DynamodbLogger::Connection)
    end

    it "should initialize the api key" do
      DynamodbLogger::Connection.aws_access_key_id.should == api_key
    end

    it "should initialize the api secret" do
      DynamodbLogger::Connection.aws_secret_access_key.should == api_secret
    end

    it "should initialize the table name" do
      DynamodbLogger::Connection.table_name.should == table_name
    end

  end

  describe "#new" do
    it "should not be accessible externally" do
      expect {DynamodbLogger::Connection.new}.to raise_error
    end
  end

  describe "#close" do
    it "shouldn't fail" do
      connection = DynamodbLogger::Connection.send(:new)

      lambda {connection.close}.should_not raise_error
    end
  end

  describe "#write" do
    let(:test_message) {"test message"}
    let(:table_name) {"table name"}

    before(:each) do
      @connection = DynamodbLogger::Connection.send(:new)
      @raw_connection = mock(Fog::AWS::DynamoDB)
      DynamodbLogger::Connection.table_name = table_name
    end

    it "should attempt to make a connection" do
      @raw_connection.stub!(:put_item)
      @connection.should_receive(:raw_connection).and_return(@raw_connection)

      @connection.write(test_message)
    end

    it "should put_item to the connection" do
      @connection.should_receive(:raw_connection).and_return(@raw_connection)
      @raw_connection.should_receive(:put_item).exactly(:once).with(table_name, test_message)
      @connection.write(test_message)
    end
  end
end
