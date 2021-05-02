Asteroid = Class{}

function Asteroid:init(map, type)
    self.map = map
    if type == 1 then 
        self.texture = love.graphics.newImage('graphics/asteroids/asteroid1.png')
    elseif type == 2 then 
        self.texture = love.graphics.newImage('graphics/asteroids/asteroid2.png')
    elseif type == 3 then 
        self.texture = love.graphics.newImage('graphics/asteroids/asteroid3.png')
    else 
        self.texture = love.graphics.newImage('graphics/asteroids/asteroid4.png')
    end

    self.x = self.map.right_edge
    self.y = math.random(0, self.map.bottom_edge)
    self.width = self.texture:getWidth() - 20
    self.height = self.texture:getHeight() 
end

function Asteroid:update(dt)
    self.x = self.x - CAM_SPEED * dt
end

function Asteroid:render()
    love.graphics.draw(self.texture, self.x, self.y)
end