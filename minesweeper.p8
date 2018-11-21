pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
    game_states = {"title","game","lose","win"}

    --default values
    state = "game"
    num_mines = 10
    grid_width = 12
    grid_height = 12
    grid_pos_x = (116-grid_width*8)/2  --grid's position
    grid_pos_y = (116-grid_height*8)/2
    px = grid_pos_x+8  --cursor position
    py = grid_pos_y+8
    grid_x = 1  --position in grid
    grid_y = 1
    zoom = 0
    pan_x = 0
    pan_y = 0
    bg_color = 1
    press_dur = 0.2 --press animation duration
    explosion_dur = 0.2  --time betw sprite changes
    explode_offset = 0.1  --for a wave of explosions
    debug = false
    debug_message = nil
    --flag waving variables
    flag_t = time()
    flag_dur = 1/7
    --sfx values
    sfx_0 = 0
    sfx_1 = 1
    sfx_2 = 2
    ugly_sfx = 10

    --sprites
    tile_idle = 1
    tile_pressed = 2
    tile_select = 16
    no_tile_select = 17
    no_tile_sp = 18
    bomb_sp = 3
    explosion_sp = {3,4,5,6,7,8,9,10,11} // have to be consecutive
    flag_sp = {12,13,14}
    flag_wave_sp = flag_sp[1]

    --make grid
    grid = {}
    for x=1,grid_width do
        grid[x] = {}
    		  for y=1,grid_height do
    		      grid[x][y] = {}
    		      grid[x][y].is_tiled = true
    		      grid[x][y].num_value = 0
    		      grid[x][y].is_bomb = false
              grid[x][y].is_flagged = false
    		      grid[x][y].pressed_t = 0
              grid[x][y].lose_sp = bomb_sp
    		  end
    end

    local m = num_mines
    while m > 0 do
        x = flr(rnd(grid_width))+1
        y = flr(rnd(grid_height))+1
        if not grid[x][y].is_bomb then
            --set as mine
            grid[x][y].is_bomb = true
            --add value to surrounding area
            if(x-1>0) grid[x-1][y].num_value += 1
            if(x-1>0 and y-1>0) grid[x-1][y-1].num_value += 1
            if(x-1>0 and y<grid_height) grid[x-1][y+1].num_value += 1
            if(y-1>0) grid[x][y-1].num_value += 1
            if(x<grid_width and y-1>0) grid[x+1][y-1].num_value += 1
            if(x<grid_width) grid[x+1][y].num_value += 1
            if(x<grid_width and y<grid_height) grid[x+1][y+1].num_value += 1
            if(y<grid_height) grid[x][y+1].num_value += 1
            m -= 1
        end
    end

    -- set bg to transparent
				palt(0,false)
				palt(bg_color,true)
end

function _update60()
    if state == "game" then
        --movement
        if btnp(0) then --left
            if grid_x>1 then
                px -= 8
                grid_x -= 1
            else
                sfx(sfx_0)
            end
        end
        if btnp(1) then --right
            if grid_x<grid_width then
                px += 8
                grid_x += 1
            else
                sfx(sfx_0)
            end
        end
        if btnp(2) then --up
            if grid_y>1 then
                py -= 8
                grid_y -= 1
            else
                sfx(sfx_0)
            end
        end
        if btnp(3) then --down
            if grid_y<grid_height then
                py += 8
                grid_y += 1
            else
                sfx(sfx_0)
            end
        end

        --select tile
        if btnp(4) then --z, presses tile
          press_tile()
        end

        if btnp(5) then --x, flags tile
            place_flag()
        end
        --zoom
        --pan
        --menu
    elseif state == "lose" then
        change_explosions()

    elseif state == "win" then
        move_flags()
    end
end

function _draw()
    if state == "game" then
        cls(bg_color)
        draw_grid()
        draw_flags()
        draw_selection()
        if debug then
            draw_bombs()
            draw_nums()
            print(time(),0,0,7)
            if(debug_message) print(debug_message,0,120,7)
        end

    elseif state == "lose" then
        cls(bg_color)
        draw_grid()
        draw_bombs()
        draw_flags()
        draw_explosions()

    elseif state == "win" then
        cls(bg_color)
        draw_grid()
        draw_flags()
    end
