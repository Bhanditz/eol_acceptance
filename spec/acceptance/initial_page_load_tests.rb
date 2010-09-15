require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Test loading kingdoms" do
  it "should load the Animalia page" do
    page.open "/1"
    page.body_text.should match(/Animalia/)
    page.body_text.should match(/Table of contents/i)
    page.body_text.should match(/Terms of use/i)
  end
  
  it "should load the Plantae page" do
    page.open "/281"
    page.body_text.should match(/Plantae/)
    page.body_text.should match(/Table of contents/i)
    page.body_text.should match(/Terms of use/i)
  end
  
  it "should load the Bacteria page" do
    page.open "/288"
    page.body_text.should match(/Bacteria/)
    page.body_text.should match(/Table of contents/i)
    page.body_text.should match(/Terms of use/i)
  end
end
