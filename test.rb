require "minitest_cuprite"
minitest_cuprite "headless": "darwin" != Gem::Platform.local.os, timeout: 10

require "minitest/hooks"
describe :test do
  before do
    File.unlink "temp.htm" if File.exist? "temp.htm"
  end
  require "open3"
  def check expectation, (string, status)
    assert status.exitstatus.zero?, string
    visit "file://#{File.expand_path __dir__}/temp.htm"
    t = evaluate_script "document.getElementsByTagName('canvas')[0].toDataURL()"
    # p File.binwrite "temp.png", Base64.decode64(t.split(?,).last)
    assert_equal expectation, t.sum
  end
  it "fen" do   # this example requires third-party gem
    check 42826, Bundler.with_unbundled_env{ Open3.capture2e "bundle exec ruby main.rb 'r3r2k/p1n2pb1/3p3p/1ppP1qN1/4N3/P3P3/1PQ2PP1/R4K1R w - - 0 1' > ../../temp.htm", chdir: "examples/fen" }
  end
  it "dot strip plot" do
    check 23174, Open3.capture2e("ruby examples/WO2022104460A1/main.rb > temp.htm")
  end
  it "scatter plot" do
    unless File.exist? "all.tsv"
      require "open-uri"
      File.write "all.tsv", open("https://storage.yandexcloud.net/gems.nakilon.pro/p5rb/all.tsv", &:read)
    end
    check 31053, Open3.capture2e("ruby examples/moscow/main.rb all.tsv > temp.htm")
  end
end
