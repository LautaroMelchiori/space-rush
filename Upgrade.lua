Upgrade = Class{}

function Upgrade:init(player, map, type, x, y)
    self.player = player
    self.map = map
    self.type = type
    if self.type == 1 or self.type == 2 then
        self.texture = love.graphics.newImage('graphics/upgrades/powerUp.png')
        self.type = 'powerUp'
    elseif self.type == 3 or self.type == 4 then
        self.texture = love.graphics.newImage('graphics/upgrades/shield.png')
        self.type = 'shield'
    elseif self.type == 5 or self.type == 6 then
        self.texture = love.graphics.newImage('graphics/upgrades/tripleShot.png')
        self.type = 'triple_shot'
    else
        self.texture = love.graphics.newImage('graphics/upgrades/healthUp.png')
        self.type = 'healthUp'
    end

    self.width = self.texture:getWidth() - 20
    self.height = self.texture:getHeight() + 5
    self.x = x + self.width / 2
    self.y = y + self.height / 2
end

function Upgrade:update(dt)
    self.x = self.x - CAM_SPEED * dt
end

function Upgrade:render()
    love.graphics.draw(self.texture, self.x, self.y)
end

function Upgrade:effect()
    if self.type == 'powerUp' then 
        self.player.powerUp = true
        self.player.powerUp_timer = 15

    elseif self.type == 'shield' then 
        self.player.shield = true
        self.player.shield_timer = 10

    elseif self.type == 'triple_shot' then
        self.player.triple_shot = true
        self.player.triple_shot_timer = 15
        self.player.bullet_delay = 0.5
    else
        -- else the upgrade is the health up
        LIVES = LIVES + 1 
    end 
    self.player.sound_effects['upgrade']:play()
end