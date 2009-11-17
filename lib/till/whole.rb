module Till

  # = Whole Template
  #
  class Whole

    # R E Q U I R E M E N T S

    # TODO: Load engines only if used?

    begin ; require 'rubygems'  ; rescue LoadError ; end   # why?
    begin ; require 'erb'       ; rescue LoadError ; end
    begin ; require 'redcloth'  ; rescue LoadError ; end
    begin ; require 'bluecloth' ; rescue LoadError ; end
    begin ; require 'rdiscount' ; rescue LoadError ; end

    begin
      require 'liquid'
      #Liquid::Template.register_filter(TemplateFilters)
    rescue LoadError
    end

    begin
      require 'haml'
      #Haml::Template.options[:format] = :html5
    rescue LoadError
    end

    begin
      require 'rdoc/markup/simple_markup'
      require 'rdoc/markup/simple_markup/to_html'
    rescue LoadError
    end

    require 'tilt'

    require 'till/context'


    # A T T R I B U T E S

    # File pathname of the template file.
    attr :file

    # Directory location of the template +file+.
    attr :location

    # Format of the template (in terms of extension names).
    attr :format

    # Where to save the rendered result (defaults to +file+ w/o it's extension).
    # This is also often referred to as the *target*.
    attr :output

    # List of redering filters to processes file through (defaults to +extension+ plus +erb+).
    attr :filters

    # Stores the rendered result, after #render is called.
    attr :result

    # Body of file.
    attr :content

    # Context/scope of template rendering.
    attr :context


    # I N I T I A L I Z E

    #
    def initialize(file)
      @file = file

      case ext = File.extname(file)
      when '.till', '.til'
        fname = file.chomp(ext)
      else
        fname = file
      end

      #@format    = File.extname(fname)
      @location  = File.dirname(File.expand_path(file))

      text = File.read(file).rstrip

      # front matter indicator
      if text =~ /\A---/
        text = text.sub(/---.*?\n/, '')
        meta, body = *text.split(/^---/)
      else
        meta = nil
        body = text
      end

      @content = body

      fm = meta ? YAML.load(meta) : {}

      self.filters = fm['filter'] || ['erb']

      self.format = fm['format'] || File.extname(fname)

      if fm['output']
        self.output = fm['output']
      else
        self.output = fname  #.chomp(extension) #+ DEFAULT_CONVERSIONS[filters.last]
      end



      #@context = Context.new(@location)  # prime context/scope
    end

    #

    def output=(path)
      if path[0,1] == '/'
        path = File.join(root, path[1..-1])
      else
        path = File.join(location, path)
      end
      @output = File.expand_path(path)
    end

    #

    def format=(ext)
      ext = ext.to_s
      ext = (ext[0,1] == '.' ? ext : ".#{ext}")
      case ext
      when '.md'
        ext = '.markdown'
      when '.tt'
        ext = '.textile'
      end
      @format = ext
    end

    #

    def filters=(list)
      @filters = [list].flatten.compact.map{ |f| f.sub(/^\./,'') }
    end

    #

    def relative_output(dir=nil)
      dir = dir || Dir.pwd
      output.sub(dir+'/', '')
    end

    # Does the output file exist?

    def exist?
      File.exist?(output)
    end

    #

    def context
      @context ||= Context.new(location)
    end

    # TODO: maybe bring root discovery up a level or two ?

    def root 
      context.metadata.root
    end

    # Render a whole template.

    def render
      context = Context.new(location)  # prime context/scope
      result  = content

      filters.each do |filter|
        if filter == 'html'  # TODO: +next+ if html format and html filter ?
          engine = Tilt[format]
        else
          engine = Tilt[filter]
        end
        raise "unknown filter #{filter}" unless engine
        result = Dir.chdir(location) do
          engine.new{result}.render(context)
        end
      end
      @result = result
    end

    # Is the current rendering different then the output file's content?
    # This will call #render if it hasn't been called yet.

    def changed?
      render unless result
      if exist?
        File.read(output) != result
      else
        true
      end
    end

    # Save the rendering to the output file.
    # This will call #render if it hasn't been called yet.

    def save
      render unless result
      if File.exist?(output)
        mode = File.stat(output).mode
        File.chmod(mode | 0000220, output)
        File.open(output, 'w'){ |f| f << result }
        File.chmod(mode, output)
      else
        File.open(output, 'w'){ |f| f << result }
        File.chmod(0440, output)  # change to read-only mode
      end
    end

  end

end

