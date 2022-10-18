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
      def circle x, y, r
        @buffer.push "circle(#{x}, #{y}, #{r})"
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
    end
  end

  class << self
    def setup &block
      Block.buffer = @buffer_setup
      Block.module_eval &block
    end
    def draw &block   # not tested yet
      Block.buffer = @buffer_draw
      Block.module_eval &block
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
      <body><main></main></body>
    </html>
  HEREDOC
end
