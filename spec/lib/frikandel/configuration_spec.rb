require "rails_helper"

RSpec.describe Frikandel::Configuration do

  it "is a singleton" do
    expect(Frikandel::Configuration).to respond_to :instance
    expect(Frikandel::Configuration.instance).to be_a Frikandel::Configuration
    expect(Frikandel::Configuration.instance).to be_equal Frikandel::Configuration.instance
  end

  it "delegates max_ttl and max_ttl= to the singleton instance" do
    expect(Frikandel::Configuration.instance).to receive(:max_ttl).and_return(:some_max_ttl)
    expect(Frikandel::Configuration.instance).to receive(:max_ttl=).with(:some_value).and_return(:some_max_ttl=)

    expect(Frikandel::Configuration.max_ttl).to eq :some_max_ttl
    expect(Frikandel::Configuration.send(:max_ttl=, :some_value)).to eq :some_max_ttl=
  end

  it "delegates ttl and ttl= to the singleton instance" do
    expect(Frikandel::Configuration.instance).to receive(:ttl).and_return(:some_ttl)
    expect(Frikandel::Configuration.instance).to receive(:ttl=).with(:some_value).and_return(:some_ttl=)

    expect(Frikandel::Configuration.ttl).to eq :some_ttl
    expect(Frikandel::Configuration.send(:ttl=, :some_value)).to eq :some_ttl=
  end

  it "has 24 hours as default-max_ttl" do
    expect(Frikandel::Configuration.max_ttl).to eq 24.hours
  end

  it "has 2 hours as default-ttl" do
    expect(Frikandel::Configuration.ttl).to eq 2.hours
  end

  it "ttls can be set" do
    Frikandel::Configuration.max_ttl = 50.hours
    Frikandel::Configuration.ttl = 5.hours

    expect(Frikandel::Configuration.max_ttl).to eq 50.hours
    expect(Frikandel::Configuration.ttl).to eq 5.hours
  end

end
