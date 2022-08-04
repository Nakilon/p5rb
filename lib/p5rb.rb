module P5
  @buffer = []
  class << self
    attr_reader :buffer_setup
    attr_reader :buffer_draw
    @buffer_setup = []
    @buffer_draw = []

    def background c
      @buffer.push "background(#{c})"
    end
    def translate x, y
      @buffer.push "translate(#{x}, #{y})"
    end
    def ellipse *args
      @buffer.push "ellipse(#{args.join ?,})"
    end
    def noStroke
      @buffer.push "noStroke()"
    end
    def fill color
      @buffer.push "fill(#{color})"
    end
    def rect x, y, w, h
      @buffer.push "rect(#{x}, #{y}, #{w}, #{h})"
    end
    def textSize size
      @buffer.push "textSize(#{size})"
    end
    def textAlign *args
      @buffer.push "textAlign(#{args.join ", "})"
    end
    def text text, x, y
      @buffer.push "text(#{text.inspect}, #{x}, #{y})"
    end

    def setup &block
      module_eval &block
      @buffer_setup = @buffer.join ";\n"
      @buffer = []
    end
    def draw &block
      module_eval &block
      @buffer_draw = @buffer.join ";\n"
      @buffer = []
    end
    def setup_to_s
      @buffer_setup
    end
    def draw_to_s
      @buffer_draw
    end

  end
end

def P5 width, height, &block
  P5.module_eval &block
  <<~HEREDOC
    <html>
      <head>
        <script src="https://github.com/processing/p5.js/releases/download/v1.4.2/p5.min.js"></script>
        <script>
          function setup() {
            createCanvas(#{width}, #{height});
#{
  P5.buffer_setup.gsub(/^/, ?\s*8)
}
          }
          function draw() {
#{
  P5.buffer_draw.gsub(/^/, ?\s*8)
}
          }
        </script>
      </head>
      <body><main></main></body>
    </html>
  HEREDOC
end
