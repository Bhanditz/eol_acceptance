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
  end

end
