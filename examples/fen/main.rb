require "fen"
board = Display.new ARGV.first
pieces = board.instance_variable_get(:@fen).board.split(?\n).map.with_index do |row, i|
  row.chars.take(8).map.with_index do |cell, j|
    [
      board.unicode_piece(cell.downcase.to_sym),
      board.unicode_piece(cell.to_sym)
    ] unless ?_ == cell
  end
end

require "p5rb"
cell_size = 50
puts( P5(cell_size*10, cell_size*10) do
  setup do
    textSize cell_size*1.3
    textAlign :CENTER, :CENTER
    translate cell_size, cell_size
    rect 0, 0, 8*cell_size, 8*cell_size, fill: 240
    noStroke
    [*0..7].product([*0..7]) do |i, j|
      if (i+j).odd?
        rect j*cell_size, i*cell_size, cell_size, cell_size, fill: 180
      end
      if pieces[i][j]
        text pieces[i][j][0], (j+0.5)*cell_size, (i+0.5)*cell_size, fill: 255
        text pieces[i][j][1], (j+0.5)*cell_size, (i+0.5)*cell_size, fill: 0
      end
    end
  end
end )
