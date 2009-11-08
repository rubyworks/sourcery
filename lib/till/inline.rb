module Till

  # = Inline Templating
  #
  class Inline

    # R E Q U I R E M E N T S

    require 'erb'
    require 'tilt'
    require 'till/context'


    # C O N S T A N T S

    # Supported templating systems.
    STENCILS = %w{ .erb .liquid .mustache }


    # A T T R I B U T E S

    # The file to receive inline templating.
    attr :file

    # The extname of the file.
    attr :extension

    # Location of the file.
    attr :location

    # The rendered result.
    attr :result

    # Rendering context/scope.
    attr :context

    # Extension name of stenciling template system
    # to use. This determines with templating system to use,
    # such as .erb, .liquid, etc. This defaults to '.erb',
    # but can be changed in the file with:
    #
    #   # :till.stencil: <ext>
    #
    attr :stencil


    # I N I T I A L I Z E

    #
    def initialize(file)
      @file      = file
      @extension = File.extname(file)
      @location  = File.dirname(File.expand_path(file))

      self.stencil = '.erb'

      @context = Context.new(@location)
    end

    #
    def stencil=(ext)
      ext = (ext[0,1] == '.' ? ext : ".#{ext}")
      raise "unsupported stencil type -- #{ext}" unless STENCILS.include?(ext)
      @stencil = ext
    end

    #
    def root
      context.metadata.root
    end

    #
    def render
      render_inline(file)
    end

    #
    def render_inline(file)
      #name  = file.sub(Dir.pwd+'/', '')
      save = false
      text = ''
      lines = File.readlines(file)
      i = 0
      while i < lines.size
        line = lines[i]
        if md = /^\s*#\s*:till.stencil:(.*?)/.match(line)
          self.type = md[1].strip
          text << line
        elsif md = /^(\s*)#(\s*):till\+(\d*):/.match(line)
          temp = md.post_match
          code = md.post_match
          line = lines[i+=1]
          while i < lines.size && line =~ /^\s*^#/
            temp << line
            code << line
            line = lines[i+=1]
          end
          res = render_template(code.gsub(/^\s*#*/,'').strip)
          text << md[1] + "#" + md[2] + ":till+#{res.split("\n").size}:"
          text << temp
          text << res
          text << "\n"
          save = true
          i += md[3].to_i
        elsif md = /^(\s*).*?(\s*#\s*:till:)/.match(line)
          pm = md.post_match.strip
          if pm[0,1] == '^'
            pm = pm[1..-1].strip
            fm = pm[0...(pm.index('<')||-1)]
            ri = line.index(fm)
            if ri
              text << line[0...ri] + render_template(pm) + md[2] + md.post_match
            else
              puts "waning: skipped line #{i} no match for #{fm}"
              text << line
            end
          else
            text << md[1] + render_template(pm) + md[2] + md.post_match
          end
          save = true
          i += 1
        else
          text << line
          i += 1
        end
      end

      @result = text
    end

    #

    def render_template(text)
      template = Tilt[stencil]
      unless template
        warn "unknown template type #{stencil}"
        template = Tilt::ERBTemplate
      end
      render_tilt(template.new{ text })
    end

    #

    def render_tilt(template)
      Dir.chdir(location) do
        template.render(@context)
      end
    end

    #

    def relative_output(dir=nil)
      dir = dir || root
      output.sub(dir+'/', '')
    end

    #

    def exist?
      File.exist?(output)
    end

    # Has the file changed?

    def changed?
      if exist?
        File.read(output) != result
      else
        true
      end
    end

    # Save result to file.

    def save
      File.open(output, 'w'){ |f| f << result }
    end

    # Output file (same as the input file).

    def output
      file
    end

    #

    #def erb(text, file=nil)
    #  if file
    #    dir = File.dirname(file)
    #    Dir.chdir(dir) do
    #      context.erb(text)
    #    end
    #  else
    #    context.erb(text)
    #  end
    #end

  end

end


