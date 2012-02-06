module Sourcery

  #
  class Metadata

    # Project root pathname.

    attr :root

    #

    def initialize(root=nil)
      @root = self.class.root(root) || Dir.pwd

      #if defined?(POM)
      #  @pom  = POM::Metadata.new(@root)
      #else
      #  @pom  = nil
      #end

      @cache = {}

      load_metadata  # TODO: when pom supports arbitrary metadata, merge @pom and @cache into same variable.
    end

    #

    def method_missing(s, *a)
      m = s.to_s
      case m
      when /=$/
        raise ArgumentError if a.size != 1
        @cache[s.to_s] = a.first
      else
        super(s, *a) unless a.empty?
        @cache[s.to_s]
      end
    end

    # Provide metadata to hash. Some (stencil) template systems
    # need the data in hash form.

    def to_h
      if @pom
        @pom.to_h
      else
        @cache
      end
    end

  private

    #

    def load_metadata
      load_metadata_from_directory
      load_metadata_from_dotruby
    end

    # Load metadata from meta_dir.

    def load_metadata_from_directory
      Dir[File.join(meta_dir, '*')].each do |f|
        val = File.read(f).strip
        val = YAML.load(val) if val =~ /\A---/
        @cache[File.basename(f)] = val
      end
    end

    # Load metadata from metadata directory.

    def load_metadata_from_directory
      file = Dir[File.join(root, '.ruby')].first
      if file
        @cache.update(YAML.load_file(file))
      end
    end

    # Where is project's metadata directory?

    def meta_dir
      @meta_dir ||= Dir[File.join(root, '{var,meta,.meta}/')].first || '.meta/'
    end

    #def load_value(name)
    #  file = File.join(metadir, name)
    #  file = Dir[file].first
    #  if file && File.file?(file)
    #    #return erb(file).strip
    #    return File.read(file).strip
    #  end
    #end

    # Root directory is indicated by the presence of a +src/+ directory.

    ROOT_INDICATORS = ['src/']

    # Locate the project's root directory. This is determined
    # by ascending up the directory tree from the current position
    # until the ROOT_INDICATORS is matched. Returns +nil+ if not found.

    def self.root(local=Dir.pwd)
      local ||= Dir.pwd
      Dir.chdir(local) do
        dir = nil
        ROOT_INDICATORS.find do |i|
          dir = locate_root_at(i)
        end
        dir ? Pathname.new(File.dirname(dir)) : nil
      end
    end

    #
    def self.locate_root_at(indicator)
      root = nil
      dir  = Dir.pwd
      while !root && dir != '/'
        find = File.join(dir, indicator)
        root = Dir.glob(find, File::FNM_CASEFOLD).first
        #break if root
        dir = File.dirname(dir)
      end
      root ? Pathname.new(root) : nil
    end

  end

end
