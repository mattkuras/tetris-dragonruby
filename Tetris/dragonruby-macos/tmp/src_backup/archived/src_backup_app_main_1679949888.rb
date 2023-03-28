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
    @current_piece_x = 5
    @current_piece_y = 0
    @current_piece = [[1, 1], [1, 1]]

    @grid = []

    for x in 0...@grid_w do
      @grid[x] = []
      for y in 0...@grid_h do
        @grid[x][y] = 0
      end
    end
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
        render_cube(x, y, 255, 0, 0) if @grid[x][y] != 0
      end
    end
  end

  def render_grid_border
    x = -1
    y = -1
    w = @grid_w + 1
    h = @grid_h + 1
    color = [ 255, 255, 255]

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
  end

  def iterate
    @next_move -= 1
    if @next_move <= 0
      @current_piece_y += 1
      @next_move = 30
      if current_piece_colliding
        # do something
      end
    end
  end

  def tick
    iterate
    render
  end
end