end
-->8
--draw functions
-- draw tiles, nums, and bombs
function draw_grid()
    for x=1,grid_width do
        for y=1,grid_height do
            if grid[x][y].is_tiled then
                if grid_x==x and grid_y==y then
                    spr(tile_select,x*8+grid_pos_x,y*8+grid_pos_y)
                else
                    spr(tile_idle,x*8+grid_pos_x,y*8+grid_pos_y)
                end
            else
                local dt = time() - grid[x][y].pressed_t
                if dt < press_dur then
                    spr(tile_pressed,x*8+grid_pos_x,y*8+grid_pos_y)
                else
                    spr(no_tile_sp,x*8+grid_pos_x,y*8+grid_pos_y)
                    if grid[x][y].is_bomb then
                        spr(bomb_sp,x*8+grid_pos_x,y*8+grid_pos_y)
                    elseif grid[x][y].num_value != 0 then
                        print(grid[x][y].num_value,x*8+grid_pos_x+2,y*8+grid_pos_y+1,12)
			                 end
                end
            end
        end
    end
end


-- shows where the cursor is
function draw_selection()
    if not grid[grid_x][grid_y].is_tiled
            and time() - grid[grid_x][grid_y].pressed_t > press_dur
            then
        spr(no_tile_select,px,py)
    end
end


-- debug draws

-- on top of tiles
function  draw_bombs()
    for x=1,grid_width do
        for y=1,grid_height do
            if grid[x][y].is_bomb then
                spr(bomb_sp,x*8+grid_pos_x,y*8+grid_pos_y)
            end
        end
    end
end


-- on top of tiles
-- includes zero
function draw_nums()
    for x=1,grid_width do
        for y=1,grid_height do
            print(grid[x][y].num_value,x*8+grid_pos_x+2,y*8+grid_pos_y+2,7)
        end
    end
end


--draw explosion
function draw_explosions()
    for x=1,grid_width do
        for y=1,grid_height do
                if grid[x][y].is_bomb then
                    spr(grid[x][y].lose_sp,x*8+grid_pos_x,y*8+grid_pos_y)
                end
        end
    end
end


--draws flags on top of bombs
function draw_flags()
    for x=1,grid_width do
        for y=1,grid_height do
            if grid[x][y].is_flagged then
                spr(flag_wave_sp,x*8+grid_pos_x,y*8+grid_pos_y)
            end
        end
    end
end

-->8
--game functions

--reveals tile
--opens surrounding tiles
--gameover if clicked bomb
--starts animation for pressing
function press_tile()
    if not grid[grid_x][grid_y].is_flagged then
        reveal_tile(grid_x,grid_y)
        if grid[grid_x][grid_y].is_bomb then
            game_over()
        elseif grid[grid_x][grid_y].num_value == 0 then
            zero_tile(grid_x,grid_y)
        end
        check_win()
    else
        sfx(sfx_2)
    end
end


function reveal_tile(x,y)
    if grid[x][y].is_tiled then
        sfx(sfx_1)
        grid[x][y].is_tiled = false
        grid[x][y].pressed_t = time()
    else
        sfx(sfx_2)
    end
end


--clicked on a mine, game over
function game_over()
    state = "lose"
    for x=1,grid_width do
        for y=1,grid_height do
            if grid[x][y].is_bomb then
                --find distance from losing bomb to x,y
                local dist = sqrt((grid_x - x)^2 + (grid_y - y)^2)
                grid[x][y].explosion_t = time() + explode_offset*dist
                grid[x][y].lose_sp = explosion_sp[1]
            end
        end
    end
end


