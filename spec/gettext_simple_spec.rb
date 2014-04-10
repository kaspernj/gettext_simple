require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GettextSimple" do
  before do
    require "tmpdir"
    @dir = Dir.mktmpdir
    Dir.mkdir("#{@dir}/da")
    Dir.mkdir("#{@dir}/da/LC_MESSAGES")
    
    file_path = "#{@dir}/da/LC_MESSAGES/default.po"
    File.open(file_path, "w") do |fp|
      fp.puts "msgid \"test %{name}\"\n"
      fp.puts "msgstr \"test translate %{name}\"\n"
      fp.puts "\n"
      
      fp.puts "msgid \"\"\n"
      fp.puts "\"test multiple lines\"\n"
      fp.puts "msgstr \"\"\n"
      fp.puts "\"test mange\"\n"
      fp.puts "\" linjer\"\n"
      fp.puts "\n"
      
      fp.puts "msgid \"empty translation\"\n"
      fp.puts "msgstr \"\"\n"
      fp.puts "\n"
    end
    
    @gs = GettextSimple.new
    @gs.load_dir("#{@dir}")
  end
  
  it "can load a pofile and do some translations" do
    @gs.instance_variable_get(:@locales).keys.should include "da"
    @gs.instance_variable_get(:@locales)["da"].keys.should include "test %{name}"
    @gs.instance_variable_get(:@locales)["da"]["test %{name}"].should eq "test translate %{name}"
    @gs.translate_with_locale("da", "test %{name}", :name => "Trala").should eq "test translate Trala"
  end
  
  it "can register kernel method shortcuts" do
    @gs.register_kernel_methods
    @gs.locale_for_thread = "da"
    
    _("test %{name}", :name => "Kasper").should eq "test translate Kasper"
  end
  
  it "can read multiple line values" do
    @gs.instance_variable_get(:@locales)["da"].keys.should include "test multiple lines"
    @gs.instance_variable_get(:@locales)["da"]["test multiple lines"].should eq "test mange linjer"
  end
  
  it "can read a sample file from POEdit" do
    @gs = GettextSimple.new
    
    da = {}
    locales = @gs.instance_variable_get(:@locales)
    locales[:da] = da
    
    @gs.__send__(:scan_pofile, :da, "#{File.dirname(__FILE__)}/sample_file.po")
    
    da["Locale"].should eq "Sprog"
    
    test_key = "BeachInspectors.com is your online tool for the best beach vacation in Denmark. Find reviews and insider tips for danish beaches and rate your favorite beach."
    test_value = "BeachInspectors.com er dit online værktøj til den bedste strand ferie i Danmark. Find bedømmelser og insider tips til danske strande og bedøm dine favoritstrande."
    
    da[test_key].should eq test_value
  end
  
  it "should ignore empty translations" do
    @gs.instance_variable_get(:@locales)["da"].keys.should_not include "empty translation"
  end
end
