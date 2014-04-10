#This class reads .po-files generated by something like POEdit and can be used to run multi-language applications or websites.
class GettextSimple
  #Initializes various data.
  def initialize(args = {})
    @args = {
      :encoding => "utf-8",
      :i18n => false,
      :default_locale => "en"
    }.merge(args)
    @locales = {}
    @debug = @args[:debug]
    
    # To avoid doing a hash lookup on every translate.
    @i18n = @args[:i18n]
    
    if @i18n
      @default_locale = I18n.default_locale
    else
      @default_locale = @args[:default_locale]
    end
    
    @locale = @default_locale
  end
  
  def register_kernel_methods
    require "#{__dir__}/../include/kernel_methods"
    $gettext_simple_kernel_instance = self
  end
  
  def locale_for_thread=(newlocale)
    Thread.current[:gettext_simple_locale] = newlocale
  end
  
  #Loads a 'locales'-directory with .mo- and .po-files and fills the '@locales'-hash.
  #===Examples
  # gtext.load_dir("#{File.dirname(__FILE__)}/../locales")
  def load_dir(dir)
    check_folders = ["LC_MESSAGES", "LC_ALL"]
    
    Dir.foreach(dir) do |file|
      debug "New locale folder found: '#{file}'." if @debug
      
      fn = "#{dir}/#{file}"
      if !File.directory?(fn) || !file.match(/^[a-z]{2}/)
        debug "Skipping: '#{file}'." if @debug
        next
      end
      
      @locales[file] = {} unless @locales[file]
      
      check_folders.each do |fname|
        fpath = "#{dir}/#{file}/#{fname}"
        next if !File.exists?(fpath) || !File.directory?(fpath)
        debug "Found subfolder in '#{file}': '#{fname}'." if @debug
        
        Dir.foreach(fpath) do |pofile|
          if pofile.match(/\.po$/)
            debug "Starting to parse '#{pofile}'." if @debug
            pofn = "#{dir}/#{file}/#{fname}/#{pofile}"
            scan_pofile(file, pofn)
          end
        end
      end
    end
  end
  
  #Translates a given string to a given locale from the read .po-files.
  #===Examples
  # str = "Hello" #=> "Hello"
  # gtext.trans("da_DK", str) #=> "Hej"
  def translate_with_locale(locale, str, replaces = nil)
    locale = locale.to_s
    str = str.to_s
    raise "Locale was not found: '#{locale}' in '#{@locales.keys.join(", ")}'." unless @locales.key?(locale)
    
    if !@locales[locale].key?(str)
      translated_str = str
    else
      translated_str = @locales[locale][str]
    end
    
    if replaces
      replaces.each do |key, val|
        translated_str = translated_str.gsub("%{#{key}}", val)
      end
    end
    
    debug "Translation with locale '#{locale}' and replaces '#{replaces}': '#{str}' to '#{translated_str}'." if @debug
    
    return translated_str
  end
  
  def translate(str, replaces = nil)
    if @i18n
      locale = I18n.locale.to_s
    elsif locale = Thread.current[:gettext_simple_locale]
      # Locale already set through condition.
    else
      locale = @default_locale
    end
    
    translate_with_locale(locale, str, replaces)
  end
  
  # Returns an array of available locales.
  def locales
    return @locales.keys
  end
  
private

  def debug(str)
    $stderr.puts str if @debug
  end
  
  def scan_pofile(locale, filepath)
    current_id = nil
    current_translation = nil
    
    reading_id = false
    reading_translation = false
    
    debug "Opening file for parsing: '#{filepath}' in locale '#{locale}'." if @debug
    File.open(filepath, "r", :encoding => @args[:encoding]) do |fp|
      fp.each_line do |line|
        if match = line.match(/^(msgid|msgstr)\s+"(.*)"$/)
          if match[1] == "msgid"
            current_id = match[2]
            reading_id = true
          elsif match[1] == "msgstr"
            current_translation = match[2]
            reading_id = false
            reading_translation = true
          else
            raise "Unknown translation parameter: '#{match[1]}'."
          end
        elsif match = line.match(/^"(.*)"$/)
          if reading_id
            current_id << match[1]
          elsif reading_translation
            current_translation << match[1]
          else
            raise "Text given but don't know what to do with it."
          end
        elsif line.match(/^(\r|)\n$/)
          if reading_id
            reading_id = false
          elsif reading_translation
            add_translation(locale, current_id, current_translation)
            reading_translation = false
            current_id = nil
            current_translation = nil
          end
        elsif line.start_with?("#")
          # Line is a comment - ignore.
        else
          raise "Couldn't understand line: '#{line}'."
        end
      end
      
      add_translation(locale, current_id, current_translation) if reading_translation
    end
  end
  
  def add_translation(locale, key, val)
    raise "No such language: '#{locale}'." unless @locales.key?(locale)
    
    if !key.to_s.empty? && !val.to_s.empty?
      debug "Found translation for locale '#{locale}' '#{key}' which is: '#{val}'." if @debug
      @locales[locale][key] = val
    end
  end
end
