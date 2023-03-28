$gtk.reset

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end


class TetrisGame
  def tick
    iterate
    render
  end

  def initialize(args)
    @args = args
    @next_piece = nil
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
      [44, 4, 140],
    ]

    @grid = []

    for x in 0...@grid_w do
      @grid[x] = []
      for y in 0...@grid_h do
        @grid[x][y] = 0
      end
    end
    select_next_piece
    select_next_piece
  end

  ######################################
  # render methods
  ######################################

  # x and y are positions in the grid, not pixels
  def render_cube(x, y, color)
    boxsize = 30
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
    @args.outputs.solids << [ grid_x + (x * boxsize), (720 - grid_y) - (y * boxsize), boxsize, boxsize, @color_index[color] ]
    @args.outputs.borders << [ grid_x + (x * boxsize), (720 - grid_y) - (y * boxsize), boxsize, boxsize, 255, 255, 255, 255 ]
  end

  def render_grid
    for x in 0...@grid_w do
      for y in 0...@grid_h do
        render_cube(x, y, @grid[x][y]) if @grid[x][y] != 0
      end
    end
  end

  def render_grid_border(x, y, w, h)
    color = 0

    for i in x..(x + w) do
      render_cube(i, y, color)
      render_cube(i, (y + h), color)
    end
    for i in y..(y + h) do
      render_cube(x, i, color)
      render_cube((x + w), i, color)
    end
  end

  def render_background
    @args.outputs.sprites << [75, 300, 300, 300, 'workforce.png']
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
    render_grid_border(-1, -1, @grid_w + 1, @grid_h + 1)
  end

  def render_current_piece
    render_piece(@current_piece, @current_piece_x, @current_piece_y)
  end

  def render_piece(piece, piece_x, piece_y)
    for x in 0...piece.length do
      for y in 0...piece[x].length do
        render_cube(piece_x + x, piece_y + y, piece[x][y]) if piece[x][y] != 0
      end
    end
  end

  def render_next_piece
    render_grid_border(13, 2, 7, 7)
    center_x = (8 -@next_piece.length) / 2
    center_y = (8 - @next_piece[0].length) /2
    render_piece(@next_piece, 13 + center_x, 2 + center_y)
    @args.outputs.labels << [910, 650, "Next piece", 10, 255, 255, 255, 255]
  end

  def render_score
    @args.outputs.labels << [ 75, 75, "Score: #{@score}", 10, 255, 255, 255]
    @args.outputs.labels << [200, 450, "GAME OVER", 100, 255, 255, 255, 255] if @gameover
  end

  def render
    render_background
    render_grid
    render_next_piece
    render_current_piece
    render_score
  end


  ######################################
  # flow methods
  ######################################

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

    for y in 0...@grid_h
      full = true
      for x in 0...@grid_w
        if @grid[x][y] == 0
          full = false
          break
        end
      end
      if full
        @score +=1
        for i in y.downto(1) do
          for j in 0...@grid_w
            @grid[j][i] = @grid[j][i-1]
          end
        end
        for i in 0...@grid_w
          @grid[i][0] = 0
        end
      end
    end
    select_next_piece
    if current_piece_colliding
      @gameover = true
    end
  end

  def select_next_piece
    @current_piece = @next_piece
    x = rand(6) + 1
    puts x
    @next_piece = case x
      when 1 then [[0, x], [0, x], [x, x]]
      when 2 then [[x, x], [x, 0], [x, 0]]
      when 3 then [[x, x, x, x]]
      when 4 then [[x, 0], [x, x], [0, x]]
      when 5 then [[0, x], [x, x], [x, 0]]
      when 6 then [[x, x], [x, x]]
      when 7 then [[0, x], [x, x], [0, x]]
    end
    @current_piece_x = 5
    @current_piece_y = 0
  end

  #####################################
  # user inputs
  #####################################

  def rotate_current_piece_left
    @current_piece = @current_piece.transpose.map(&:reverse)
    if (@current_piece_x + @current_piece.length) >= @grid_w
      @current_piece_x = @grid_w - @current_piece.length
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
    elsif k.key_down.up
      rotate_current_piece_left
    end
  end

  def iterate
    if @gameover
      if @args.inputs.keyboard.key_down.space
        $gtk.reset
      end
      return
    end

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
end
