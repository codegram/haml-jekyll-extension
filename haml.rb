require 'rubygems'
require 'haml'
require 'sass'

module Jekyll
  class Site

    def haml2html
      folder = self.config['haml_folder'] || '**/*.haml'
      compile( ["*.haml", folder], /\.haml$/, ".html", Haml::Engine )
    end  

    def sass2css
      folder = self.config['folder'] || '**/*.sass'
      compile( ["*.sass", folder], /\.sass$/, ".css", Sass::Engine )
    end  

    def scss2css
      folder = self.config['scss_folder'] || '**/*.scss'
      compile( ["*.scss", folder], /\.scss$/, ".css", Sass::Engine, syntax: :scss )
    end  

    private

    def compile( files, input_regex, output_extension, engine, options = {} )

      Dir.glob(files).each do |f| 
        origin = File.open(f).read
        result = engine.new( origin, options ).render
        if !result.empty?

          puts "Rendering #{f}"
          output_file_name = f.gsub!( input_regex, output_extension )

          if file_outdated?( output_file_name, result )
            File.open( output_file_name, 'w' ) do |f|
              f.write( result )
            end
          end

        end
      end
    end

    def file_outdated?( file, result )
      !File.exists?(file) or (File.exists?(file) and result != File.read(file))
    end

  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.haml2html
  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.sass2css
  end

  AOP.before(Site, :render) do |site_instance, result, args|
    site_instance.scss2css
  end

  AOP.around(Site, :filter_entries) do |site_instance, args, proceed, abort|
    result = proceed.call
    result.reject do |entry|
      entry.match(/\.haml$/) ||
      entry.match(/\.sass$/) ||
      entry.match(/\.scss$/)
    end
  end
end
