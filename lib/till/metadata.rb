module Till

  # Metadata belongs to the project being scaffold.
  #
  # TODO: Support POM::Metadata
  #
  class Metadata

    #require 'facets/ostruct'

    begin
      require 'pom/metadata'
    rescue LoadError
    end

    # Project root pathname.
    attr :root

    #
    def initialize(root=nil)
      @root = self.class.root(root) || Dir.pwd

      if defined?(POM)
        @pom  = POM::Metadata.new(@root)
      else
        @pom  = nil
      end

      @cache  = {} #OpenStruct.new

      load_metadata  # TODO: when pom supports arbitrary metadata, merge @pom and @cache into same variable.
    end

    #
    def method_missing(s, *a)
      return super unless a.empty?
      if @pom
        begin
          @pom.__send__(s, *a)
        rescue
          @cache.key?(s.to_s) ? @cache[s.to_s] : nil
        end
      else
        @cache.key?(s.to_s) ? @cache[s.to_s] : nil
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

    # Load metadata. This serves as the fallback if POM is not used.

    def load_metadata
      Dir[File.join(metadir, '*')].each do |f|
        val = File.read(f).strip
        val = YAML.load(val) if val =~ /\A---/
        @cache[File.basename(f)] = val
      end
    end

    # What is project root's metadirectory?

    def metadir
      @metadir ||= Dir[File.join(root, '{.meta,meta}/')].first || '.meta/'
    end

    #def load_value(name)
    #  file = File.join(metadir, name)
    #  file = Dir[file].first
    #  if file && File.file?(file)
    #    #return erb(file).strip
    #    return File.read(file).strip
    #  end
    #end

    # Root directory is indicated by the presence of a +meta/+ directory,
    # or +.meta/+ hidden directory.

    ROOT_INDICATORS = [ '{.meta,meta}/' ]

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

