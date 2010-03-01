require 'rubygems'
require 'nokogiri'
require 'pp'
require 'yaml'
require 'set'
require 'ruby-debug'
class Conf
  @data = YAML.load(open(File.join(File.dirname(__FILE__), "config.yml")).read)
  @data.merge!(YAML.load(open(File.join(File.dirname(__FILE__), "config_private.yml")).read))
  def self.method_missing(method, *args, &block)
    @data[method.to_s]
  end
  def self.data
    @data
  end
end
