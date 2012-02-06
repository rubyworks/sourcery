module Sourcery

  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load_file(File.dirname(__FILE__) + '/sourcery.yml')
    )
  end

  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end

end

require 'sourcery/cli'
