$gtk.reset

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end


class TetrisGame
  def initialize(args)
    @args = args
    @next_move = 30
    @score = 0
    @gameover = false
    @grid_w = 10
    @grid_h = 20

    @color_index = [
      [127, 127, 127],
      [0, 255, 255],
      [255, 0, 0],
      [0, 255, 0],
      [0, 0, 255],
      [255, 255, 0],
    ]

    @grid = []

    for x in 0...@grid_w do
      @grid[x] = []
      for y in 0...@grid_h do
        @grid[x][y] = 0
      end
    end
    select_next_piece
  end

  # x and y are positions in the grid, not pixels
  def render_cube(x, y, r, g, b, a = 255)
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
    @args.outputs.solids << [ grid_x + (x * boxsize), (720 - grid_y) - (y * boxsize), boxsize, boxsize, r, g, b, a ]
  end

  def render_grid
    for x in 0...@grid_w do
      for y in 0...@grid_h do
        render_cube(x, y, 255, 255, 0) if @grid[x][y] != 0
      end
    end
  end

  def render_grid_border
    x = -1
    y = -1
    w = @grid_w + 1
    h = @grid_h + 1
    color = @color_index[0]

    for i in x..(x + w) do
      render_cube(i, y, *color)
      render_cube(i, (y + h), *color)
    end
    for i in y..(y + h) do
      render_cube(x, i, *color)
      render_cube((x + w), i, *color)
    end
  end

  def render_background
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
    render_grid_border
  end

  def render_current_piece
    for x in 0...@current_piece.length do
      for y in 0...@current_piece[x].length do
        render_cube(@current_piece_x + x, @current_piece_y + y, 0, 204, 204) if @current_piece[x][y] != 0
      end
    end
  end

  def render
    render_background
    render_grid
    render_current_piece
  end

  def current_piece_colliding
    for x in 0...@current_piece.length do
      for y in 0...@current_piece[x].length do
        if @current_piece[x][y] != 0
          if @current_piece[x][y] != 0 && (@current_piece_y + y >= @grid_h)
            return true
          elsif @grid[@current_piece_x + x][@current_piece_y + y + 1] != 0
            return true
          end
        end
      end
    end
    false
  end

  def plant_current_piece
    # make current piece part of the landscape
    for x in 0...@current_piece.length do
      for y in 0...@current_piece[x].length do
        if @current_piece[x][y] != 0
          @grid[@current_piece_x + x][@current_piece_y + y] = @current_piece[x][y]
        end
      end
    end
    @current_piece_y = 0
    @current_piece_x = 5
    select_next_piece
  end

  def select_next_piece
    x = rand(6) + 1
    @current_piece = case x
      when 1 then [[0, x], [0, x], [x, x]]
      when 2 then [[x, x], [x, 0], [x, 0]]
      when 3 then [[x, x, x, x]]
      when 4 then [[x, 0], [x, x], [0, x]]
      when 5 then [[0, x], [x, x], [x, 0]]
      when 6 then [[x, x], [x, x]]
      when 7 then [[0, x], [x, x], [0, x]]
    end
  end

  def handle_user_input
    k = @args.inputs.keyboard
    if k.key_down.left
      @current_piece_x -=  1 if @current_piece_x > 0
    elsif k.key_down.right
      @current_piece_x +=  1 if @current_piece_x + @current_piece.length < @grid_w
    elsif k.key_down.down || k.key_held.down
      @next_move -= 10
    end
  end

  def iterate
    handle_user_input
    @next_move -= 1
    if @next_move <= 0
      if current_piece_colliding
        plant_current_piece
      else
        @current_piece_y += 1
      end
      @next_move = 30
    end
  end

  def tick
    # iterate
    render
  end
end
