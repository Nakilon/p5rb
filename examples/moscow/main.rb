# $ jq -r 'try @tsv "\(.geometry.coordinates)"' < ru_mow_statewide-addresses-state.geojson > all.tsv
# $ ruby main.rb all.tsv > temp.htm

all = $<.map{ |_| _.split.map &:to_f }
x_min, x_max = all.map(&:first).minmax
y_min, y_max = all.map(&:last).minmax
f = ->x,y{ [
  (x - x_min).fdiv(x_max - x_min) * 500,
  (y_max - y).fdiv(y_max - y_min) * 500,
] }

require "../../lib/p5rb"
P5 500, 500 do
  setup do
    noStroke
    stroke 0
    all.each{ |x,y| point *f[x,y] }
  end
end.tap &method(:puts)
