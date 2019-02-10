# encoding: utf-8
require "json"
require "date"
require "logstash/outputs/base"
require "logstash/namespace"
require "centralized_ruby_logger"

DEFAULT_APP_NAME = "FAILED_APP_NAME"
DEFAULT_SUB_SYSTEM = "FAILED_SUB_SYSTEM_NAME"

class LogStash::Outputs::Coralogix < LogStash::Outputs::Base
  config_name "coralogix"
  concurrency :shared
  config :config_params, :validate => :hash, :required => true
  config :timestamp_key_name, :validate => :string, :required => false
  config :log_key_name, :validate => :string, :required => false
  config :is_json, :validate => :boolean, :required => false
  config :force_compression, :validate => :boolean, :required => false, :default => false
  config :debug, :validate => :boolean, :required => false, :default => false
  @configured = false

  public def register
    configure
  end

  public def multi_receive(events)
    events.each do |record|
      record = record.to_hash

      logger = get_logger(record)

      log_record = log_key_name != nil ? record.fetch(log_key_name, record) : record
      log_record = is_json ? log_record.to_json : log_record
      log_record = log_record.to_s.empty? ? record : log_record

      timestamp = record.fetch(timestamp_key_name, nil)
      if (timestamp.nil?)
        logger.debug log_record
      else
        begin
          float_timestamp = DateTime.parse(timestamp.to_s).to_time.to_f * 1000
          logger.debug log_record, nil, timestamp: float_timestamp
        rescue Exception => e
          logger.debug log_record
        end
      end
    end

    return 1
  end

  def version?
    begin
      Gem.loaded_specs['logstash-output-coralogix'].version.to_s
    rescue Exception => e
      return '1.0.0'
    end
  end

  # This method is called before starting.
  def configure
    begin
      @loggers = {}
      #If config parameters doesn't start with $ then we can configure Coralogix logger now.
      if !config_params["APP_NAME"].start_with?("$") && !config_params["SUB_SYSTEM"].start_with?("$")
        @logger = Coralogix::CoralogixLogger.new config_params["PRIVATE_KEY"], config_params["APP_NAME"], config_params["SUB_SYSTEM"], debug, "Logstash (#{version?})", force_compression
        @configured = true
      end
    rescue Exception => e
      $stderr.write "Failed to configure: #{e}"
    end
  end

  def extract record, key, default
    begin
      res = record
      return key unless key.start_with?("$")
      key[1..-1].split(".").each do |k|
        res = res.fetch(k, nil)
        return default if res == nil
      end
      return res
    rescue Exception => e
      return default
    end
  end


  def get_app_sub_name(record)
    app_name = extract(record, config_params["APP_NAME"], DEFAULT_APP_NAME)
    sub_name = extract(record, config_params["SUB_SYSTEM"], DEFAULT_SUB_SYSTEM)
    return app_name, sub_name
  end

  def get_logger(record)

    return @logger if @configured

    app_name, sub_name = get_app_sub_name(record)

    if !@loggers.key?("#{app_name}.#{sub_name}")
      @loggers["#{app_name}.#{sub_name}"] = Coralogix::CoralogixLogger.new config_params["PRIVATE_KEY"], app_name, sub_name, debug, "Logstash (#{version?})", force_compression
    end

    return @loggers["#{app_name}.#{sub_name}"]
  end

end
