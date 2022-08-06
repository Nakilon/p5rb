h = {}
require "yaml"
YAML.load_file("table.yaml").each do |row|
  row[1].each do |s|
    h[s] ||= []
    h[s].push row[3].to_f
  end
end

min, max = h.values.flatten.minmax
f = ->_{ (_ - min).fdiv(max - min) * 500 + 120 }

require "p5rb"
puts( P5(h.values.flatten.map(&f).max + 10, h.size * 20 + 20) do
  setup do
    noStroke
    textAlign :CENTER, :TOP
    (0..10).each do |i|
      v = (max-min)*i/10+min
      text v.round(2), f[v], 0
    end
    textAlign :LEFT, :CENTER
    h.sort_by{ |s, v| [s[/\d+/].to_i, s] }.each_with_index do |(s, v), i|
      STDERR.puts s
      text s, 0, i * 20 + 20, fill: 0
      fill 0, 50
      v.each{ |_| circle f[_], i * 20 + 20, 20 }
    end
  end
end )
