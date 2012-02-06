module Sourcery

  require 'optparse'
  require 'sourcery/caster'

  #
  def self.cli(*argv)
    options = {}

    usage = OptionParser.new do |use|
      use.banner = 'Usage: sourcery [OPTIONS] [FILE1 FILE2 ...]'

      #use.on('--delete', 'delete templates when finished') do
      #  options[:delete] = true
      #end

      use.on('-a', '--ask', 'prompt user before overwrites') do
        options[:ask] = true
      end

      use.on('-s', '--skip', 'automatically skip overwrites') do
        options[:skip] = true
      end

      use.on('-o', '--stdout', 'dump output to stdout instead of saving') do
        options[:stdout] = true
      end

      use.on('-t', '--trial', 'run in trial mode (no actual disk write)') do
        $TRIAL = true
      end

      use.on('--debug', 'run in debug mode') do
        $DEBUG = true
      end

      use.on_tail('-h', '--help', 'display this help information') do
        puts use
        exit
      end

      #use['<DIR>',       'directory to till; default is working directory']
    end

    usage.parse!(argv)

    if !argv.empty?
      options[:files] = argv
    end

    caster = Caster.new(options)

    caster.call
  end

end
