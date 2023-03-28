def init(args)
  args.state.score ||= 0
  args.state.gameover ||= false
  args.state.grid_w ||= 10
  args.state.grid_h||= 20
  args.state.current_piece_x ||= 5
  args.state.current_piece_y||= 0

  if args.state.grid.nil?
    args.state.grid = []
    for x in 0..args.state.grid_w-1 do
      args.state.grid[x] = []
        for x in 0..args.state.grid_h-1 do
          args.state.grid[x][y] = 0

        end
    end
  end
end

def tick(args)
  init args
  render background(args)
  render args
end

# x and y are positions in the grid, not pixels
def render_cube(args, x, y)
  grid_x = 0
  grid_y = 0
  args.outputs.solids << []
end

def render_grid
end

def background(args)
  args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
end

def render(args)
end
