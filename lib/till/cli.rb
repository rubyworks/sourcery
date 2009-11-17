#!/usr/bin/env ruby

require 'optparse'
require 'till/runner'

options = {}

usage = OptionParser.new do |use|

  use.banner = 'Usage: till [OPTIONS] [FILE1 FILE2 ...]'

  #use.on('--delete', 'delete templates when finished') do
  #  options[:delete] = true
  #end

  use.on('-f', '--force', 'automatically make overwrites') do
    options[:force] = true
  end

  use.on('-s', '--skip', 'automatically skip overwrites') do
    options[:skip] = true
  end

  use.on('-o', '--stdout', 'dump output to stdout instead of saving') do
    options[:stdout] = true
  end

  use.on('-t', '--trial', 'run in trial mode') do
    $TRIAL = true
  end

  use.on('--debug', 'run in debug mode') do
    $DEBUG = true
  end

  use.on_tail('-h', '--help', 'display this help information') do
    puts use
    exit
  end

end

#use['<DIR>',       'directory to till; default is working directory']

usage.parse!(ARGV)

files = ARGV

runner = Till::Runner.new(files, options)

runner.till

