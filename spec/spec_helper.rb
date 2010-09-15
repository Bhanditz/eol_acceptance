require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "boot"))
require "selenium/client"
require "selenium/rspec/spec_helper"
require "selenium/rspec/reporting/selenium_test_report_formatter"

Spec::Runner.configure do |config|
 
  config.prepend_before(:each) do
    create_selenium_driver
    start_new_browser_session
  end
 
  config.append_after(:each) do
    begin
      selenium_driver.stop
    rescue Exception => e
      STDERR.puts "Could not properly close selenium session : #{e.inspect}"
    end
  end
 
  def create_selenium_driver
    @selenium_driver = Selenium::Client::Driver.new \
      :host => Conf.host, 
      :port => 4444, 
      :browser => Conf.browser, 
      :url => Conf.url,
      :timeout_in_second => 60
    def @selenium_driver.dom(options = {})
      return @page_dom = Nokogiri::HTML(self.get_html_source) if options[:reload]
      @page_dom ||= Nokogiri::HTML(self.get_html_source)
    end
  end
  
  def start_new_browser_session
    selenium_driver.start_new_browser_session
    selenium_driver.set_context "Starting example '#{self.description}'"
  end
 
  def selenium_driver
    @selenium_driver
  end
  alias :page :selenium_driver
  
  def get_dom(open_page)
    open_page.dom(:reload => true)
    Nokogiri.HTML(open_page.get_html_source)
  end

end

