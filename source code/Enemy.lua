Enemy = Class{}

function Enemy:init(map, type, player)
    self.map = map
    self.type = type
    self.player = player
    if SCORE < 10000 then 
        self.speed = 600
    elseif SCORE < 20000 then
        self.speed = 800
    else
        self.speed = 1000
    end

    if self.type == 1 then 
        self.texture = love.graphics.newImage('graphics/enemies/enemy11.png')
    else
        self.texture = love.graphics.newImage('graphics/enemies/enemy22.png')
    end
    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()
    self.x = self.map.right_edge + self.width
    self.y = math.random(0, self.map.bottom_edge)
end

function Enemy:update(dt)
    if self.type == 1 then
        self.x = self.x - self.speed * dt
    else
        self:moveToPlayer(dt)
    end
end

function Enemy:render()
    love.graphics.draw(self.texture, self.x, self.y, math.rad(90))
end

function Enemy:moveToPlayer(dt)
    local xSpeed = math.sin(math.rad (60)) * self.speed / 2
    local ySpeed = math.cos(math.rad (60)) * self.speed / 2

    if (self.y - self.player.y) > 7 then
        self.y = self.y - ySpeed * dt
        self.x = self.x - xSpeed * dt
    elseif (self.y - self.player.y) < -7 then
        self.y = self.y + ySpeed * dt
        self.x = self.x - xSpeed * dt
    else
        self.x = self.x - self.speed / 2 * dt
    end
end