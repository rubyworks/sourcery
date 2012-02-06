module Sourcery

  require 'sourcery/context'
  require 'fileutils'
  require 'erb'

  # Spell Caster renders `src/` files to `lib/`.
  #
  class Caster

    # Source directory, defaults to `src`.
    attr :source

    # Target directory, defaults to `lib`.
    attr :target

    #
    attr :files

    #
    attr_accessor :ask

    #
    attr_accessor :skip

    #
    attr_accessor :stdout

    #
    #attr_accessor :delete

    #
    def initialize(options={})
      @source = options[:source] || 'src'
      @target = options[:target] || 'lib'
      @force  = options[:ask]
      @skip   = options[:skip]
      @stdout = options[:stdout]
      #@delete = options[:delete]

      if options[:files]
        @files = options[:files]
      else
        @files = collect_files(source)
      end
    end

    # Collect all files from source except those starting with an `_` or `.`.
    def collect_files(dir)
      Dir[File.join(dir,'**/*')].reject do |f|
        basename = File.basename(f)
        basename.start_with?('_') or basename.start_with?('.')
      end
    end

    #
    def ask?
      @ask
    end

    #
    def skip?
      @skip
    end

    #
    #def delete? ; @delete ; end

    #
    def debug?
      $DEBUG
    end

    #
    def trial?
      $TRIAL
    end

    #
    def call
      ensure_target_directory

      copy_map = {}

      files.each do |file|
        output = target_file(file)
        if output == file 
          raise "output and source file are identical -- #{file}."
        end
        copy_map[file] = output
      end

      copy_map.each do |file, output|
        render(file, output)
      end
    end

    # Render and save ERB template `file` to `output` file.
    def render(file, output)
      if File.file?(output) && skip?
        print_line('SKIP', output)
      else
        template = ERB.new(File.read(file))
        result   = template.result(context.__binding__)
        if stdout
          puts result
        else
          save(result, output, file)
        end
      end
    end

    # Determine output file name given source `file`.
    def target_file(file)
      name = file.sub(source+'/', '')
      File.join(target, name)
    end

    #
    def context
      @context ||= Context.new
    end

    #
    def save(text, output, source_file)
      name = output # relative_path(output)
      if trial?
        puts "  CAST #{name} (dryrun)"
      else
        save = false
        if File.exist?(output)
          if FileUtils.uptodate?(output, [source_file])
            print_line('UNCHANGED', name)
          elsif ask?
            case ask("%11s %s?" % ['OVERWRITE', name])
            when 'y', 'yes'
              save = true
            end
          else
            save = true
          end
        else
          save = true
        end

        if save
          save_file(output, text)
          puts "  CAST #{name}"
        end
      end
    end

    #
    def print_line(label, string)
      "%11s %s" % [label, string]
    end

    # Save file and make it read-only.
    def save_file(file, text)
      #File.open(file, 'w'){ |f| << text }
      mode = nil
      if File.exist?(file)
        mode = File.stat(file).mode
        mask = mode | 0000200
        File.chmod(mask, file)  # make writeable
      end
      File.open(file, 'w'){ |f| f << text }
      mode = mode || File.stat(file).mode
      mask = mode & (mode ^ 0000222)
      File.chmod(mask, file)    # make read-only
    end

    #
    def ask(prompt=nil)
      $stdout << "#{prompt}"
      $stdout.flush
      $stdin.gets.chomp!
    end

    #
    def ensure_target_directory
      FileUtils.mkdir(target) unless File.directory?(target)
    end

  end

end
