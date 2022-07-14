-- These two files should be included in the same folder as this script
PATH = debug.getinfo(1).source:sub(2):match("(.*\\)")
dofile (PATH .. "IndexToRNG_Table.lua")
dofile (PATH .. "RNGToIndex_Table.lua")

-- Replace 'filename' with the name of the savestate you're working with
local filename = "YOUR_SAVESTATE_HERE.st"
local file = (PATH .. filename)

function get_index(rng_val)
	return RNGToIndex[rng_val + 1]
end

function get_rng(index)
	return IndexToRNG[index + 1]
end

-- RNG value to start with (0 if you're starting from the beginning)
local cur_rng_val = 0

-- Optional: RNG value to end at (useful if you're running multiple
-- Mupen instances and want to avoid overlap; set to -3 to bypass)
local last_rng_val = 5000
local complete = false
local last_rng_val = last_rng_val + 1

-- If you have an RNG index you want to start with, rather than an value,
-- uncomment the line below, and fill in the function with your RNG index;
-- the value will print in the Lua dialog box
-- print("The value of your index is: " .. get_rng(0))

local timer = 0

local RNG_addr = 0x00B8EEE0
-- These two addresses are for the US version only
local coins = 0x00B3B218
local stars = 0x00B3B21A

local name = "Successful RNG Values & Indices - '" .. filename .. "'.txt"
local txt = io.open(name,"a")
txt:close()

-- Unreachable_RNG_Values.txt should be included in the same folder as this script
local badList = {}
for line in io.lines("Unreachable_RNG_Values.txt") do
    badList[tonumber(line)] = true
end

function main()
	if (cur_rng_val == last_rng_val) then
		complete = true
		print("Testing Complete")
		goto done
	elseif (badList[cur_rng_val] == true) then
		print("Skipped Unreachable RNG Value\n")
		cur_rng_val = cur_rng_val + 1
		goto done
	elseif (timer == 0) then
		savestate.loadfile(file)
	elseif (timer == 1) then
		memory.writeword(RNG_addr, cur_rng_val)

	-- 'timer' here should equal a frame count (after the savestate is loaded) at
	-- which the desired condition should be met if the RNG is successful (i.e. 
	-- if the star is collected or the coin count is reached)
	elseif (timer == 745) then
		if (memory.readword(stars) == 74) then
            cur_rng_ind = get_index(cur_rng_val)
			print ("RNG Val: " .. cur_rng_val .. ", RNG Index: " .. cur_rng_ind .. "\n")
			local txt=io.open(name,"a")
			txt:write("RNG Val: " .. cur_rng_val .. ", RNG Index: " .. cur_rng_ind .. "\n")
			txt:close()
		end
		timer = -1
		cur_rng_val = cur_rng_val + 1
	end
	timer = timer + 1
	::done::
end

function draw()
	wgui.setfont(12,"Arial","")
	wgui.setcolor("black")
	wgui.setbrush("white")
	wgui.setpen("white")
	wgui.setbk("white")
	
	wgui.text(0,0,"Currently testing value: " .. cur_rng_val)
end

if not (complete) then
	emu.atinput(main)
	emu.atvi(draw)
end
emu.atstop(emu.pause())