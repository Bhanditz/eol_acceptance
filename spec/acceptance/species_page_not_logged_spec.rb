require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Species page without login" do

  it "should show featured taxa when it is clicked from home page" do
    page.open "/"
    #should have login
    page.text("xpath=//a[@href='/login']").should == 'login'
    page.click("//table[@id='featured-species-table'][1]//a[starts-with(@href, '/pages')]", :wait_for => :page)
    dom = page.dom(:reload => true)
    #it should show Random Taxa in lower-right.
    page.title.should match(/- Encyclopedia of Life/)
    page.body_text.should match(/explore/i)
    dom.xpath("//table[@id='related-species-table']//img").size.should == 5 
    #it should show "Species recognized by" in header.
    page.text("xpath=//div[@id='page-title']").should match(/Species recognized by/)
    #it should show Scientific Name as H1, Common Name as H2. TODO: Can we check them interactively?
    dom.xpath("//div[@id='page-title']//h1").first.text.strip.should_not == ''
    page.element?("xpath=//div[@id='page-title']//h2").should be_true
    #it should show IUCN status
    page.text("xpath=//span[@class='iucn-status']").should match(/IUCN Red List Status:/i)
    page.text("xpath=//span[@class='iucn-status-value']").strip.should_not == ""
    #is should have large image on the left, other thumbnail images show up in the middle.
    page.element?("xpath=//div[@id='media-images']//div[@id='large-image']//img[@class='main-image']").should be_true
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
  end
  
  it "should show IUCN status 'vulnerable' for cheetah's page" do
    page.open Conf.cheetah_page
    page.text("xpath=//span[@class='iucn-status-value']").should match(/vulnerable/i)
  end
  
  it "should paginate through thumbnail images on the page" do
    page.open Conf.corn_page
    dom = page.dom(:reload => true)
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
    img_src1 = dom.xpath("//*[@id='thumbnails']/a/span/img").map {|i| i.attr("src")}
    img_src1.size.should == 9
    page.click("next", :wait_for => :ajax)
    sleep 1
    dom = page.dom(:reload => true)
    page.element?("xpath=//div[@id='image-thumbnails']//div[@id='image-collection']//div[@id='thumbnails']").should be_true
    img_src2 = dom.xpath("//*[@id='thumbnails']/a/span/img").map {|i| i.attr("src")}
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
    page.click("xpath=(//a[@title='Content Partners'])[last()]", :wait_for => :ajax)
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
  
  it "should open pages from menus" do
    # This just ensures that the page-does-not-exists follows our expected format.
    page.open "http://staging.eol.org/adfgsdf/sdfgdfg"
    page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should match(/page.*?not exist/)
    page.open "http://staging.eol.org/adfgsdf"
    page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should match(/Search Results/)
    
    page.open Conf.corn_page
    dom = page.dom(:reload => true)
    skipped_links = []
    exceptions = ["Suggestions", "Press Releases"]
    # We don't want to check the language menu at all, so we remove it from the DOM entirely:
    dom.xpath(".//ul[@id='global-navigation']//a[@class='dropdown'][starts-with(@title, 'Language')]")[0].parent.unlink
    dom.xpath(".//ul[@id='global-navigation']//a").each do |link|
      next if link.attributes and link.attributes['class'] and link.attributes['class'].value =~ /dropdown/
      href = link.attributes['href'].value
      #puts "++ Clicking on #{link.inner_text.strip}"
      # YOU WERE HERE - this is currently failing because we have some local URLs that redirect us to non-local sites.  Thus, our assertions fail.  We would like to
      # click on the link and check the current url, but we weren't sure how to get that information from the page instance.
      if (href =~ /^\// || href =~ /#{Conf.url}/) && !exceptions.include?(link.inner_text.strip)
        #puts "  ++ worked for #{link.inner_text.strip}"
        page.click("//a[@href='#{href}']", :wait_for => :page)
        page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should_not match(/page.*?not exist/)
        page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should_not match(/Search Results/)
      else 
        skipped_links << href
      end
    end
    skipped_links.each do |href|
      next if href == "http://synthesis.eol.org" #this page gets stuck by some reason , so I just skip it
      page.open(href)
      page.get_html_source.size.should > 5000
      page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should_not match(/page.*?not exist/)
      page.dom(:reload => true).xpath(".//*[@id='page-title']/h1").inner_text.should_not match(/Search Results/)
    end
  end
  
  
  
  it 'should be able to toggle between scientific and vernacular names' do
    page.open Conf.corn_page
    dom = get_dom(page)
    dom.xpath("//ul[@id='taxonomictext']//a[.='Animalia']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Plantae']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Magnoliophyta']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Liliopsida']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Poales']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Poaceae']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Zea']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Zea mays L.']").size.should == 1
    dom.xpath("//h1/i[.='Zea mays']").size.should == 1
    dom.xpath("//h2/i[.='Corn']").size.should == 1
    page.body_text.should match(/Scientific names/i)
    page.click("xpath=//a[@title='click to show common names']", :wait_for => :page)
    page.dom(:reload => true)
    dom = get_dom(page)
    dom.xpath("//ul[@id='taxonomictext']//a[.='Animals']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Plants']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Flowering plants']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Monocotyledons']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Poales']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Grasses']").size.should == 1
    dom.xpath("//ul[@id='taxonomictext']//a[.='Corn']").size.should > 1
    dom.xpath("//h1/i[.='Zea mays']").size.should == 1
    dom.xpath("//h2/i[.='Corn']").size.should == 1
    page.body_text.should match(/Common names/i)
  end
  
  it 'should require users to be logged in to add comments' do
    page.open Conf.corn_page
    page.body_text.should_not match(/You must be logged in to post comments/i)
    page.click("large-image-comment-button-popup-link")
    page.dom(:reload => true)
    page.body_text.should match(/You must be logged in to post comments/i)
  end
  
  it 'should require users to be logged in to add tags' do
    page.open Conf.corn_page
    page.body_text.should_not match(/You must be logged in to add your own tags/i)
    page.click("large-image-tagging-button-popup-link")
    page.dom(:reload => true)
    page.body_text.should match(/You must be logged in to add your own tags/i)
  end
  
  describe "Search" do 
    it "should not change anything if nothing entered to search box" do
      page.open "/"
      html_original = page.dom(:reload => true).xpath(".//div[@id='content']").inner_html
      page.click("search_image")
      sleep 2
      page.dom(:reload => true).xpath(".//div[@id='content']").inner_html == html_original
      
      page.type "q", "tiger"
      page.click("search_image")
      sleep 2
      page.get_html_source.should_not == html_original
    end
    
    it "should keep type of a search (text, tag, full text) selected after the search is done" do
      page.open "/"
      page.type "q", "blue"
      page.click "search_type_tag"
      page.checked?("search_type_tag").should be_true
      page.click "search_image", :wait_for => :page
      page.checked?("search_type_tag").should be_true
      page.dom(:reload => true).xpath("//input[@id='q']/@value").text.should == "blue"
      page.click "search_type_text"
      page.checked?("search_type_text").should be_true
      page.click "search_image", :wait_for => :page
      page.checked?("search_type_text").should be_true
      page.dom(:reload => true).xpath("//input[@id='q']/@value").text.should == "blue"
    end
    
    it "should return suggested search results and page big searches" do
      page.open "/"
      page.type "q", "tiger"
      page.click "search_type_text"
      page.click "search_image", :wait_for => :page
      page.body_text.should match(/Suggested search results/i)
      dom = page.dom(:reload => true)
      dom.xpath("//table[@summary='Suggested Search Results']//i[.='Panthera tigris']").size.should == 1
      dom.xpath("//table[@summary='Common Names Search Results']//tr").size.should == 11
      dom.xpath("//table[@summary='Common Names Search Results']//a").size.should > 11
      dom.xpath("//table[@summary='Common Names Search Results']//img").size.should > 0
      dom.xpath("//table[@summary='Scientific Names Search Results']//tr").size.should == 11
      page.click("xpath=(//a[@rel='next' and @class='next_page'])[1]", :wait_for => :page)
      dom = page.dom(:reload => true)
      dom.xpath("//table[@summary='Common Names Search Results']//tr").size.should == 11
      dom.xpath("//table[@summary='Common Names Search Results']//a").size.should > 11
      dom.xpath("//table[@summary='Common Names Search Results']//img").size.should > 0
      dom.xpath("//table[@summary='Scientific Names Search Results']//tr").size.should == 11
    end
    
    it "should redirect exact matches to a species page" do
      page.open "/"
      page.type "q", "Cafeteria roenbergensis"
      page.click "search_type_text"
      page.click "search_image", :wait_for => :page
      page.body_text.should match(/Cafeteria roenbergensis Fenchel & D. J. Patterson/i)
      page.body_text.should match(/Table of contents/i)
      page.body_text.should match(/Overview/i)
      page.body_text.should match(/Add new content/i)
    end
    
    it "should allow : in search terms" do
      page.open "/"
      page.type "q", "rac:coon"
      page.click "search_type_text"
      page.click "search_image", :wait_for => :page
      page.body_text.should match(/Sorry, there is no result for "rac:coon" with a colon. See result for "raccoon"./i)
      dom = page.dom(:reload => true)
      dom.xpath("//table[@summary='Suggested Search Results']//i[.='Procyon lotor']").size.should == 1
      dom.xpath("//table[@summary='Common Names Search Results']//tr").size.should == 11
    end
    
    it "should find results for tag searches" do
      page.open "/"
      page.type "q", "blue"
      page.click "search_type_tag"
      page.click "search_image", :wait_for => :page
      dom = page.dom(:reload => true)
      dom.xpath("//table[@summary='Scientific Names Search Results']//tr").size.should >= 5
      dom.xpath("//table[@summary='Scientific Names Search Results']//a[.='Deep Blue Chromis']").size.should == 1
      dom.xpath("//table[@summary='Scientific Names Search Results']//i[.='Chromis abyssus']").size.should == 1
      dom.xpath("//table[@summary='Scientific Names Search Results']//a[.='Blue chromis']").size.should == 1
      dom.xpath("//table[@summary='Scientific Names Search Results']//i[.='Chromis cyanea']").size.should == 1
      dom.xpath("//table[@summary='Scientific Names Search Results']//i[.='Halcyon smyrnensis fusca']").size.should == 1
    end
    
    it "should find results for tag search of video" do
      page.open "/"
      page.type "q", "video"
      page.click "search_type_tag"
      page.click "search_image", :wait_for => :page
      dom = page.dom(:reload => true)
      dom.xpath("//table[@summary='Scientific Names Search Results']//tr").size.should >= 10
      #names should be sorted alphabetically
      prev_name = 'Aaaaaaaaaaaaaaaaaa'
      dom.xpath("//table[@summary='Scientific Names Search Results']//tr").each_with_index do |row, index|
        next if index == 0
        this_name = row.xpath(".//i").text
        #TODO skipping non italisized names for now, could be a bad idea? 
        next if !this_name || this_name.empty?
        (this_name > prev_name).should be_true
        prev_name = this_name
      end
    end
  end
  
  describe "Accounts" do
    it "should create an account" do
      page.open "/register"
      page.type "user_username", "jrice"
      page.body_text.should_not match(/jrice is already taken/i)
      page.focus "user_entered_password"
      page.dom(:reload => true)
      page.body_text.should match(/jrice is already taken/i)
      # page.body_text.should_not match(/show clade browser/i)
      # page.click "curator_request", :wait_for => :ajax
      # pp get_dom(page)
    end
  end
end
