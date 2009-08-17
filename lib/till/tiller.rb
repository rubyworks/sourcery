require 'till/metadata'
require 'facets/kernel/ask'
require 'erb'

module Till

  # The Tiller class is used to generate files from
  # embebbded ERB template files.
  #
  class Tiller

    attr_accessor :output
    attr_accessor :delete
    attr_accessor :force
    attr_accessor :skip
    attr_accessor :dryrun

    def initialize(output, options)
      @output = output || Dir.pwd
      @delete = options[:delete]
      @force  = options[:force]
      @skip   = options[:skip]
      @dryrun = options[:dryrun]
    end

    def delete? ; @delete ; end
    def force?  ; @force  ; end
    def skip?   ; @skip   ; end

    #
    def tillfiles
      @tillfiles ||= Dir[File.join(@output, '**/*.till')].select{ |f| File.file?(f) }
    end

    #
    def rubyfiles
      @rubyfiles ||= Dir[File.join(@output, '**/*.rb')].select{ |f| File.file?(f) }
    end

    def till
      till_templates
      till_inline
    end

    # Search for till templates (*.till) and render.
    #
    def till_templates
      tillfiles.each do |file|
        result = erb(File.read(file))
        fname = file.chomp('.till')
        name  = fname.sub(Dir.pwd+'/', '')
        #print "  #{name}"
        if dryrun
          puts "  #{name}"
        else
          if File.exist?(fname)
            if skip?
              puts "  skipped #{name}"; next
            elsif !force?
              case ask("  overwrite #{name}? ")
              when 'y', 'yes'
              else
                next
              end
            end
          end
          File.open(fname, 'w'){ |f| f << result }
          puts "  written #{name}"
          #rm(file) if delete?  # TODO
        end
      end
    end

    # Search through Ruby files for inline till templates.
    def till_inline
      rubyfiles.each do |file|
        name  = file.sub(Dir.pwd+'/', '')
        text = ''
        save = false
        File.readlines(file).each do |line|
          if md = /^(\s*).*?(\s*#\s*:till:)/.match(line)
            text << md[1] + erb(md.post_match.strip) + md[2] + md.post_match
            save = true
          else
            text << line
          end
        end
        if save
          if dryrun
            puts "  #{name}"
          else
            File.open(file, 'w'){ |f| f << text }
            puts "  written #{name}"
          end
        end
      end
    end

    def context
      @conext ||= Erb.new(@output)
    end

    def erb(text)
      context.erb(text)
    end

    # Tiller's erb context
    #
    class Erb

      def initialize(output)
        @metadata = Metadata.new(output)
      end

      def method_missing(s)
        @metadata.send(s)
      end

      # Processes through erb.
      def erb(text)
        erb = ERB.new(text)
        erb.result(binding)
      end

    end#class Context

  end#class Tiller

end

