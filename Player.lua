require 'Bullet'
require 'TopBullet'
require 'BotBullet'
require 'Enemy'
require 'Asteroid'
require 'Animation'
require 'Upgrade'

Player = Class{}

function Player:init(map)
    -- spaceship texture
    self.texture = love.graphics.newImage('graphics/player/playerBlue.png')

    -- starting point 
    self.xStart = 80
    self.yStart = 360

    self.x = self.xStart
    self.y = self.yStart

    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()

    self.map = map

    self.speed = 500
    self.speed_diagonal = 250

    -- table which stores all bullets objects
    self.bullets = {}

    self.can_fire = true
    self.bullet_timer = 0.2
    self.bullet_delay = 0.315

    -- table which stores all enemies objects
    self.enemies = {}

    self.enemy_spawnTimer = 0
    self.enemy_spawnDelay = 1

    -- table which stores all asteroid objects
    self.asteroids = {}

    self.asteroid_spawnTimer = 0
    self.asteroid_spawnDelay = 6

    -- table which stores all explosions
    self.explosions = {}

    -- table which stores all upgrades
    self.upgrades = {}

    -- chance to drop upgrades
    self.upgrade_probability = 10

    self.powerUp = false
    self.powerUp_timer = 0

    self.triple_shot = false
    self.triple_shot_timer = 0

    self.shield = false
    self.shield_timer = 0
    self.shield_texture = love.graphics.newImage('graphics/shield/shield.png')

    -- sound effects
    self.sound_effects = {
        ['normal_laser'] = love.audio.newSource('sounds/sound_effects/laser.wav', 'static'),
        ['big_laser'] = love.audio.newSource('sounds/sound_effects/laser2.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/sound_effects/explosion.wav', 'static'),
        ['upgrade'] = love.audio.newSource('sounds/sound_effects/upgrade.wav', 'static'),
        ['game_over'] = love.audio.newSource('sounds/sound_effects/gameOver.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/sound_effects/hit.wav', 'static')
    }

    -- adjusting effect's volume
    self.sound_effects['big_laser']:setVolume(0.2)
    self.sound_effects['explosion']:setVolume(0.3)
end

function Player:update(dt)
    self:movement(dt)
    self:shoot(dt)
    self:update_bullets(dt)
    self:update_asteroids(dt)
    self:update_enemies(dt)
    self:update_explosions(dt)
    self:update_upgrades(dt)
    self:update_timers(dt)
    self:update_difficulty()
    self:check_collisions()
end

function Player:render()
    -- render shield texture around player
    if self.shield then love.graphics.draw(self.shield_texture, self.x - self.width, self.y) end

    -- render player
    love.graphics.draw(self.texture, self.x, self.y, math.rad(90))
    
    -- render asteroids
    for _, asteroid in ipairs(self.asteroids) do
        asteroid:render()
    end
    
    --render upgrades
    for _, upgrade in ipairs(self.upgrades) do
        upgrade:render()
    end  

    -- render bullets
    for _, bullet in ipairs(self.bullets) do
        bullet:render()
    end

    -- render enemies
    for _, enemy in ipairs(self.enemies) do
        enemy:render()
    end

    -- render the current frame of each animation
    for _, explosion in ipairs(self.explosions) do
        love.graphics.draw(explosion:getCurrentFrame(), explosion.x, explosion.y)
    end
end

function Player:movement(dt)
    -- keyboard input for movement

    local up = love.keyboard.isDown('w')
    local down = love.keyboard.isDown('s')
    local right = love.keyboard.isDown('d')
    local left = love.keyboard.isDown('a')

    if down and right then
        self.x = self.x + self.speed_diagonal * dt
        self.y = self.y + self.speed_diagonal * dt
    elseif down and left then
        self.x = self.x - self.speed_diagonal * dt
        self.y = self.y + self.speed_diagonal * dt
    elseif up and right then
        self.x = self.x + self.speed_diagonal * dt
        self.y = self.y - self.speed_diagonal * dt
    elseif up and left then
        self.x = self.x - self.speed_diagonal * dt
        self.y = self.y - self.speed_diagonal * dt
    elseif down then
        self.y = self.y + self.speed * dt
    elseif up then
        self.y = self.y - self.speed * dt
    elseif left then
        self.x = self.x - self.speed * dt
    elseif right then
        self.x = self.x + self.speed * dt
    end

    -- avoid getting out from map limits
    if self.x - self.width < self.map.left_edge then self.x = self.map.left_edge + self.width end
    if self.x > self.map.right_edge then self.x = self.map.right_edge end
    if self.y < self.map.top_edge then self.y = self.map.top_edge end
    if self.y > self.map.bottom_edge then self.y = self.map.bottom_edge end
