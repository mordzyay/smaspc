local m = {}

local collisionpos = {
	{8, 3}, --head
	{3, 16}, --lfoot
	{12, 16}, --rfoot
	{2, 8}, --lside
	{13, 8}, --rside
}

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function m:New(o)
    o = o or {
        x = 0,
        y = 0,
    }
	o["w"] = 16
	o["h"] = 16
	o["xs"] = -1
	o["ys"] = 0

    setmetatable(o, self)
    self.__index = self

    return o
end

function m:remove()
    for i,v in pairs(self) do
        v = nil
    end
    self = nil
end

--COLLISION STARTS HERE
function m:footcol()
	local lc = Game.world:getTile(self.x+collisionpos[2][1], self.y+collisionpos[2][2])
	local rc = Game.world:getTile(self.x+collisionpos[3][1], self.y+collisionpos[3][2])
	
	if lc == nil or rc == nil then
		self:sidecol()
		return
	end
	
	if not (self.ys > 0) then
		self:sidecol()
		return
	end
	
	--we do this TWICE for BOTH tile AAGHHGH
	local function checktile(t)
		if t < 1 then
			return
		end
		self.y = math.floor(self.y/16)*16
		self.ys = 0
	end
	checktile(lc)
	checktile(rc)
	self:sidecol()
end
function m:sidecol()
	local function gettile(x, y)
		local c = Game.world:getTile(x, y)
		if c == nil then return nil, nil end
		return c, c > 0
	end
	
	if self.xs > 0 then
		local t, c = gettile(self.x+collisionpos[5][1], self.y+collisionpos[5][2])
		if c then
			self.x = self.x - 1
			self.xs = -self.xs
		end
	end
	if self.xs < 0 then
		local t, c = gettile(self.x+collisionpos[4][1], self.y+collisionpos[4][2])
		if c then
			self.x = self.x + 1
			self.xs = -self.xs
		end
	end
end
function m:headcol()
	local tc = Game.world:getTile(self.x+collisionpos[1][1], self.y+collisionpos[1][2])
	
	if tc == nil then
		return
	end
	
	if not (self.ys < 0) then
		return
	end
	
	--we do this TWICE for BOTH tile AAGHHGH
	local function checktile(t)
		if t < 1 then
			return
		end
		--self.y = math.floor((self.y+16)/16)*16
		self.ys = 1
	end
	checktile(tc)
end
function m:collision()
	--onscreen check
	self:headcol()
	self:footcol()
	self:sidecol()
end

--COLLISION ENDS HERE

function m:update(dt)
	local gravity = 0.3
	self.ys = self.ys + gravity
    self.x = self.x + self.xs
    self.y = self.y + self.ys
	self:collision()
end

local newColors = {
    {0,0,0,0},
    {32/255,32/255,32/255,1},
    {1,217/255,178/255,1},
    {186/255,97/255,17/255,1}
}

function m:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader(nesShader)
	sendPalette(newColors)
	drawSprite(sprites.goomba[1], self.x, self.y, false, false)
	love.graphics.setShader()
end

return m