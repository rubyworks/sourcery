module Till

  # = Tilling Context
  #
  class Context

    require 'till/metadata'

    attr :metadata

    #

    def initialize(dir=nil)
      @metadata = Metadata.new(dir)
    end

    #

    def method_missing(s)
      @metadata.send(s)
    end

    #

    def to_h
      @metadata.to_h
    end

    # Processes through erb.
    #def erb(text)
    #  erb = ERB.new(text)
    #  erb.result(binding)
    #end

  end

end