end

function Player:shoot(dt)
    if love.keyboard.isDown('space') then
        if self.can_fire then

            if self.triple_shot then
                -- add three different bullets objects to our bullets table for triple shot
                top_bullet = TopBullet(self)
                bullet = Bullet(self)
                bot_bullet = BotBullet(self)
                table.insert(self.bullets, top_bullet)
                table.insert(self.bullets, bullet)
                table.insert(self.bullets, bot_bullet)
            else
                -- add a single bullet object to our bullets table for normal shot
                bullet = Bullet(self)
                table.insert(self.bullets, bullet)
            end
            
            -- reset the timer to delay shots
            self.can_fire = false
            self.bullet_timer = self.bullet_delay
        end
    end

    if self.bullet_timer > 0 then
        self.bullet_timer = self.bullet_timer - dt
    else
        self.can_fire = true
    end 
end

function Player:check_collisions()
    -- collision checking between player and asteroids
    for i, asteroid in ipairs(self.asteroids) do
        if collides(self, asteroid) or collides(asteroid, self) then
            self:create_explosion(asteroid.x - asteroid.width / 2, asteroid.y - asteroid.height / 2)
            table.remove(self.asteroids, i)
            if self.shield == false then 
                LIVES = LIVES - 1
                self.sound_effects['hit']:play()
                self.x = 80 
                self.y = 360
                self.shield = true
                self.shield_timer = 1.5
            end
        end
        -- collision checking between asteroids and bullets
        for k, bullet in ipairs(self.bullets) do
            if collides(bullet, asteroid) or collides(asteroid, bullet) then
                table.remove(self.bullets, k)
                if self.powerUp then 
                    table.remove(self.asteroids, i)
                    self:create_explosion(asteroid.x - asteroid.width / 2, asteroid.y - asteroid.height / 2)
                    SCORE = SCORE + 100
                end
            end
        end
    end
    -- collision checking between player and enemies
    for i, enemy in ipairs(self.enemies) do
        if collides(self, enemy) or collides(enemy, self) then
            self:create_explosion(enemy.x - enemy.width, enemy.y)
            table.remove(self.enemies, i)

            if self.shield == false then 
                LIVES = LIVES - 1
                self.sound_effects['hit']:play()
                self.x = self.xStart
                self.y = self.yStart
                self.shield = true
                self.shield_timer = 1.5
            end
        end
        --collision checking between bullets and enemies
        for j, bullet in ipairs(self.bullets) do
            if collides(enemy, bullet) or collides(bullet, enemy) then
                table.remove(self.enemies, i)
                table.remove(self.bullets, j)
                self:create_explosion(enemy.x - enemy.width, enemy.y)
                if self.powerUp then 
                    SCORE = SCORE + 300
                else
                    SCORE = SCORE + 150
                end
                -- chance to drop an upgrade object 
                if math.random(self.upgrade_probability) == 1 then self:create_upgrade(enemy.x - enemy.width, enemy.y) end
            end
        end
    end
    -- collision checking between player and upgrades
    for i, upgrade in ipairs(self.upgrades) do
        if collides(self, upgrade) or collides(upgrade, self) then
            upgrade:effect()
            table.remove(self.upgrades, i)
        end
    end

    -- check for player's death
    if LIVES < 0 then
        self.sound_effects['game_over']:play()
        GAME_STATE = 'restart' 
    end

end

function collides(obj1, obj2)
    if (obj1.x < obj2.x and obj1.x + obj1.width > obj2.x and
        obj1.y < obj2.y and obj1.y + obj1.height > obj2.y)  or 
        (obj1.x - obj1.width < obj2.x + obj2.width and obj1.x > obj2.x and
        obj1.y < obj2.y and obj1.y + obj1.height > obj2.y) then
        return true
    else
        return false
    end
end

function Player:update_asteroids(dt)
    if self.asteroid_spawnTimer > 0 then
        self.asteroid_spawnTimer = self.asteroid_spawnTimer - dt
    else
        self:spawn_asteroid()
    end

    for i, asteroid in ipairs(self.asteroids) do
        asteroid:update(dt)
        if asteroid.x < self.map.left_edge - asteroid.width then
            table.remove(self.asteroids, i)
        end
    end
