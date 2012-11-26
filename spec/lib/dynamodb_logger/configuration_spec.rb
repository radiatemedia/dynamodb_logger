require 'dynamodb_logger'

describe DynamodbLogger::Configuration do
  it "should be properly loaded" do
    DynamodbLogger::Configuration.should be_a(Class)
  end
end
