module P5
  class << self
    attr_reader :buffer_outer
    attr_reader :buffer_preload
    attr_reader :buffer_setup
    attr_reader :buffer_draw
  end
  @buffer_outer = ""
  @buffer_preload = []
  @buffer_setup = []
  @buffer_draw = []

  module Block
    class << self
      attr_writer :buffer
      def raw _
        @buffer.push _
      end
      def clear
        @buffer.push "clear()"
      end
      def background color
        @buffer.push "background(#{color})"
      end
      def frameRate _
        @buffer.push "frameRate(#{_})"
      end
      def noFill
        @buffer.push "noFill()"
      end
      def noStroke
        @buffer.push "noStroke()"
      end
      def stroke color
        @buffer.push "stroke(#{color})"
      end
      def strokeWeight _
        @buffer.push "strokeWeight(#{_})"
      end
      def translate x, y
        @buffer.push "translate(#{x}, #{y})"
      end
      def line x1, y1, x2, y2, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "line(#{x1}, #{y1}, #{x2}, #{y2})"
        @buffer.push "pop()" if fill
      end
      def circle x, y, r, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "circle(#{x}, #{y}, #{r})"
        @buffer.push "pop()" if fill
      end
      def ellipse *args   # not tested yet
        @buffer.push "ellipse(#{args.join ?,})"
      end
      def fill color, alpha = nil
        @buffer.push "fill(#{color}#{", #{alpha}" if alpha})"
      end
      def rect x, y, w, h, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "rect(#{x}, #{y}, #{w}, #{h})"
        @buffer.push "pop()" if fill
      end
      def point x, y, stroke: nil, strokeWeight: nil
        @buffer.push "push()" if stroke || strokeWeight
        stroke stroke if stroke
        strokeWeight strokeWeight if strokeWeight
        @buffer.push "point(#{x}, #{y})"
        @buffer.push "pop()" if stroke || strokeWeight
      end
      def textSize size
        @buffer.push "textSize(#{size})"
      end
      def textAlign *args
        @buffer.push "textAlign(#{args.join ", "})"
      end
      def textWidth text
        @buffer.push "textWidth(#{text.inspect})"
      end
      def textAscent text
        @buffer.push "textAscent(#{text.inspect})"
      end
      def text text, x, y, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "text(#{text.inspect}, #{x}, #{y})"
        @buffer.push "pop()" if fill
      end
      def map *args
        "map(#{args.join ", "})"
      end
      def loadImage path, var
        @buffer.push "#{var} = loadImage('#{path}')"
      end
      def image var, x = 0, y = 0, w = nil, h = nil
        @buffer.push "image(#{var}, #{x}, #{y}#{", #{w}" if w}#{", #{h}" if h})"
      end
    end
  end

  class << self
    def raw _
      @buffer_outer = _
    end
    def preload &block
      ::P5::Block.buffer = @buffer_preload
      ::P5::Block.module_eval &block
    end
    def setup &block
      ::P5::Block.buffer = @buffer_setup
      ::P5::Block.module_eval &block
    end
    def draw &block   # not tested yet
      ::P5::Block.buffer = @buffer_draw
      ::P5::Block.module_eval &block
    end
  end

  next_color = 0
  self.define_singleton_method :next_color do
    "color('hsl(#{(((3-Math.sqrt(5))*180 * (next_color+=1)) % 360).round}, 75%, 75%)')"
  end

  class << self
    def plot_scatter data, reverse_y: false
      size = 1000
      max = nil
      (x_range, x_from, x_to, x_enum, x_f),
      (y_range, y_from, y_to, y_enum, y_f) = data.map{ |_| _.take 2 }.transpose.map do |axis|
        min, max = axis.minmax
        range = (min - max).abs
        division = 10**Math::log10(range).floor
        from = min.div(division)*division
        to = -(-max).div(division)*division
        [
          to - from,
          from, to,
          from.step(to, division),
        ]
      end
      max = [x_range, y_range].max
      x_f = ->_{ 20 + (size-40.0) * (_ - x_from) / max }
      y_f = ->_{ 20 + (size-40.0) * (reverse_y ? y_to - _ : _ - y_from) / max }
      P5 40 + (size-40.0) * x_range / max + 50,   # TODO: properly fix the issue that with wide labels the right end of the plot may be cut off
         40 + (size-40.0) * y_range / max do
        setup do
          textSize 15
          raw "const w = max([#{y_enum.map{ |_| "textWidth(#{_})" }.join ?,}])"
          raw "translate(w, 15)"
          stroke 200
          textAlign :CENTER, :BOTTOM; x_enum.each{ |_| line x_f[_], y_f[y_from], x_f[_], y_f[y_to]; text _, x_f[_], 20-5 }
          textAlign :RIGHT, :CENTER;  y_enum.each{ |_| line x_f[x_from], y_f[_], x_f[x_to], y_f[_]; text _, x_f[x_from]-5, y_f[_] }
          stroke 0
          data.each{ |x, y, c, w| point x_f[x], y_f[y], stroke: c, strokeWeight: w }
        end
      end
    end
    def plot_bar_grouped data
      # TODO: this is currently pretty much hardcoded for a time dates charting
      cls = data.values.flat_map(&:keys).uniq.sort
      size = cls.size + 1
      from, to = data.keys.minmax
      max = data.values.flat_map(&:values).max
      P5 500, 500 do
        setup do
          noStroke
          textAlign :CENTER
          cls.size.times do |i|
            raw "let color#{i} = #{P5.next_color}"
          end
          cls.each_with_index{ |_, i| text _, 50+400/(size-2)*i, 25, fill: "color#{i}" }
          text 0, 50, 45, fill: "'black'"
          text max, 450, 45, fill: "'black'"
          textAlign :RIGHT, :TOP
          (from..to).each do |x|
            y = map x.to_i, from.to_i, to.to_i+1, 50, 450
            cls.each_with_index do |c, i|
              rect 50, "#{y}+#{400.0*i/(to-from+1)/size}", map(data.fetch(x,{})[c]||0, 0, max, 0, 400), 400.0/(to-from+1)/size, fill: "color#{i}"
            end
          end
        end
      end
    end
    def plot_bar_stacked data, names, colorize
      # TODO: this is currently hardcoded for '00-00 - 00-00' time axis tick labels width
      count = {}
      max = data.map do |_, day|
        day.each{ |k,v| count[k] ||= 0; count[k] += v }.map(&:last).reduce :+
      end.max
      pairs = {}
      data.each_cons(2) do |(_, day1), (_, day2)|
        (day1.map(&:first) & day2.map(&:first)).each{ |_| pairs[_] ||= 0; pairs[_] += 1 }
      end
      require "pcbr"
      require "set"
      pcbr = PCBR.new
      count.max_by(colorize){ |k,v| v }.each{ |k,v| pcbr.store k, [-v, pairs[k]||0] }
      top = pcbr.sorted
      size = 500
      P5 size, size do
        setup do
          noStroke
          textAlign :RIGHT, :TOP
          border = 25
          left = "#{border} + textWidth(\"00-00 - 00-00\") + 5"
          data.each_with_index do |(bin, day), i|
            y1 = map i, 0, data.size, border, size-border
            y2 = map i+1, 0, data.size, border, size-border
            text bin, "#{left} - 5", y1
            pos = 0
            day.sort_by{ |k,| top.index(k) || top.size }.each do |k, v|
              rect \
                map(pos, 0, max, left, size-border), y1,
                map(v, 0, max, 0, "#{size}-#{border}-(#{left})"), "#{y2}-#{y1}",
                fill: top.include?(k) ? "color('hsl(#{(((3-Math.sqrt(5))*180 * top.index(k)) % 360).round}, 75%, 75%)')" : "color('hsl(0, 0%, 75%)')"
              pos += v
            end
          end
          top.each_with_index{ |id, i| text names[id].inspect[1..-2], size-border, "#{border} + textAscent('X') * #{i}", fill: "color('hsl(#{(((3-Math.sqrt(5))*180 * top.index(id)) % 360).round}, 75%, 75%)')" }
        end
      end
    end
  end
end

def P5 width, height, &block
  ::P5.buffer_outer.clear
  ::P5.buffer_preload.clear
  ::P5.buffer_setup.clear
  ::P5.buffer_draw.clear
  ::P5.module_eval &block
  <<~HEREDOC
    <html>
      <head>
        <meta charset="UTF-8">
        <script src="https://github.com/processing/p5.js/releases/download/v1.4.2/p5.min.js"></script>
        <script>
          #{
            ::P5.buffer_outer
          }
          function preload() {
    #{
      ::P5.buffer_preload.join(";\n").gsub(/^/, ?\s*8)
    }
          }
          function setup() {
            createCanvas(#{width}, #{height});
    #{
      ::P5.buffer_setup.join(";\n").gsub(/^/, ?\s*8)
    }
          }
          function draw() {
    #{
      ::P5.buffer_draw.join(";\n").gsub(/^/, ?\s*8)
    }
          }
        </script>
      </head>
      <body style="margin: 0"><main></main></body>
    </html>
  HEREDOC
end
