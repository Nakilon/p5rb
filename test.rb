require "minitest_cuprite"
minitest_cuprite "headless": "darwin" != Gem::Platform.local.os, timeout: 10

require "minitest/hooks"
describe :test do
  def base64 string, status
    assert status.exitstatus.zero?, string
    visit "data:text/html;charset=UTF-8;base64,#{Base64.strict_encode64 string}"#.tap{ |_| File.write "temp.txt", _ }
    evaluate_script "document.getElementsByTagName('canvas')[0].toDataURL()"
  end
  def file string, status
    assert status.exitstatus.zero?, string
    File.write "temp.htm", string
    visit "file://#{File.expand_path "temp.htm"}"
    evaluate_script "document.getElementsByTagName('canvas')[0].toDataURL()"
  end

  describe :idhash do
    require "open3"
    require "dhash-vips"
    def check delta, expectation, base64
      fingerprint = DHashVips::IDHash.fingerprint Vips::Image.new_from_buffer(Base64.decode64(base64.split(?,)[1]), "")#.tap{ |_| _.write_to_file "temp.png" }
      assert_in_delta 0, DHashVips::IDHash.distance(expectation, fingerprint), delta, ->{ "0x#{fingerprint.to_s 16}" }
    end

  it "fen" do   # this example requires third-party gem
      check 0, 0xff8900000000ffffff9181808000ffffffdfa04201fe0000ffd12000c0090000, base64(*Bundler.with_unbundled_env{ Open3.capture2e "bundle install >/dev/null && bundle exec ruby main.rb 'r3r2k/p1n2pb1/3p3p/1ppP1qN1/4N3/P3P3/1PQ2PP1/R4K1R w - - 0 1'", chdir: "examples/fen" })
  end
  it "dot strip plot" do
      check 0, 0x1d5cdc0d1d0c1d9f5720a6fff2fe020180df0000df81c03f0080ffff0000ff7f, base64(*Open3.capture2e("ruby examples/WO2022104460A1/main.rb"))
  end
  it "scatter plot" do
    unless File.exist? "all.tsv"
      require "open-uri"
      File.write "all.tsv", open("https://storage.yandexcloud.net/gems.nakilon.pro/p5rb/all.tsv", &:read)
    end
      check 0, 0x2e0f3f2f9c983034009ef8fafcf870304f0f3020c102403c639e7c78f8020404, file(*Open3.capture2e("ruby examples/moscow/main.rb all.tsv"))
  end
    it "bar chart" do
      check 0, 0xfd7cf00080fec23d7ffee0408340c2fffe0000d040ff388167008b80408080ff, base64(*Open3.capture2e("ruby examples/tg_export/main.rb"))
    end
  end

end
