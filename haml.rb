require 'rubygems'
require 'haml'
require 'sass'

module Jekyll
  class Site
    def haml2html
      haml_folder = self.config['haml_folder'] || '**/*.haml'
      compile_haml(["*.haml", haml_folder], /\.haml$/,'.html')
    end  

    def sass2css
      sass_folder = self.config['sass_folder'] || '**/*.sass'
      compile_sass(["*.sass", sass_folder], /\.sass$/,'.css')
    end  

    private

    def compile_haml(files, input_regex, output_extension)
      Dir.glob(files).each do |f| 
        begin
          origin = File.open(f).read
          result = Haml::Engine.new(origin).render
          raise HamlErrorException.new if result.empty?
          puts "Rendering #{f}"
          output_file_name = f.gsub!(input_regex,output_extension)
          File.open(output_file_name,'w') {|f| f.write(result)} if !File.exists?(output_file_name) or (File.exists?(output_file_name) and result != File.read(output_file_name))
        rescue HamlErrorException => e
        end
      end
    end

    def compile_sass(files, input_regex, output_extension)
      Dir.glob(files).each do |f| 
        begin
          origin = File.open(f).read
          result = Sass::Engine.new(origin).render
          raise HamlErrorException.new if result.empty?
          puts "Rendering #{f}"
          output_file_name = f.gsub!(input_regex,output_extension)
          File.open(output_file_name,'w') {|f| f.write(result)} if !File.exists?(output_file_name) or (File.exists?(output_file_name) and result != File.read(output_file_name))
        rescue HamlErrorException => e
        end
      end
    end

  end

  class HamlErrorException < Exception
  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.haml2html
  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.sass2css
  end

  AOP.around(Site, :filter_entries) do |site_instance, args, proceed, abort|
    result = proceed.call
    result.reject{ |entry| entry.match(/\.haml$/) || entry.match(/\.sass$/) }
  end
end
