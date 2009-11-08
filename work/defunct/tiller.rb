require 'till/metadata'
require 'facets/kernel/ask'
require 'facets/string/tabto'
require 'erb'

module Till

  # The Tiller class is used to generate files from
  # embebbded ERB template files.
  #
  class Tiller

    attr_accessor :files

    attr_accessor :force

    attr_accessor :skip

    #attr_accessor :delete

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
      @files = files
      @force = options[:force]
      @skip  = options[:skip]
      #@delete = options[:delete]
    end

    def collect_usable_files(dir)
      Dir[File.join(dir,'**/*.{till,til,rb}')]
    end

    def delete? ; @delete ; end
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

    def till
      files.each{ |file|
        raise "unsupport file type -- #{file}" unless File.extname =~ /^\.(rb|til|till)$/
      end

      files.each do |file|
        case File.extname(file)
        when '.till', '.til'
          till_template(file)
        when '.rb'
          till_inline(file)
        end
      end
    end

    # Search for till templates (*.till) and render.
    #
    def till_template(file)
      result = erb(File.read(file))
      fname = file.chomp(File.extname(file))
      write(fname, result)
      #rm(file) if delete?  # TODO
    end

    # Search through Ruby files for inline till templates.
    def till_inline(file)
      name  = file.sub(Dir.pwd+'/', '')
      save = false
      text = ''
      lines = File.readlines(file)
      i = 0
      while i < lines.size
        line = lines[i]
        if md = /^(\s*)#(\s*):till\+(\d*):/.match(line)
          temp = md.post_match
          code = md.post_match
          line = lines[i+=1]
          while i < lines.size && line =~ /^\s*^#/
            temp << line
            code << line
            line = lines[i+=1]
          end
          res = erb(code.gsub(/^\s*#*/,'').strip, file)
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
              text << line[0...ri] + erb(pm, file) + md[2] + md.post_match
            else
              puts "waning: skipped line #{i} no match for #{fm}"
              text << line
            end
          else
            text << md[1] + erb(pm, file) + md[2] + md.post_match
          end
          save = true
          i += 1
        else
          text << line
          i += 1
        end
      end

      if save
        write(file, text)
      end
    end

    #
    def write(fname, text)
      name  = fname.sub(Dir.pwd+'/', '')
      if trial?
        puts "  #{name}"
      else
        if File.exist?(fname)
          if skip?  # TODO: skip before running erb ?
            puts "    skipped #{name}"
            return
          elsif File.read(fname) == text
            puts "  unchanged #{name}"
            return
          elsif !force?
            case ask("  overwrite #{name}? ")
            when 'y', 'yes'
            else
              return
            end
          end
        end
        File.open(fname, 'w'){ |f| f << text }
        puts "    written #{name}"
      end
    end

    #
    def context
      @conext ||= Erb.new() #TODO: @output ?
    end

    def erb(text, file=nil)
      if file
        dir = File.dirname(file)
        Dir.chdir(dir) do
          context.erb(text)
        end
      else
        context.erb(text)
      end
    end

    # Tiller's erb context
    #
    class Erb

      def initialize(dir=nil)
        @metadata = Metadata.new(dir)
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

