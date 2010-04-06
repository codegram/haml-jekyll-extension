module Jekyll
  class Site
    def haml2html
      path = self.config['haml_path'] || 'haml'
      haml_folder = self.config['haml_folder'] || '**/*.haml'
      compile_haml(path, ["*.haml", haml_folder], /\.haml$/,'.html')
    end  

    def sass2css
      path = self.config['sass_path'] || 'sass'
      sass_folder = self.config['sass_folder'] || '**/*.sass'
      compile_haml(path, ["*.sass", sass_folder], /\.sass$/,'.css')
    end  

    private

    def compile_haml(exec_path, files, input_regex, output_extension)
      Dir.glob(files).each do |f| 
        begin
          result = `#{exec_path} #{f}`
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
