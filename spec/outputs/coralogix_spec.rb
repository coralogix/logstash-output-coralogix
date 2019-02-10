# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/coralogix_logger"
require "logstash/codecs/plain"
require "logstash/event"

file = "samples/logstash.conf"
@@configuration = String.new
@@configuration << File.read(file)


describe LogStash::Outputs::Coralogix do
  let(:config) {{'config_params' => {"PRIVATE_KEY" => "9626c7dd-8174-5015-a3fe-5572e042b6d9", "APP_NAME" => "Logstash Tester", "SUB_SYSTEM" => "Logstash subsystem"}}}
  let(:output) {LogStash::Outputs::Coralogix.new config}

  before do
    output.register
  end

  describe "Send message" do
    records = []
    records << {"message" => "Hello from Logstash"}
    subject {output.multi_receive(records)}

    it "returns 1" do
      expect(subject).to eq(1)
    end
  end
end
