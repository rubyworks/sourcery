module Till

  # Base class for all the inline parsers.
  #
  class Inline

    # C L A S S - M E T H O D S

    #
    def self.factory(file)
      map[File.extname(file)]
    end

    #
    def self.map
      @map ||= (
        register.inject({}) do |hash, base|
          base.extensions.each do |ext|
            hash[ext] = base
          end
          hash
        end
      )
    end

    def self.register
      @register ||= []
    end

    def self.inherited(base)
      register << base
    end

    def self.extensions ; raise ; end
 

    # R E Q U I R E M E N T S

    require 'pathname'
    require 'erb'
    require 'tilt'
    require 'till/context'

    require 'till/inline/bash'
    require 'till/inline/cpp'
    require 'till/inline/css'
    require 'till/inline/sgml'
    require 'till/inline/js'
    require 'till/inline/ruby'


    # A T T R I B U T E S

    attr :file

    attr :type

    attr :stencil

    attr :context

    # The rendered result.
    attr :result


    # I N I T I A L I Z E

    #
    def initialize(file)
      @file   = Pathname.new(file)
      @type   = @file.extname

      @stencil = '.erb'
      @context = Context.new(@file.parent)
    end

    #

    def content
      @content ||= File.read(file)
    end 

    #

    def render
      @result = render_result
    end

    #

    def render_template(text)
      engine = Tilt[stencil]
      unless engine
        warn "unknown templating system type #{stencil}"
        engine = Tilt::ERBTemplate
      end
      Dir.chdir(file.parent) do
        engine.new{ text }.render(context)
      end
    end

    #

    def relative_output(dir=nil)
      dir = dir || Dir.pwd
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

  end

end

