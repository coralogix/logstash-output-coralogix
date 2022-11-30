# Logstash Coralogix Output Plugin

## This repository is deprecated and will no longer be supported by Coralogix.
## If you are still using our plugin for some reason please contact support to convert to the [generic HTTP output solution](https://coralogix.com/docs/coralogix-logstash-integration/).


[![gem](https://img.shields.io/gem/v/logstash-output-coralogix.svg?logo=ruby&logoColor=red&style=flat)](https://rubygems.org/gems/logstash-output-coralogix/)
[![gem downloads](https://img.shields.io/gem/dt/logstash-output-coralogix.svg?style=flat)](https://rubygems.org/gems/logstash-output-coralogix/)
[![Github license](https://img.shields.io/github/license/coralogix/logstash-output-coralogix.svg?logo=github&style=flat)](https://github.com/coralogix/logstash-output-coralogix/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/coralogix/logstash-output-coralogix.svg?style=flat)](https://github.com/coralogix/logstash-output-coralogix/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/coralogix/logstash-output-coralogix.svg?style=flat)](https://github.com/coralogix/logstash-output-coralogix/pulls)
[![GitHub contributors](https://img.shields.io/github/contributors/coralogix/logstash-output-coralogix.svg?style=flat)](https://github.com/coralogix/logstash-output-coralogix/graphs/contributors)

Coralogix provides a seamless integration with Logstash, so you can send your logs from anywhere and parse them according to your needs.

## Table of contents

1. Prerequisites
2. Usage
3. Installation
4. Configuration

## Prerequisites

Have Logstash installed, for more information on how to install: https://www.elastic.co/guide/en/logstash/current/installing-logstash.html

## Usage

**Private Key** - A unique ID which represents your company, this Id will be sent to your mail once you register to Coralogix..

**Application Name** - The name of your main application, for example, a company named “SuperData” would probably insert the “SuperData” string parameter or if they want to debug their test environment they might insert the  “SuperData– Test”.

**SubSystem Name** - Your application probably has multiple subsystems, for example: Backend servers, Middleware, Frontend servers etc. in order to help you examine the data you need, inserting the subsystem parameter is vital.

## Installation

```bash
logstash-plugin install logstash-output-coralogix
```

If you are not sure where logstash-plugin is located, you can check here:

https://www.elastic.co/guide/en/logstash/current/dir-layout.html

## Configuration

### Common

Open your Logstash configuration file and add Coralogix output (You should configure input plugin depending on your needs, for more information regarding input plugins please refer to: https://www.elastic.co/guide/en/logstash/current/input-plugins.html).

```ruby
output {
    coralogix {
        config_params => {
            "PRIVATE_KEY" => "YOUR_PRIVATE_KEY"
            "APP_NAME" => "APP_NAME"
            "SUB_SYSTEM" => "SUB_NAME"
        }
        log_key_name => "message"
        timestamp_key_name => "@timestamp"
        severity_key_name => "severity"
        category_key_name => "category"
        is_json => true
    }
}
```

The first key (config_params) is mandatory while the others are optional.

### Application and subsystem name

In case your input stream is a JSON object, you can extract **APP_NAME** and/or **SUB_SYSTEM** from the JSON using the `$` sign. For example, in the below JSON, `$message.system` will extract *nginx* value.

```json
{
    "@timestamp": "2017 - 04 - 03 T18: 44: 28.591 Z",
    "@version": "1",
    "host": "test-host",
    "message": {
        "system": "nginx",
        "status": "OK",
        "msg": "Hello from Logstash"
    }
}
```

### Record content

In case your input stream is a JSON object and you don’t want to send the entire JSON, rather just a portion of it, you can write the value of the key you want to send in the `log_key_name`. By default, logstash will send whole record content.

For instance, in the above example, if you write `log_key_name` message then only the value of message key will be sent to Coralogix.

If you want to send the entire message then you can just delete this key.

### Timestamp

Coralogix automatically generates the timestamp based on the log arrival time. If you rather use your own timestamp, use the `timestamp_key_name` to specify your timestamp field, and it will be read from your log.

**Note:** We accepts only logs which are not older than `24 hours`.

### Category

This plugin puts everything in the category `CORALOGIX`. If you want to take control over which category is to be used, use the `category_key_name` to specify your category field.

### Severity

By default everything is sent as severity `DEBUG`. You can use a value in the incoming log entry to dictate which severity is to be used, use the `severity_key_name`. The valid log levels are:
 `debug`, `verbose`, `info`, `warning`, `error`, `critical`. Values other than this ends up as debug

### JSON support

In case your raw log message is a JSON object you should set `is_json` key to a **true** value, otherwise you can ignore it.

### Proxy support

This plugin supports sending data via proxy. Here is the example of the configuration:

```ruby
output {
    coralogix {
        ...
        # Proxy settings
        proxy => {
            host => "PROXY_ADDRESS"
            port => PROXY_PORT
            user => "PROXY_USER" # Optional
            password => "PROXY_PASSWORD" # Optional
        } 
    }
}
```
