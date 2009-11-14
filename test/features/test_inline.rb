require 'test/unit'
require 'tmpdir'

class TC_Till_Inline < Test::Unit::TestCase

  def setup
    @tmpdir = File.join(Dir.tmpdir, 'till/')
    FileUtils.rm_r(@tmpdir) if File.exist?(@tmpdir)
    FileUtils.mkdir_p(@tmpdir)
    FileUtils.cp_r('test/fixture', @tmpdir)
  end

  def test_fixture
    out = File.join(@tmpdir, "fixture/inline.rb")
    system "till -f #{out}"

    expect = File.read('test/proofs/inline.rb')
    result = File.read(out)

    assert_equal(expect, result)
  end

  def teardown
    #FileUtils.rm_r(@tmpdir)
  end

end

