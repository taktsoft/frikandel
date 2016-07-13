require "rails_helper"

describe Frikandel::Configuration do

  it "is a singleton" do
    Frikandel::Configuration.should respond_to :instance
    Frikandel::Configuration.instance.should be_a Frikandel::Configuration
    Frikandel::Configuration.instance.should be_equal Frikandel::Configuration.instance
  end

  it "delegates max_ttl and max_ttl= to the singleton instance" do
    Frikandel::Configuration.instance.should_receive(:max_ttl).and_return(:some_max_ttl)
    Frikandel::Configuration.instance.should_receive(:max_ttl=).with(:some_value).and_return(:some_max_ttl=)

    Frikandel::Configuration.max_ttl.should eq :some_max_ttl
    Frikandel::Configuration.send(:max_ttl=, :some_value).should eq :some_max_ttl=
  end

  it "delegates ttl and ttl= to the singleton instance" do
    Frikandel::Configuration.instance.should_receive(:ttl).and_return(:some_ttl)
    Frikandel::Configuration.instance.should_receive(:ttl=).with(:some_value).and_return(:some_ttl=)

    Frikandel::Configuration.ttl.should eq :some_ttl
    Frikandel::Configuration.send(:ttl=, :some_value).should eq :some_ttl=
  end

  it "has 24 hours as default-max_ttl" do
    Frikandel::Configuration.max_ttl.should eq 24.hours
  end

  it "has 2 hours as default-ttl" do
    Frikandel::Configuration.ttl.should eq 2.hours
  end

  it "ttls can be set" do
    Frikandel::Configuration.max_ttl = 50.hours
    Frikandel::Configuration.ttl = 5.hours

    Frikandel::Configuration.max_ttl.should eq 50.hours
    Frikandel::Configuration.ttl.should eq 5.hours
  end

end
