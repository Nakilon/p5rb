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
    def circle x, y, r
      @buffer.push "circle(#{x}, #{y}, #{r})"
    end
    def ellipse *args
      @buffer.push "ellipse(#{args.join ?,})"
    end
    def noStroke
      @buffer.push "noStroke()"
    end
    def fill color, alpha = nil
      @buffer.push "fill(#{color}#{", #{alpha}" if alpha})"
    end
    def rect x, y, w, h, fill: nil
      (@buffer.push "push()"; fill fill) if fill
      @buffer.push "rect(#{x}, #{y}, #{w}, #{h})"
      @buffer.push "pop()" if fill
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
