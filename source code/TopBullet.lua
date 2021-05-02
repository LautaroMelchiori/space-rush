--Complementary object to make the triple shot possible

TopBullet = Class{}

function TopBullet:init(player)
    self.player = player

    if player.powerUp then
        self.texture = love.graphics.newImage('graphics/bullet/bigBullet.png')
        self.x = self.player.x + 35
        self.y = self.player.y
    else
        self.texture = love.graphics.newImage('graphics/bullet/smallBullet.png')
        self.x = self.player.x + 10
        self.y = self.player.y + 25
    end


    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()
end

function TopBullet:update(dt)
    self.x = self.x + BULLET_SPEED * dt
    self.y = self.y - 60 * dt
    if self.x > self.player.map.right_edge + self.width then
        return true
    end
end

function TopBullet:render()
    love.graphics.draw(self.texture, self.x, self.y, math.rad(90))
end