require "minitest_cuprite"
minitest_cuprite("headless": "darwin" != Gem::Platform.local.os, timeout: 10) do |_|
  next if "darwin" != Gem::Platform.local.os
  require "browser_reposition"
  _.extend(BrowserReposition).reposition
end

describe :test do
  require "open3"
  def f expectation, status, string, path
    assert status.exitstatus.zero?, string
    visit "file://#{File.expand_path __dir__}/#{path}"
    t = evaluate_script "document.getElementsByTagName('canvas')[0].toDataURL()"
    # p File.binwrite "temp.png", Base64.decode64(t.split(?,).last)
    assert_equal expectation, t.sum
  end
  it "fen" do   # this example requires third-party gem
    File.unlink "examples/fen/temp.htm" if File.exist? "examples/fen/temp.htm"
    string, status = Bundler.with_unbundled_env{ Open3.capture2e "bundle exec ruby main.rb 'r3r2k/p1n2pb1/3p3p/1ppP1qN1/4N3/P3P3/1PQ2PP1/R4K1R w - - 0 1' > temp.htm", chdir: "examples/fen" }
    f 42826, status, string, "examples/fen/temp.htm"
  end
  it "dot strip plot" do
    File.unlink "temp.htm" if File.exist? "temp.htm"
    string, status = Open3.capture2e "ruby examples/WO2022104460A1/main.rb > temp.htm"
    f 23174, status, string, "temp.htm"
  end
  it "scatter plot" do
    File.unlink "temp.htm" if File.exist? "temp.htm"
    unless File.exist? "all.tsv"
      require "open-uri"
      File.write "all.tsv", open("https://storage.yandexcloud.net/gems.nakilon.pro/p5rb/all.tsv", &:read)
    end
    string, status = Open3.capture2e "ruby examples/moscow/main.rb all.tsv > temp.htm"
    f 31053, status, string, "temp.htm"
  end
end
