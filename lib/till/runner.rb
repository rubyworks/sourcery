module Till

  # = Runner
  #
  class Runner

    require 'till/whole'
    require 'till/inline'
    require 'till/metadata'

    require 'facets/kernel/ask'
    require 'facets/string/tabto'


    # A T T R I B U T E S

    attr_accessor :files

    attr_accessor :force

    attr_accessor :skip

    attr_accessor :stdout

    #attr_accessor :delete


    # I N I T I A L I Z E

    #
    def initialize(files, options)
      files = files || Dir['**/*.til']
      files = files.map do |file|
        if File.directory?(file)
          collect_usable_files(file)
        else
          file
        end
      end.flatten
      @files  = files
      @force  = options[:force]
      @skip   = options[:skip]
      @stdout = options[:stdout]
      #@delete = options[:delete]
    end

    def collect_usable_files(dir)
      Dir[File.join(dir,'**/*.{till,til,rb}')]
    end

    #def delete? ; @delete ; end
    def force?  ; @force  ; end
    def skip?   ; @skip   ; end

    def debug?  ; $DEBUG  ; end
    def trial?  ; $TRIAL  ; end

    #
    #def tillfiles
    #  @tillfiles ||= Dir[File.join(@output, '**/*.till')].select{ |f| File.file?(f) }
    #end

    #
    #def rubyfiles
    #  @rubyfiles ||= Dir[File.join(@output, '**/*.rb')].select{ |f| File.file?(f) }
    #end

    #def whole
    #  @whole ||= Whole.new
    #end

    #def inline
    #  @inline ||= Inline.new
    #end

    #

    def till
      #files.each do |file|
      #  raise "unsupport file type -- #{file}" unless File.extname(file) =~ /^\.(rb|til|till)$/
      #end

      files.each do |file|
        case File.extname(file)
        when '.till', '.til'
          till_whole_template(file)
        else
          till_inline_template(file)
        end
      end
    end

    # Search for till templates (*.till) and render.
    #
    def till_whole_template(file)
      template = Whole.new(file)
      if template.exist? && skip?
        puts "  #{template.relative_output} skipped"
      else
        result = template.render
        if stdout
          puts result
        else
          save(template, result)
        end
      end
      #result = erb(File.read(file))
      #fname = file.chomp(File.extname(file))
      #rm(file) if delete?  # TODO
    end

    # Search through Ruby files for inline till templates.
    def till_inline_template(file)
      parser = Inline.factory(file)
      if !parser
        puts "  unrecognized #{file}" if $DEBUG || $TRIAL
        return
      end
      template = parser.new(file)
      if template.exist? && skip?
        puts "  #{template.relative_output} skipped"
      else
        result = template.render
        if stdout
          puts result
        else
          save(template, result)
        end
      end   
    end

    #
    def save(template, result)
      name = template.relative_output
      save = false
      if trial?
        puts "  #{name}"
      else
        if template.exist?
          if !template.changed?
            puts "  unchanged #{name}"
          elsif !force?
            case ask("  overwrite #{name}? ")
            when 'y', 'yes'
              save = true
            end
          else
            save = true
          end
        else
          save = true
        end
      end
      if save
        template.save
        puts "    written #{name}"
      end
    end

  end

end

