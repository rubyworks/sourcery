require 'pom/metadata'
#require 'sow/context'

module Till

  # Metadata belongs to the project being scaffold.
  #
  # TODO: Support POM::Metadata
  #
  class Metadata

    def initialize(output)
      @output = output
      @cache  = {}
      load_metadata
    end

    def method_missing(s, *a)
      return super unless a.empty?

      if @cache.key?(s.to_s)
        @cache[s.to_s]
      else
        nil
      end
    end

  private

    def load_metadata
      Dir[File.join(metadir, '*')].each do |f|
        @cache[File.basename(f)] = File.read(f).strip
      end
    end

    # What is the output's metadirectory?
    def metadir
      @metadir ||= Dir[File.join(@output, '{.meta,meta}/')].first || '.meta/'
    end

    #def load_value(name)
    #  file = File.join(metadir, name)
    #  file = Dir[file].first
    #  if file && File.file?(file)
    #    #return erb(file).strip
    #    return File.read(file).strip
    #  end
    #end

  end

end

