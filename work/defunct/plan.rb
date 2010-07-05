module Till

  # = Tilling Plan
  #
  # A plan file is used to easily repeat a set of tills.
  #
  #   myfile.html:
  #     source: templates/myfile.rdoc
  #     filter: erb, rdoc
  #
  class Plan

    include Enumerable

    #

    def initialize(root)
      file = Dir[File.join(root, '{.config,config}/till/plan.{yml,yaml}')].first
      @plan = file ? YAML.load(File.new(file) : {}
    end

    #

    def [](file)
      @plan[file]
    end

    #

    def each(&block)
      @plan.each(&block)
    end

  end

end

