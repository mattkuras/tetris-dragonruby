def tick(args)
  init args
  render args
end


class TetrisGame
  def inititalize(args)
    @score ||= 0
    @gameover ||= false
    @grid_w ||= 10
    @grid_h||= 20
    @current_piece_x ||= 5
    @current_piece_y ||= 0

    if @grid.nil?
      @grid = []
      for x in 0..@grid_w-1 do
        @grid[x] = []
          for x in 0..@grid_h-1 do
            @grid[x][y] = 0

          end
      end
    end
  end

  # x and y are positions in the grid, not pixels
  def render_cube(args, x, y)
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
    # args.outputs.solids << [ 0 + (2 * 30), (720 - 0) - (2 * 30), 30, 30, 255, 0, 0, 255 ]
    args.outputs.solids << [ grid_x + (x * boxsize), (720 - grid_y) - (y * boxsize), boxsize, boxsize, 255, 0, 0, 255 ]
  end

  def render_grid(args)
    render_cube(args, 2, 2)
    render_cube(args, 3, 3)
    render_cube(args, 4, 4)
  end

  def render_background(args)
    args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
  end

  def render(args)
    render_background(args)
    render_grid(args)
  end
end
