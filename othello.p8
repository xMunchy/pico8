pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
   --make pink transparent
	  palt(0,false)
	  palt(15,true)
	  mode = "title"

	  board = {}
		free = 8*8-4 --open spaces
		flipping_dur = 0.1 --for cats
		-- flipping_dur = 0.05 --for tokens
		flipping_t = 0
	  for x=1,8 do
	     board[x] = {}
	     for y=1,8 do
	         board[x][y] = {}
					 board[x][y].flip_prog = 0
					 board[x][y].is_flipping = false
	     end
	  end

		--transition sprites
		p1_to_p2 = {160,162,164,166,168,170,172,174} --cats
		p2_to_p1 = {128,130,132,134,136,138,140,142}
		-- p1_to_p2 = {64,66,68,70,72,74,76,78} --tokens
		-- p2_to_p1 = {96,98,100,102,104,106,108,110}
	 --sprite id for p1 and p2
	 p = {7,9} --cats
	 -- p = {3,5} --tokens
   player = flr(rnd(2)) --whose turn? p1 = 0, p2 = 1
   side = p[player+1]
	 button = {40,39} --sprite id for p1/p2 buttons
   --position of curson
   x = 1
   y = 1

   --set up board
   board[4][4].side = p[1]
   board[4][5].side = p[2]
   board[5][4].side = p[2]
   board[5][5].side = p[1]
--   board[6][6] = 5
--   board[4][6] = 5
--   board[5][3] = 5
--   board[3][3] = 5
end

function _update60()
	if mode=="title" then
		if btnp(5) then
			mode = "game"
		end
	elseif mode=="game" then
	   if btnp(0) then --left
	      if(x>1) x -= 1
	   end
	   if btnp(1) then --right
	      if(x<8) x += 1
	   end
	   if btnp(2) then --up
	      if(y>1) y -= 1
	   end
	   if btnp(3) then --down
	      if(y<8) y += 1
	   end
	   if btnp(5) then --place token
			 dir = get_dir(x,y)
				if #dir > 0 then
	          place_token(dir)
						if game_is_over() then
							game_over()
						end
	      end
	   end
		 flip_timer()
	 elseif mode=="game over" then
		 flip_timer()
		 if btnp(5) then
			 _init()
		 end
	 end
end

function _draw()
	if mode=="title" then
		cls()
		print("othello",50,60,7)

	elseif mode == "game" then
		cls()
		map(0,0,0,0)
		--display board
		show_tokens()
		--display selection
		if #get_dir(x,y)>0 then
			rect((x-1)*16,(y-1)*16,x*16,y*16,11)
			spr(button[player+1],(x-1)*16-2,(y-1)*16-2)
		else
			rect((x-1)*16,(y-1)*16,x*16,y*16,8)
		end
		spr(side,(x-1)*16,(y-1)*16,2,2)

	elseif mode == "game over" then
		cls()
		map(0,0,0,0)
		--display board
		show_tokens()
		if winner == 1 then --player 1
		   sspr(72,16,40,8,20,70,80,16)
		   sspr(56,0,16,16,32,10,64,64)
		elseif winner == 2 then --player 2
		   sspr(72,16,40,8,20,70,80,16)
		   sspr(72,0,16,16,32,10,64,64)
		else --tie
		   sspr(88,0,16,16,32,40,64,64)
		end
	end
end

