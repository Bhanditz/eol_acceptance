require 'rubygems'
require 'nokogiri'
require 'pp'
require 'yaml'
class Conf
  @data = YAML.load(open(File.join(File.dirname(__FILE__), "config.yml")).read)
  def self.method_missing(method, *args, &block)
    @data[method.to_s]
  end
  def self.data
    @data
  end
end
