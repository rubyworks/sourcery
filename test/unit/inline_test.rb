require 'test/unit'
require 'till/inline2'

DIR = Pathname.new(__FILE__).parent

class Till::TestInline < Test::Unit::TestCase

  def test_load
    file = Till::Inline.new(DIR + 'fixture/inline.rb')
    file.render
  end

end

