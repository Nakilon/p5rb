module P5
  class << self
    attr_reader :buffer_setup
    attr_reader :buffer_draw
  end
  instance_variable_set :@buffer_setup, []
  instance_variable_set :@buffer_draw, []

  @buffer = []
  class << self
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
      @buffer_setup = @buffer
      @buffer = []
    end
    def draw &block
      module_eval &block
      @buffer_draw = @buffer
      @buffer = []
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
  P5.buffer_setup.join(";\n").gsub(/^/, ?\s*8)
}
          }
          function draw() {
#{
  P5.buffer_draw.join(";\n").gsub(/^/, ?\s*8)
}
          }
        </script>
      </head>
      <body><main></main></body>
    </html>
  HEREDOC
end
