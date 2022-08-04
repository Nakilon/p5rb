require "fen"
board = Display.new ARGV.first
pieces = board.instance_variable_get(:@fen).board.split(?\n).flat_map.with_index do |row, i|
  row.chars.take(8).map.with_index do |cell, j|
    next if ?_ == cell
    [j, i, board.unicode_piece(cell.downcase.to_sym), board.unicode_piece(cell.to_sym)]
  end.compact
end

require "p5rb"
cell_size = 50
puts( P5(cell_size*10, cell_size*10) do
  setup do
    textSize cell_size*1.3
    textAlign :CENTER, :CENTER
    translate cell_size, cell_size
  end
  draw do
    fill 240
    rect 0, 0, 8*cell_size, 8*cell_size
    noStroke
    fill 180
    [*0..7].product([*0..7]) do |i, j|
      rect j*cell_size, i*cell_size, cell_size, cell_size if (i+j).odd?
    end
    pieces.each do |x, y, fill, piece|
      fill 255; text  fill, (x+0.5)*cell_size, (y+0.5)*cell_size
      fill 0  ; text piece, (x+0.5)*cell_size, (y+0.5)*cell_size
    end
  end
end )