--recursively reveals all surrounding tiles
function zero_tile(x,y)
    if x-1>0 and grid[x-1][y].is_tiled then
        reveal_tile(x-1,y)
        if grid[x-1][y].num_value == 0 then
            zero_tile(x-1,y)
        end
    end
    if x-1>0 and y-1>0
            and grid[x-1][y-1].is_tiled
            then
        reveal_tile(x-1,y-1)
        if grid[x-1][y-1].num_value == 0 then
            zero_tile(x-1,y-1)
        end
    end
    if y-1>0
            and grid[x][y-1].is_tiled
            then
        reveal_tile(x,y-1)
        if grid[x][y-1].num_value == 0 then
            zero_tile(x,y-1)
        end
    end
    if x<grid_width and y-1>0
            and grid[x+1][y-1].is_tiled
            then
        reveal_tile(x+1,y-1)
        if grid[x+1][y-1].num_value == 0 then
            zero_tile(x+1,y-1)
        end
    end
    if x<grid_width
            and grid[x+1][y].is_tiled
            then
        reveal_tile(x+1,y)
        if grid[x+1][y].num_value == 0 then
            zero_tile(x+1,y)
        end
    end
    if x<grid_width and y<grid_height
            and grid[x+1][y+1].is_tiled
            then
        reveal_tile(x+1,y+1)
        if grid[x+1][y+1].num_value == 0 then
            zero_tile(x+1,y+1)
        end
    end
    if y<grid_height
            and grid[x][y+1].is_tiled
            then
        reveal_tile(x,y+1)
        if grid[x][y+1].num_value == 0 then
            zero_tile(x,y+1)
        end
    end
    if x-1>0 and y<grid_height
            and grid[x-1][y+1].is_tiled
            then
        reveal_tile(x-1,y+1)
        if grid[x-1][y+1].num_value == 0 then
            zero_tile(x-1,y+1)
        end
    end
end


-- does the animation
function change_explosions()
  for x=1,grid_width do
      for y=1,grid_height do
          if grid[x][y].is_bomb then
              local dt = time() - grid[x][y].explosion_t
              if dt > explosion_dur and grid[x][y].lose_sp != explosion_sp[#explosion_sp] then
                  grid[x][y].lose_sp += 1
                  grid[x][y].explosion_t = time()
              end
          end
      end
  end
end


--are the only tiles left, bombs?
function check_win()
    local win = true
    --are all tiles revealed except for bombs?
    for x=1,grid_width do
        for y=1,grid_height do
            if not grid[x][y].is_bomb and grid[x][y].is_tiled then --did not win
                win = false
                break
            end
        end
    end
    if(win) game_win()
end


--won the game!
function game_win()
    state = "win"
    --put flags on all bombs
    for x=1,grid_width do
        for y=1,grid_height do
            if grid[x][y].is_bomb then
                grid[x][y].is_flagged = true
            end
        end
    end
end


--place flag at cursor
function place_flag()
    if grid[grid_x][grid_y].is_flagged then
        grid[grid_x][grid_y].is_flagged = false
    elseif not grid[grid_x][grid_y].is_flagged
          and grid[grid_x][grid_y].is_tiled then
      grid[grid_x][grid_y].is_flagged = true
  else
      sfx(sfx_2)
  end
end


-- does the animation
function move_flags()
  for x=1,grid_width do
      for y=1,grid_height do
          if grid[x][y].is_flagged then
              local dt = time() - flag_t
              if dt > flag_dur then
                  if flag_wave_sp == flag_sp[#flag_sp] then
                      flag_wave_sp = flag_sp[1]
                  else
                      flag_wave_sp += 1
                  end
                  flag_t = time()
              end
          end
      end
  end
end
__gfx__
000000006666666566666655117001111111111d1111111d1111111d511881151111111d1111111d1111111d8111111811118841111882411111184100000000
000000006666666566666655170000111111111d1111111d1119911d1589985d1119911d1111111d1111111d1811118d11828841112882411182284100000000
007007006666666566666655000000011111111d1116611d119aa91d189aa98d119aa91d1116611d1111111d1181181d18828841182882418882284100000000
000770006666666566666655000000011115511d1166661d19a77a9d89a77a9819a77a9d1166661d1111111d1118811d18821141882111411882214100000000
000770006666666566666655000000011115511d1166661d19a77a9d89a77a9819a77a9d1166661d1111111d1118811d12111141111111411111114100000000
007007006666666566666655100000111111111d1116611d119aa91d189aa98d119aa91d1116611d1111111d1181181d11111141111111411111114100000000
000000006666666555555555110001111111111d1111111d1119911d1589985d1119911d1111111d1111111d1811118d11111141111111411111114100000000
00000000555555555555555511111111dddddddddddddddddddddddd5dd88dd5dddddddddddddddddddddddd8dddddd811111111111111111111111100000000
666666651111111d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
676767651616161d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
667676651161611d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
676767651616161d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
667676651161611d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
676767651616161d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666651111111d1111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555dddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00050000100500d050090500100001000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000e5500d5500f5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c55009550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003955038550385503855038550385503855038550385503855039550395503955039550395500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
