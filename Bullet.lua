Bullet = Class{}

BULLET_SPEED = 600

function Bullet:init(player)
    self.player = player
    
    if self.player.powerUp then
        (self.player.sound_effects['big_laser']:clone()):play()
        self.texture = love.graphics.newImage('graphics/bullet/bigBullet.png')
        self.x = self.player.x + 35
        self.y = self.player.y
    else
        self.player.sound_effects['normal_laser']:play()
        self.texture = love.graphics.newImage('graphics/bullet/smallBullet.png')
        self.x = self.player.x + 10
        self.y = self.player.y + 25
    end


    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()
end

function Bullet:update(dt)
    self.x = self.x + BULLET_SPEED * dt
    
    if self.x > self.player.map.right_edge + self.width then
        return true
    end
end

function Bullet:render()
    love.graphics.draw(self.texture, self.x, self.y, math.rad(90))
end