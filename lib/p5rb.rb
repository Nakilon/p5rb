module P5
  class << self
    attr_reader :buffer_setup
    attr_reader :buffer_draw
  end
  @buffer_setup = []
  @buffer_draw = []

  module Block
    class << self
      attr_writer :buffer
      def raw _
        @buffer.push _
      end
      def background color
        @buffer.push "background(#{color})"
      end
      def noStroke
        @buffer.push "noStroke()"
      end
      def stroke color
        @buffer.push "stroke(#{color})"
      end
      def translate x, y
        @buffer.push "translate(#{x}, #{y})"
      end
      def line x1, y1, x2, y2
        @buffer.push "line(#{x1}, #{y1}, #{x2}, #{y2})"
      end
      def circle x, y, r
        @buffer.push "circle(#{x}, #{y}, #{r})"
      end
      def ellipse *args   # not tested yet
        @buffer.push "ellipse(#{args.join ?,})"
      end
      def fill color, alpha = nil
        @buffer.push "fill(#{color.inspect}#{", #{alpha}" if alpha})"
      end
      def rect x, y, w, h, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "rect(#{x}, #{y}, #{w}, #{h})"
        @buffer.push "pop()" if fill
      end
      def point x, y
        @buffer.push "point(#{x}, #{y})"
      end
      def textSize size
        @buffer.push "textSize(#{size})"
      end
      def textAlign *args
        @buffer.push "textAlign(#{args.join ", "})"
      end
      def text text, x, y, fill: nil
        (@buffer.push "push()"; fill fill) if fill
        @buffer.push "text(#{text.inspect}, #{x}, #{y})"
        @buffer.push "pop()" if fill
      end
      def map *args
        "map(#{args.join ", "})"
      end
    end
  end

  class << self
    def setup &block
      ::P5::Block.buffer = @buffer_setup
      ::P5::Block.module_eval &block
    end
    def draw &block   # not tested yet
      ::P5::Block.buffer = @buffer_draw
      ::P5::Block.module_eval &block
    end
  end

  class << self
    def plot_scatter data, reverse_y: false
      size = 1000
      max = nil
      (x_range, x_from, x_to, x_enum, x_f),
      (y_range, y_from, y_to, y_enum, y_f) = data.transpose.map do |axis|
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
          data.each{ |x,y| point x_f[x], y_f[y] }
        end
      end
    end
    def plot_bar data
      cls = data.values.flat_map(&:keys).uniq.sort
      size = cls.size + 1
      from, to = data.keys.minmax
      max = data.values.flat_map(&:values).max
      P5 500, 500 do
        setup do
          noStroke
          textAlign :CENTER
          cls.each_with_index{ |_, i| text _, 50+400/(size-2)*i, 25, fill: %w{ red green blue }[i] }
          textAlign :RIGHT, :TOP
          (from..to).each do |date|
            y = map date.ajd.to_i, from.ajd.to_i, to.ajd.to_i, 50, 450
            text date.strftime("%m-%d"), 45, y
            rect 50, y,                            map(data.fetch(date,{})[cls[0]]||0, 0, max, 0, 400), 400/(to-from)/size, fill: "red"
            rect 50, "#{y}+#{400/(to-from)/size}", map(data.fetch(date,{})[cls[1]]||0, 0, max, 0, 400), 400/(to-from)/size, fill: "green"
            rect 50, "#{y}+#{800/(to-from)/size}", map(data.fetch(date,{})[cls[2]]||0, 0, max, 0, 400), 400/(to-from)/size, fill: "blue"
          end
        end
      end
    end
  end
end

def P5 width, height, &block
  ::P5.module_eval &block
  <<~HEREDOC
    <html>
      <head>
        <script src="https://github.com/processing/p5.js/releases/download/v1.4.2/p5.min.js"></script>
        <script>
          function setup() {
            createCanvas(#{width}, #{height});
#{
  ::P5.buffer_setup.join(";\n").gsub(/^/, ?\s*12)
}
          }
          function draw() {
#{
  ::P5.buffer_draw.join(";\n").gsub(/^/, ?\s*12)
}
          }
        </script>
      </head>
      <body style="margin: 0"><main></main></body>
    </html>
  HEREDOC
end
