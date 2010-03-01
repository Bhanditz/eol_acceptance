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
    #is should have large image on the left, other thumbnail images show up in the middle.
    page.element?("xpath=//div[@id='media-images']//div[@id='large-image']//img[@id='main-image']").should be_true
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
  end

  it "should show IUCN status 'vulnerable' for cheetah's page" do
    page.open Conf.cheetah_page
    page.text("xpath=//span[@class='iucn-status-value']").should match(/vulnerable/i)
  end
  
  it "should paginate through thumbnail images on the page" do
    page.open Conf.corn_page
    dom = Nokogiri.HTML(page.get_html_source)
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
    img_src1 = dom.xpath("//*[starts-with(@id, 'thumbnail_')]/span/img").map {|i| i.attr("src")}
    img_src1.size.should == 9
    page.click("next", :wait_for => :ajax)
    dom = Nokogiri.HTML(page.get_html_source)
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
    img_src2 = dom.xpath("//*[starts-with(@id, 'thumbnail_')]/span/img").map {|i| i.attr("src")}
    img_src2.size.should > 0
    img_src1.to_set.intersection(img_src2.to_set).size.should == 0
  end

  it "should change images when somebody clicks on thumbnails" do
    page.open Conf.corn_page
    dom = Nokogiri.HTML(page.get_html_source)
    big_img_src1 = dom.xpath(".//*[@id='main-image']").attr("src")
    attribution1 = dom.xpath("//*[@id='field-notes']").text
    page.click("xpath=id('thumbnails')/descendant::img[contains(@src,'_small.jpg')][3]", :wait_for => :ajax)
    dom = Nokogiri.HTML(page.get_html_source)
    big_img_src2 = dom.xpath(".//*[@id='main-image']").attr("src")
    attribution2= dom.xpath("//*[@id='field-notes']").text
    big_img_src1.should_not == big_img_src2
    #NOTE we assume that atribution of two pictures is different, which might not always be the case
    attribution1.should_not == attribution2
    # page.click("xpath=.//*[@id='large-image-attribution-button-popup-link']/span")
    # sleep(10)
    # dom = Nokogiri.HTML(page.get_html_source)
    # attr_popup = dom.xpath(".//*[@id='large-image-attribution-button-popup-link_popup']")
    # puts "something", attr_popup
  end



end
