require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GettextSimple" do
  before do
    require "tmpdir"
    @dir = Dir.mktmpdir
    Dir.mkdir("#{@dir}/da")
    Dir.mkdir("#{@dir}/da/LC_MESSAGES")
    
    File.open("#{@dir}/da/LC_MESSAGES/default.po", "w") do |fp|
      fp.puts "msgid \"test %{name}\"\n"
      fp.puts "msgstr \"test translate %{name}\"\n\n"
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
end