function get_dir(x,y)
   local found_me = false --adjacent to my token
   local found_you = false --adjacent to your token
	 local directions = {}
   --already occupied
   if board[x][y].side then
      return {}
   end

   --check right side
	 local i = x+1
   while i<9 do
      if not board[i][y].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][y].side==side then --found me
         found_me = true
         break
      elseif board[i][y].side!=side then --found you
         found_you = true
      end
			i += 1
   end
   if found_me and found_you then
      directions[#directions+1] = "r"
		end
      found_me = false
      found_you = false

   --check left side
   local i = x-1
   while i>0 do
      if not board[i][y].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][y].side==side then --found me
         found_me = true
         break
      elseif board[i][y].side!=side then --found you
         found_you = true
      end
      i -= 1
   end
   if found_me and found_you then
      directions[#directions+1] = "l"
		end
      found_me = false
      found_you = false

   --check down
	 local i = y+1
   while i<9 do
      if not board[x][i].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[x][i].side==side then --found me
         found_me = true
         break
      elseif board[x][i].side!=side then --found you
         found_you = true
      end
			i += 1
   end
   if found_me and found_you then
      directions[#directions+1] = "d"
		end
		found_me = false
		found_you = false

   --check up
   local i = y-1
	 while i>0 do
      if not board[x][i].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[x][i].side==side then --found me
         found_me = true
         break
      elseif board[x][i].side!=side then --found you
         found_you = true
      end
			i -= 1
   end
   if found_me and found_you then
      directions[#directions+1] = "u"
		end
      found_me = false
      found_you = false

   --check left/down diagonal
   local i = x-1
   local j = y+1
   while i>0 and j<9 do
      if not board[i][j].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][j].side==side then --found me
         found_me = true
         break
      elseif board[i][j].side!=side then --found you
         found_you = true
      end
      i -= 1
      j += 1
   end
   if found_me and found_you then
      directions[#directions+1] = "ld"
   end
	 found_me = false
	 found_you = false

   --check right/down diagonal
   local i = x+1
   local j = y+1
   while i<9 and j<9 do
      if not board[i][j].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][j].side==side then --found me
         found_me = true
         break
      elseif board[i][j].side!=side then --found you
         found_you = true
      end
      i += 1
      j += 1
   end
   if found_me and found_you then
      directions[#directions+1] = "rd"
   end
    found_me = false
    found_you = false

   --check left/up diagonal
   local i = x-1
   local j = y-1
   while i>0 and j>0 do
      if not board[i][j].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][j].side==side then --found me
         found_me = true
         break
      elseif board[i][j].side!=side then --found you
         found_you = true
      end
      i -= 1
      j -= 1
   end
   if found_me and found_you then
      directions[#directions+1] = "lu"
		end
      found_me = false
      found_you = false

   --check right/up diagonal
   local i = x+1
   local j = y-1
   while i<9 and j>0 do
      if not board[i][j].side then --no same colored piece found
         found_me = false
         found_you = false
         break
      elseif board[i][j].side==side then --found me
         found_me = true
         break
      elseif board[i][j].side!=side then --found you
         found_you = true
      end
      i += 1
      j -= 1
   end
   if found_me and found_you then
      directions[#directions+1] = "ru"
   end

   return directions
end

function place_token(d)
	free -= 1
   board[x][y].side = side
   flip_all_tokens(d)
	 player = (player+1)%2
	 side = p[player+1]
	 x = 1
	 y = 1
end

function flip_all_tokens(d)
	--check right side
	local dir = false
	for a = 1,#d do
		if d[a]=="r" then
			dir = true
			break
		end
	end
	local i = x+1
	while dir and board[i][y].side != side do
		board[i][y].is_flipping = true
		board[i][y].flip_prog = 1
		board[i][y].change_to = player + 1
		board[i][y].side = side
		i += 1
	end

	--check left side
	local dir = false
	for a = 1,#d do
		if d[a]=="l" then
			dir = true
			break
		end
	end
	local i = x-1
	while dir and board[i][y].side != side do
		board[i][y].is_flipping = true
		board[i][y].flip_prog = 1
		board[i][y].change_to = player + 1
		board[i][y].side = side
		 i -= 1
	end

	--check down
	local dir = false
	for a = 1,#d do
		if d[a]=="d" then
			dir = true
			break
		end
	end
	local i = y+1
	while dir and board[x][i].side != side do
		board[x][i].is_flipping = true
		board[x][i].flip_prog = 1
		board[x][i].change_to = player + 1
		board[x][i].side = side
		 i += 1
	end

	--check up
	local dir = false
	for a = 1,#d do
		if d[a]=="u" then
			dir = true
			break
		end
	end
	local i = y-1
	while dir and board[x][i].side != side do
		board[x][i].is_flipping = true
		board[x][i].flip_prog = 1
		board[x][i].change_to = player + 1
		board[x][i].side = side
		 i -= 1
	end

	--check left/down diagonal
	local dir = false
	for a = 1,#d do
		if d[a]=="ld" then
			dir = true
			break
		end
	end
	local i = x-1
	local j = y+1
	while dir and board[i][j].side != side do
		board[i][j].is_flipping = true
		board[i][j].flip_prog = 1
		board[i][j].change_to = player + 1
		board[i][j].side = side
		 i -= 1
		 j += 1
	end

	--check right/down diagonal
	local dir = false
	for a = 1,#d do
		if d[a]=="rd" then
			dir = true
			break
		end
	end
	local i = x+1
	local j = y+1
	while dir and board[i][j].side != side do
		board[i][j].is_flipping = true
		board[i][j].flip_prog = 1
		board[i][j].change_to = player + 1
		board[i][j].side = side
		 i += 1
		 j += 1
	end

	--check left/up diagonal
	local dir = false
	for a = 1,#d do
		if d[a]=="lu" then
			dir = true
			break
		end
	end
	local i = x-1
	local j = y-1
	while dir and board[i][j].side != side do
		board[i][j].is_flipping = true
		board[i][j].flip_prog = 1
		board[i][j].change_to = player + 1
		board[i][j].side = side
		 i -= 1
		 j -= 1
	end

	--check right/up diagonal
	local dir = false
	for a = 1,#d do
		if d[a]=="ru" then
			dir = true
			break
		end
	end
	local i = x+1
	local j = y-1
	while dir and board[i][j].side != side do
		board[i][j].is_flipping = true
		board[i][j].flip_prog = 1
		board[i][j].change_to = player + 1
		board[i][j].side = side
		 i += 1
		 j -= 1
	end
end

function flip_timer()
	if time() >= flipping_t then
		flipping_t = time() + flipping_dur
		for x=1,8 do
			for y=1,8 do
				if board[x][y].is_flipping then
					board[x][y].flip_prog += 1
					if board[x][y].flip_prog>#p1_to_p2 then
						board[x][y].is_flipping = false
						board[x][y].flip_prog = 0
					end
				end
			end
		end
	end
end

function show_tokens()
	for x=1,8 do
		for y=1,8 do
			if board[x][y].is_flipping then --flip
				if board[x][y].change_to==1 then --player 1
					spr(p2_to_p1[board[x][y].flip_prog],(x-1)*16,(y-1)*16,2,2)
				else --player 2
					spr(p1_to_p2[board[x][y].flip_prog],(x-1)*16,(y-1)*16,2,2)
				end
			elseif board[x][y].side then --exists, not flippng
				spr(board[x][y].side,(x-1)*16,(y-1)*16,2,2)
			end
		end
	end
end

--check if game is over.
--game ends when no more spaces are left or
--when both players have no more valid moves
function game_is_over()
   --any more spaces?
   if free==0 then
		 return true
	 end
	 --any more valid moves?
	 no_valid = 0
	 for i=1,8 do
		 for j=1,8 do
			 if #get_dir(i,j)>0 then
				 no_valid = false
			 end
		 end
	 end
	 if no_valid then
		 player = (player+1)%2
		 side = p[player+1]
		 for i=1,8 do
			 for j=1,8 do
				 if #get_dir(i,j)>0 then
					 no_valid = false
					 break
				 end
			 end
		 end
	 end
	 return no_valid
end

function game_over()
	mode = "game over"
	local p1 = 0
	local p2 = 0
	for i=1,8 do
		for j=1,8 do
			if board[i][j].side and board[i][j].side==p[1] then
				p1 += 1
			elseif board[i][j].side and board[i][j].side==p[2] then
				p2 += 1
			end
		end
	end
	if p1>p2 then
		winner = 1
	elseif p2>p1 then
		winner = 2
	else --tie
		winner = 0
	end
end


__gfx__
000000003333333333333333ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
000000003333333333333333ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
0070070033e3333333333333ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
000770003eee333333333333ffffff000007ffffffffff777770ffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
0007700033e3333333333333fffff00000007ffffffff77777770ffffffff0fffff0fffffffff5fffff5fffffccc7ccc7cc7c7ff000000000000000000000000
007007003333333333333333ffff0005000007ffffff7776777770ffffff000fff000fffffff555fff555fffffc7ffc7fc7fc7ff000000000000000000000000
000000003333333333333333fff000500000007ffff777677777770fffff000000000fffffff5e55055e5fffffc7ffc7fcc7c7ff000000000000000000000000
0000000033333333333333b3fff000000000007ffff777777777770ffff00000000000fffff05555055550ffffc7ffc7fc7fffff000000000000000000000000
000000003333333333333333fff000000000007ffff777777777770fff0009000009000fff000a55755a000fffc7fccc7cc7c7ff000000000000000000000000
000000003333333333333333fff000000000007ffff777777777770ffff00000000000fffff55557e75555ffffffffffffffffff000000000000000000000000
000000003333333333333333ffff00000000077fffff77777777700fffff000000000fffffff555777555fffffffffffffffffff000000000000000000000000
000000003333333333333333fffff000000077fffffff777777700fffffff0000000fffffffff5777775ffffffffffffffffffff000000000000000000000000
0000000033b33333333c3333ffffff0000077fffffffff7777700fffffffff88888fffffffffff11111fffffffffffffffffffff000000000000000000000000
00000000333b333333ccc333fffffff77777fffffffffff00000ffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
0000000033333333333c3333ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
000000003333333333333333ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
00000000333333333333333333333333333333333333333333333333fcccccfffeeeeeff17ffff17111117117fff17117fff1711171111170000000000000000
00000000333333333333333333333333333333333333333333333333cc7c7ccfee7e7eef17ffff17ff17ff1717ff171717ff1717ff17ff170000000000000000
00000000333333333333a33333333333333333333333333333333333ccc7cccfeee7eeef17ffff17ff17ff17f17f1717f17f1717ff17ff170000000000000000
00000000333b3333333aaa3333333333333333333333333333333333cc7c7ccfee7e7eef17f17f17ff17ff17f17f1717f17f1711171111170000000000000000
00000000333333333333a33333333333333b3333333333d333333333fcccccfffeeeeeff17f17f17ff17ff17f17f1717f17f1717ff17f17f0000000000000000
000000003333333333333333333333333333333333333ddd33333333ffffffffffffffff17f17f17ff17ff17f17f1717f17f1717ff17ff170000000000000000
0000000033333333333333333333333333333333333333d333333333ffffffffffffffff17171717ff17ff17ff171717ff171717ff17ff170000000000000000
00000000333333333333333333333333333333333333333333333333fffffffffffffffff17ff17f11111717fff11717fff117111717ff170000000000000000
00000000333333333333333333333333333333333333333333333333f77777fff00000ffffffffffffffffff0000000000000000000000000000000000000000
0000000033333333c33333333333333333333333333333333333b3337707077f0070700fffffffffffffffff0000000000000000000000000000000000000000
000000003333333ccc3333333333333b3333333333333333333333337770777f0007000fffffffffffffffff0000000000000000000000000000000000000000
0000000033333333c3333333333333333333333333333333333333337707077f0070700fffffffffffffffff0000000000000000000000000000000000000000
000000003333333333333b3333333333333333333333333333333333f77777fff00000ffffffffffffffffff0000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333ffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333ffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333333333333ffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07fffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffff077fffffffffffff0077ffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffff077ffffffffffff00077ffffffffffff0077fffffffffffff007fffffffffffff007ffffffffffffffffffffff
ffffff000007fffffffffff0077ffffffffff00077ffffffffff005007ffffffffffff0077ffffffffffff00777fffffffffff00777ffffffffff0077fffffff
fffff00000007fffffffff000077ffffffff0050077fffffffff0500077fffffffffff0077ffffffffffff077677fffffffff0077677ffffffff007777ffffff
ffff0005000007fffffff05000077ffffff005000077ffffffff0000077fffffffffff0077fffffffffff0077767ffffffff007777677ffffff00777767fffff
fff000500000007fffff0500000077fffff000000077ffffffff0000077fffffffffff0077fffffffffff0077777ffffffff007777777fffff0077777767ffff
fff000000000007fffff0000000077fffff000000077ffffffff0000077fffffffffff0077fffffffffff0077777ffffffff007777777fffff0077777777ffff
fff000000000007fffff0000000077fffff000000077ffffffff0000077fffffffffff0077fffffffffff0077777ffffffff007777777fffff0077777777ffff
fff000000000007fffff0000000077fffff000000077ffffffff0000077fffffffffff0077fffffffffff0077777ffffffff007777777fffff0077777777ffff
ffff00000000077ffffff000000777ffffff0000077ffffffffff00077fffffffffffff07ffffffffffff0077777fffffffff0077777ffffff000777777fffff
fffff000000077ffffffff0000777ffffffff00077ffffffffffff077fffffffffffffffffffffffffffff00777fffffffffff00777ffffffff0007777ffffff
ffffff0000077ffffffffff00777ffffffffff077ffffffffffffffffffffffffffffffffffffffffffffff007fffffffffffff007ffffffffff00077fffffff
fffffff77777ffffffffffff777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000ffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff70fffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffff700fffffffffffff7700fffffffffffff770ffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffff700ffffffffffff77700ffffffffffff7700ffffffffffff77000ffffffffffff770ffffffffffffffffffffff
ffffff777770fffffffffff7700ffffffffff77700ffffffffff776770ffffffffffff7700ffffffffffff700500ffffffffff77000ffffffffff7700fffffff
fffff77777770fffffffff777700ffffffff7767700fffffffff7677700fffffffffff7700fffffffffff7700050fffffffff7700500ffffffff770000ffffff
ffff7776777770fffffff76777700ffffff776777700ffffffff7777700fffffffffff7700fffffffffff7700000ffffffff770000500ffffff77000050fffff
fff777677777770fffff7677777700fffff777777700ffffffff7777700fffffffffff7700fffffffffff7700000ffffffff770000000fffff7700000050ffff
fff777777777770fffff7777777700fffff777777700ffffffff7777700fffffffffff7700fffffffffff7700000ffffffff770000000fffff7700000000ffff
fff777777777770fffff7777777700fffff777777700ffffffff7777700fffffffffff7700fffffffffff7700000ffffffff770000000fffff7700000000ffff
fff777777777770fffff7777777700fffff777777700ffffffff7777700fffffffffff7700fffffffffff7700000ffffffff770000000fffff7700000000ffff
ffff77777777700ffffff777777000ffffff7777700ffffffffff77700fffffffffffff70fffffffffffff77000ffffffffff7700000ffffff777000000fffff
fffff777777700ffffffff7777000ffffffff77700ffffffffffff700ffffffffffffffffffffffffffffff770ffffffffffff77000ffffffff7770000ffffff
ffffff7777700ffffffffff77000ffffffffff700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff770ffffffffff77700fffffff
fffffff00000ffffffffffff000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777ffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffff5fffff5fffffffff5fffff5fffffffff5fffff5fffffffff5fffff5fffffffff5fffff5fffffffff5fffff5fffffffff0fffff0fffffffff0fffff0ffff
ffff555fff555fffffff555fff555fffffff555fff555fffffff555fff555fffffff555fff555fffffff555fff555fffffff000fff000fffffff000fff000fff
ffff5e55055e5fffffff5e55055e5fffffff5e55055e5fffffff5e55055e5fffffff5e55055e5fffffff000000000fffffff000000000fffffff000000000fff
fff05555055550fffff05555055550fffff05555055550fffff05555055550fffff00000000000fffff00000000000fffff00000000000fffff00000000000ff
ff000a55755a000fff000a55755a000fff000a55755a000fff000a55755a000fff0000000000000fff0000000000000fff0000000000000fff0009000009000f
fff55557e75555fffff55557e75555fffff55557e75555fffff00000000000fffff00000000000fffff00000000000fffff00000000000fffff00000000000ff
ffff555777555fffffff555777555fffffff000000000fffffff000000000fffffff000000000fffffff000000000fffffff000000000fffffff000000000fff
fffff5777775fffffffff0000000fffffffff0000000fffffffff0000000fffffffff0000000fffffffff0000000fffffffff0000000fffffffff0000000ffff
ffffff88888fffffffffff88888fffffffffff88888fffffffffff88888fffffffffff88888fffffffffff88888fffffffffff88888fffffffffff88888fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffff0fffff0fffffffff0fffff0fffffffff0fffff0fffffffff0fffff0fffffffff0fffff0fffffffff0fffff0fffffffff5fffff5fffffffff5fffff5ffff
ffff000fff000fffffff000fff000fffffff000fff000fffffff000fff000fffffff000fff000fffffff000fff000fffffff5e5fff5e5fffffff555fff555fff
ffff000000000fffffff000000000fffffff000000000fffffff000000000fffffff555555555fffffff555505555fffffff555505555fffffff5e55055e5fff
fff00000000000fffff00000000000fffff00000000000fffff00000000000fffff05555555550fffff05555055550fffff05555055550fffff05555055550ff
ff0009000009000fff0009000009000fff0009000009000fff0009007009000fff0005557555000fff0005557555000fff0005557555000fff000a55755a000f
fff00000000000fffff00000000000fffff00000700000fffff55557e75555fffff55557e75555fffff55557e75555fffff55557e75555fffff55557e75555ff
ffff000000000fffffff000000000fffffff555777555fffffff555777555fffffff555777555fffffff555777555fffffff555777555fffffff555777555fff
fffff0000000fffffffff0777770fffffffff5777775fffffffff5777775fffffffff5777775fffffffff5777775fffffffff5777775fffffffff5777775ffff
ffffff11111fffffffffff11111fffffffffff11111fffffffffff11111fffffffffff11111fffffffffff11111fffffffffff11111fffffffffff11111fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__map__
0102010201020102010201020102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112111211121112232411121121221200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010201020102333425260131320200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112111221221112111235361112111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102252631320102252601020102252600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112353611121112353611212212353600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102232401252602012324313202010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112333411353612113334121112232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526012122020123242324020102333400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3536113132121133343334122526111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102012324020102012122023536240200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112113334121112113132121133341200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0123240201020125260201022122010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1133341221221135361211123132252600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010231320133342323242402353600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112111211121112113333343412111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
