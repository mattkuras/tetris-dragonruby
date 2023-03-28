$gtk.reset

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end


class TetrisGame
  def initialize(args)
    @args = args
    @score = 0
    @gameover = false
    @grid_w = 10
    @grid_h = 20
    @current_piece_x = 5
    @current_piece_y = 0
    @grid = []

    for x in 0...@grid_w do
      @grid[x] = []
      for y in 0...@grid_h do
        @grid[x][y] = 0
      end
    end
  end

  def tick
    render
  end

  # x and y are positions in the grid, not pixels
  def render_cube(x, y)
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
    @args.outputs.solids << [ grid_x + (x * boxsize), (720 - grid_y) - (y * boxsize), boxsize, boxsize, 255, 0, 0, 255 ]
  end

  def render_grid
    for x in 0...@grid_w do
      for y in 0...@grid_h do
        render_cube(x, y) # if @grid[x][y] != 0
      end
    end
  end

  def render_grid_border
    x = -1
    y = -1
    w = @grid_w + 2
    h = @grid_h + 2

    for i in x..(x + w) do
      render_cube(i, y)
      render_cube(i, (y + h))
    end
    for i in y...(y + h) do
      render_cube(x, i)
      render_cube((x + w), i)
    end
  end

  def render_background
      @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
    render_grid_border
  end

  def render
    render_background
    render_grid
  end
end
