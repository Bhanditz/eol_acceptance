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
    # this code does not work in Safari yet unfortunatelly
    # We do have to check such things by hand for now 
    # if Conf.browser == "*firefox"
    #   page.click("xpath=.//*[@id='large-image-attribution-button-popup-link']/span", :wait_for => :ajax)
    #   dom = Nokogiri.HTML(page.get_html_source)
    #   attr_popup = dom.xpath(".//*[@id='large-image-attribution-button-popup-link_popup']")
    #   attribution1 = attr_popup.text
    #   page.click("xpath=id('thumbnails')/descendant::img[contains(@src,'_small.jpg')][1]", :wait_for => :ajax)
    #   page.click("xpath=.//*[@id='large-image-attribution-button-popup-link']/span", :wait_for => :ajax)
    #   dom = Nokogiri.HTML(page.get_html_source)
    #   attr_popup = dom.xpath(".//*[@id='large-image-attribution-button-popup-link_popup']")
    #   attribution2 = attr_popup.text
    #   attribution1.should_not == attribution2
    # end
  end
  
    
  it "should show TOC items" do
    #check that TOC exists
    page.open Conf.corn_page
    page.dom.xpath(".//*[@id='toc']//a[starts-with(@class, 'toc_item')]").size.should > 0
    #check that clicking on TOC items works as expected
    re_category_id = /^category_id_[\d]+$/
    active_link_id = page.dom.xpath(".//*[@id='toc']//a[contains(@class, 'active')]")[0].attributes['id'].value
    active_link_id.should match(re_category_id)
    inactive_link_id = page.dom.xpath(".//*[@id='toc']//a[contains(@class, 'toc_item')]").select { |e| !e.attributes['class'].value.match(/active/) }[0].attributes['id'].value
    inactive_link_id.should match(re_category_id)
    center_header = page.dom.xpath(".//*[@id='center-page-content']/div[1]/h3").inner_text
    central_content = page.dom.xpath(".//*[@id='center-page-content']").inner_text
    page.click(inactive_link_id, :wait_for => :ajax)
    page.dom(:reload => true).xpath(".//*[@id='#{inactive_link_id}']")[0].attributes["class"].value.should match(/active/)
    page.dom.xpath(".//*[@id='#{active_link_id}']")[0].attributes["class"].value.should_not match(/active/)
    page.dom.xpath(".//*[@id='center-page-content']").inner_text.should_not == central_content
    new_center_header = page.dom.xpath(".//*[@id='center-page-content']/div[1]/h3").inner_text
    new_center_header.should_not == center_header
    #check that BHL exists
    page.click("link=Biodiversity Heritage Library", :wait_for => :ajax)
    page.dom(:reload => true).xpath(".//div[@id='center-page-content']//th")[0].inner_text.strip.should == 'BHL Summary'
    #check that Common name page exists
    page.click("link=Common Names", :wait_for => :ajax)
    page.dom(:reload => true).xpath(".//*[@id='common_names_wrapper']//div[@class='title']").size.should > 0
    common_names = page.text('common_names_wrapper')
    common_names.should match /English/
    common_names.should match /Arabic/
    #check that Specialist Project page exists
    page.click("link=Specialist Projects", :wait_for => :ajax)
    page.dom(:reload => true).xpath(".//div[@id='center-page-content']//img").size.should > 4
    #check for a bunch of references
    page.click("link=Literature References", :wait_for => :ajax)
    page.dom(:reload => true).xpath(".//div[@id='center-page-content']").inner_text.should match /References/i
    page.dom(:reload => true).xpath(".//div[@id='center-page-content']//tr").size.should > 2
    #check for Biomedical Terms
    page.click("link=Biomedical Terms", :wait_for => :ajax)
    iframe = page.dom(:reload => true).xpath(".//div[@id='center-page-content']//iframe")
    iframe.size.should == 1
    iframe[0].attributes["src"].value.should match /ubio/i
  end


end
