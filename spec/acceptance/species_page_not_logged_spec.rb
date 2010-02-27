require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Species page without login" do

  it "should show featured taxa when it is clicked from home page" do
    page.open "/"
    #should have login
    page.text("xpath=//a[@href='/login']").should == 'login'
    page.click("//table[@id='featured-species-table'][1]//a[starts-with(@href, '/pages')]", :wait_for => :page)
    dom = Nokogiri.HTML(page.get_html_source)
    #it should show Random Taxa in lower-right.
    page.title.should match(/- Encyclopedia of Life/)
    page.body_text.should match(/explore/i)
    dom.xpath("//table[@id='related-species-table']//img").size.should == 5 
    #it should show "Species recognized by" in header.
    page.text("xpath=//div[@id='page-title']").should match(/Species recognized by/)
    #it should show Scientific Name as H1, Common Name as H2. TODO: Can we check them interactively?
    dom.xpath("//div[@id='page-title']//h1").first.text.strip.should_not == ''
    dom.xpath("//div[@id='page-title']//h2").first.text.strip.should_not == ''
    #it should show IUCN status
    page.text("xpath=//span[@class='iucn-status']").should match(/IUCN Red List Status:/i)
    page.text("xpath=//span[@class='iucn-status-value']").strip.should_not == ""
  end

  it "should show IUCN status 'vulnerable' for cheetah's page" do
    page.open Conf.cheetah_page
    page.text("xpath=//span[@class='iucn-status-value']").should match(/vulnerable/i)
  end



end
