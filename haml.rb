module Jekyll
  class Site
    def haml2html
      haml_path = self.config['haml'] || 'haml'
      (Dir["*.haml", File.join("_layouts", "*.haml")]).each do |f| 
        begin
          result = `#{haml_path} #{f}`
          raise HamlErrorException.new if result.empty?
          output_file_name = f.gsub!(/\.haml$/,'.html')
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
end
