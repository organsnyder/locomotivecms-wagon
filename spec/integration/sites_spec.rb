require File.dirname(__FILE__) + "/integration_helper"

describe Locomotive::Builder do
  it "imports" do
    File.exists?("site/config/site.yml").should be_false
    import_site
    YAML.load_file("site/config/site.yml").should == {
      "name"=>"locomotive",
      "locales"=>["en"],
      "subdomain"=>"locomotive",
      "domains"=>["locomotive.engine.dev"]
    }
  end
  
  it "pushes" do
    import_site
    file_name = File.dirname(__FILE__) + '/../../site/app/views/pages/index.liquid'
    text = File.read(file_name)
    text.gsub!(/Content of the home page/, "New content of the home page")
    File.open(file_name, "w") { |file| file.puts text}
    VCR.use_cassette('push') do
      Locomotive::Builder.push("site", "http://locomotive.engine.dev:3000", "admin@locomotivecms.com", "locomotive")
    end
    
    WebMock.should have_requested(:put, "http://locomotive.engine.dev:3000/locomotive/api/pages/50c99d81c82cd100d3000007.json?auth_token=C3NNrE3RCZgGwiYoyJeQ").with(:body => "page[listed]=true&page[published]=true&page[cache_strategy]=none&page[response_type]=text%2Fhtml&page[raw_template]=New%20content%20of%20the%20home%20page%0A&locale=en").once
  end
end