end

function Player:spawn_asteroid()
    asteroid = Asteroid(self.map, math.random(4))

    table.insert(self.asteroids, asteroid)
    self.asteroid_spawnTimer = self.asteroid_spawnDelay
end

function Player:update_enemies(dt)
    if self.enemy_spawnTimer > 0 then
        self.enemy_spawnTimer = self.enemy_spawnTimer - dt
    else
        self:spawn_enemy()
    end

    for i, enemy in ipairs(self.enemies) do
        enemy:update(dt)
        if enemy.x < self.map.left_edge - enemy.width then
            -- punishes the player for letting enemies escape
            if SCORE >= 100 then
                SCORE = SCORE - 100
            else
                SCORE = 0
            end
            table.remove(self.enemies, i)
        end
    end
end

function Player:spawn_enemy()
    enemy = Enemy(self.map, math.random(2), self)

    table.insert(self.enemies, enemy)
    self.enemy_spawnTimer = self.enemy_spawnDelay   
end

function Player:update_bullets(dt)
    for index, bullet in ipairs(self.bullets) do
        -- update all bullets and if they are past the screen, remove them
        if bullet:update(dt) then table.remove(self.bullets, index) end
    end
end
    
function Player:update_explosions(dt)
    for index, explosion in ipairs(self.explosions) do
        explosion:update(dt)
        if explosion.cycle_completed then
            table.remove(self.explosions, index)
        end
    end
end

function Player:create_explosion(x, y)
    explosion = Animation({frames = {
        -- all frames required to create the explosion animation 
        love.graphics.newImage('graphics/explosions/explosion1.png'),
        love.graphics.newImage('graphics/explosions/explosion2.png'),
        love.graphics.newImage('graphics/explosions/explosion3.png'),
        love.graphics.newImage('graphics/explosions/explosion4.png'),
        love.graphics.newImage('graphics/explosions/explosion5.png'),
        love.graphics.newImage('graphics/explosions/explosion6.png'),
        love.graphics.newImage('graphics/explosions/explosion7.png'),
        love.graphics.newImage('graphics/explosions/explosion8.png'),
        love.graphics.newImage('graphics/explosions/explosion9.png'),
        love.graphics.newImage('graphics/explosions/explosion9.png'),
    }, interval = 0.027, xPos = x - 3, yPos = y,
    sound = self.sound_effects['explosion']:clone()})
    table.insert(self.explosions, explosion)
end

function Player:update_upgrades(dt)
    for index, upgrade in ipairs(self.upgrades) do
        upgrade:update(dt)
        if upgrade.x + upgrade.width < 0 then
            table.remove(self.upgrades, index)
        end
    end
end

function Player:create_upgrade(x, y)
    upgrade = Upgrade(self, self.map, math.random(7), x, y)
    table.insert(self.upgrades, upgrade)
end

function Player:update_timers(dt)
    self.shield_timer = self.shield_timer - dt
    if self.shield_timer <= 0 then 
        self.shield = false 
    end

    self.powerUp_timer = self.powerUp_timer - dt
    if self.powerUp_timer <= 0 then 
        self.powerUp = false
    end

    self.triple_shot_timer = self.triple_shot_timer - dt
    if self.triple_shot_timer <= 0 then 
        self.triple_shot = false 
        self.bullet_delay = 0.315
    end

end

function Player:update_difficulty()
    -- increase difficulty as score goes up

    if SCORE > 50000 then
        self.enemy_spawnDelay = 0.1
        self.asteroid_spawnDelay = 1
        self.upgrade_probability = 20
        CAM_SPEED = 275
    elseif SCORE > 40000 then
        self.enemy_spawnDelay = 0.2
        self.asteroid_spawnDelay = 2
        self.upgrade_probability = 18
        CAM_SPEED = 250
    elseif SCORE > 30000 then
        self.enemy_spawnDelay = 0.4
        self.asteroid_spawnDelay = 3
        self.upgrade_probability = 16
        CAM_SPEED = 225
    elseif SCORE > 20000 then
        self.enemy_spawnDelay = 0.6
        self.asteroid_spawnDelay = 4
        self.upgrade_probability = 14
        CAM_SPEED = 200
    elseif SCORE > 10000 then
        self.enemy_spawnDelay = 0.8
        self.asteroid_spawnDelay = 5
        self.upgrade_probability = 12
        CAM_SPEED = 175
    end
end