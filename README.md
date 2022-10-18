## gem p5rb -- Ruby DSL for p5.js

It renders an HTML document with <canvas> and the JS boilerplate included.  
It has some sugar:
* optional `:fill` arg to set color per operation

TODO:
* [ ] validate args on Ruby level
* [ ] plotting library
* [ ] (dev) s/cuprite/ferrum?

### examples

#### scatter plot

```ruby
# all = <integer>[n][2]
(x_min, x_max), (y_min, y_max) = all.transpose.map(&:minmax)
f = ->x,y{ [
  (x - x_min).fdiv(x_max - x_min) * 500,
  (y_max - y).fdiv(y_max - y_min) * 500,
] }

require "p5rb"
P5 500, 500 do
  setup do
    all.each{ |x,y| point *f[x,y] }
  end
end.tap &method(:puts)
```

![image](https://user-images.githubusercontent.com/2870363/194798263-4404df53-26b0-464c-88e1-0ed17f746186.png)

#### chess board FEN format renderer

```none
$ cd examples/fen
$ bundle install
$ bundle exec ruby main.rb "r3r2k/p1n2pb1/3p3p/1ppP1qN1/4N3/P3P3/1PQ2PP1/R4K1R w - - 0 1" > temp.htm
$ open temp.htm
```

```ruby
# ...
require "p5rb"
puts( P5(500, 500) do
  setup do
    textSize 65
    textAlign :CENTER, :CENTER
    translate 50, 50
    rect 0, 0, 400, 400, fill: 240
    noStroke
    [*0..7].product([*0..7]) do |i, j|
      rect j*50, i*50, 50, 50, fill: 180 if (i+j).odd?
    end
    pieces.each do |x, y, piece|
      text piece, (x+0.5)*50, (y+0.5)*50, fill: 0
    end
  end
end )
```

![image](https://user-images.githubusercontent.com/2870363/182951397-721f7937-d942-47a0-832e-c48c4d99c766.png)

#### dot strip plot

![image](https://user-images.githubusercontent.com/2870363/183269117-1f7c94eb-6eaa-4b06-a6e8-947d77b56d82.png)
