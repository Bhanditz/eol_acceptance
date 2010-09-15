require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

def get_top_images(page) 
  dom = Nokogiri.HTML(page.get_html_source)
  dom.xpath("//table[@id='top-photos-table']//img[contains(@src, '_medium.jpg')]").map {|img| img.attr(:src)}.join(" ")
end

def top_images_diff(page)
  img1 = get_top_images(page)
  sleep(25)
  img2 = get_top_images(page)
  [img1, img2]
end

describe "Home page without login" do

  it "should show home page" do
    page.open "/"
    page.title.should == "Encyclopedia of Life"
    #should have login
    page.text("xpath=//a[@href='/login']").should == 'login'
    #should have 'create an account'
    page.text("xpath=//a[@href='/register']").should == 'create an account'
    #Verify that "EOL Announcements" are showing up in the lower-left
    page.text("xpath=//div[@id='sidebar-a']/h1").should == 'EOL Announcements'
    #Verify that "What's New" news feed is working in lower right.
    page.text("xpath=//div[@id='sidebar-b']/h1").should == "What's New?"
    #Verify that a "Featured" taxon shows up at lower center, with an image.
    page.element?("xpath=//div[@id='home-center-content']//td[starts-with(@class, 'image')]/a/img[contains(@src,'_medium.jpg')]").should be_true
  end

  it "should redirect to login when admin page is accessed" do
    page.open "/admin"
    page.location.match(/\/login/).should  be_true
  end

  it "should run ajax to change random taxa" do
    page.open "/"
    img1, img2 = top_images_diff(page)
    img1.should_not == img2
  end

  # # This test has been deprecated
  # it "should stop ajax change random taxa on demand" do
  #   page.open "/"
  #   page.click("css=img#play-button")
  #   sleep(2)
  #   img1, img2 = top_images_diff(page)
  #   img1.should == img2
  # end
  
end
