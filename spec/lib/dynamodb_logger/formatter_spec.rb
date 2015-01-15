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
      message.values[0].should == test_string
    end

    it "should use a passed-in hash" do
      message = @formatter.message_to_hash test_hash

      message.should be_a(Hash)

      message.keys.length.should == 2

      message.keys.should include('dog')
      message.keys.should include('count')

      message['dog'].should == 'cat'

      message['count'].should == 1
    end

    it "should handle empty keys" do
      message = @formatter.message_to_hash test_hash.merge('' => '')

      message.should be_a(Hash)
    end

    it "should handle nil values" do
      message = @formatter.message_to_hash test_hash.merge('empty' => nil)

      message.should be_a(Hash)
    end

    it "should handle values that do not respond to empty" do
      message = @formatter.message_to_hash test_hash.merge('number' => 3)

      message.should be_a(Hash)
    end

    it "should handle empty values" do
      message = @formatter.message_to_hash test_hash.merge('empty' => '')

      message.should be_a(Hash)
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

      message[primary_key_name].should == primary_key
    end

    it "should set the message correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['message'].should == test_message
    end

    it "should set the timestamp correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['timestamp'].should == timestamp.to_f
    end

    it "should set the severity correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['severity'].should == severity
    end

    it "should set the pid correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['pid'].should == Process.pid
    end

    it "should set the server name correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['server_name'].should == Socket.gethostname
    end

    it "should set the progname correctly" do
      hash = @formatter.call severity, timestamp, progname, test_message
      hash['progname'].should be_nil

      hash = @formatter.call severity, timestamp, 'test', test_message
      hash['progname'].should == 'test'
    end
  end
end
