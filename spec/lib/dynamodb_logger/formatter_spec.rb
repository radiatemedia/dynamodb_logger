require 'dynamodb_logger'

describe DynamodbLogger::Formatter do

  describe '#message_to_hash' do
    let(:primary_key) {1}
    let(:test_string) {'string'}
    let(:test_hash) {{:dog => 'cat', :count => 1}}

    before(:each) do
      @formatter = DynamodbLogger::Formatter.new
      @formatter.primary_key_name = 'business_id'
      @formatter.primary_key_value = Proc.new {primary_key}
    end

    it "should not fail on string messages" do
      lambda {@formatter.message_to_hash test_string}.should_not raise_error
    end

    it "should not fail on a hash" do
      lambda {@formatter.message_to_hash test_hash}.should_not raise_error
    end

    it "should convert string messages to a hash" do
      message = @formatter.message_to_hash test_string

      message.should be_a(Hash)

      message.keys.length.should == 1
      message.keys[0].should == 'message'
      message.values[0].keys[0].should == 'S'
      message.values[0].values[0].should == test_string
    end

    it "should use a passed-in hash" do
      message = @formatter.message_to_hash test_hash

      message.should be_a(Hash)

      message.keys.length.should == 2

      message.keys.should include('dog')
      message.keys.should include('count')

      message['dog'].keys.length.should == 1
      message['dog'].keys[0].should == 'S'
      message['dog'].values[0].should == 'cat'

      message['count'].keys.length.should == 1
      message['count'].keys[0].should == 'N'
      message['count'].values[0].should == '1'
    end

    it "should handle numeric types properly" do
      test_numbers_hash = {:one => 1, :two => 2.0}
      message = @formatter.message_to_hash test_numbers_hash
      test_numbers_hash.each do |key, value|
        subhash = message[key.to_s]
        subhash.keys.length.should == 1
        subhash.keys[0].should == 'N'
        subhash.values[0].should == value.to_s
      end
    end

    it "it should handle numeric sets" do
      sample_hash = {:test => [1,2,3,4,5]}
      message = @formatter.message_to_hash sample_hash
      message.values[0].keys[0].should == 'NS'
      message.values[0].values[0].should be_a(Array)
    end

    it "it should treat mixed sets as strings" do
      sample_hash = {:test => [1,2,3,4,5,'six']}
      message = @formatter.message_to_hash sample_hash
      message.values[0].keys[0].should == 'SS'
      message.values[0].values[0].should be_a(Array)
    end
  end

  describe '#call' do
    let(:primary_key) {1}
    let(:primary_key_name) {'business_id'}
    let(:test_message) {'string'}
    let(:severity) {'DEBUG'}
    let(:timestamp) {Time.now}
    let(:progname) {nil}

    before(:each) do
      @formatter = DynamodbLogger::Formatter.new
      @formatter.primary_key_name = primary_key_name
      @formatter.primary_key_value = Proc.new {primary_key}
    end

    it "should assign the primary key correctly" do
      message = @formatter.call severity, timestamp, progname, test_message

      message[primary_key_name].values[0].should == primary_key.to_s
    end

    it "should set the message correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['message'].values[0].should == test_message
    end

    it "should set the timestamp correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['timestamp'].values[0].should == timestamp.to_f.to_s
    end

    it "should set the severity correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['severity'].values[0].should == severity
    end

    it "should set the pid correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['pid'].values[0].should == Process.pid.to_s
    end

    it "should set the server name correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['server_name'].values[0].should == Socket.gethostname
    end

    it "should set the progname correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['progname'].should be_nil

      hash = @formatter.call severity, timestamp, 'test', test_message
      hash['progname'].values[0].should == 'test'
    end
  end
end
