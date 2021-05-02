Class = require 'class'

require 'Player'
require 'Map'

WINDOW_WIDTH = 1368
WINDOW_HEIGHT = 774
CAM_SPEED = 150
GAME_STATE = 'title_screen'
LIVES = 2
SCORE = 0
DIFFICULTY = 1

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    font = love.graphics.newFont('fonts/font1.TTF', 48)
    small_font = love.graphics.newFont('fonts/font1.TTF', 32)
    big_font = love.graphics.newFont('fonts/font1.TTF', 96)

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true
    })

    background_image = love.graphics.newImage("graphics/background/space_sprite.png")
    camera_x = 0

    love.mouse.setCursor(love.mouse.newCursor('graphics/cursor/cursor1.png', 5, 1))

    title_screen_music = love.audio.newSource('sounds/music/music2.wav', 'stream')
    playing_music = love.audio.newSource('sounds/music/music.wav', 'stream')
    restart_screen_music = love.audio.newSource('sounds/music/music2.wav', 'stream')

    playing_music:setVolume(0.6)
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.quit() 
    end
    camera_x = camera_x + CAM_SPEED * dt
    if  GAME_STATE == 'playing' then
        map:update(dt) 
    end
end

function love.draw()
    scroll_background()
    love.graphics.print(tostring(love.timer.getFPS()), 5, 5)
    if  GAME_STATE == 'playing' then
        love.graphics.setFont(small_font)
        love.graphics.print('Lives: '..LIVES, 1180, 734)
        love.graphics.print('Score: '..SCORE, 10, 734)
        map:render()

        love.audio.stop(title_screen_music)
        playing_music:play()
    elseif GAME_STATE == 'restart' then
        display_restartScreen()
    else 
        display_titleScreen()
    end
end

function scroll_background()
    local w, h = background_image:getDimensions()
    local start_x = (- camera_x % w) - w
    local tile_x = math.ceil(love.graphics.getWidth() / w)
    local tile_y = math.ceil(love.graphics.getHeight() / h)
    for i = 0, tile_x do
        for j = 0, tile_y do
            love.graphics.draw(background_image, start_x + i * w, j * h)
        end
    end
end

function display_titleScreen()
    love.graphics.printf('SPACE RUSH', big_font, 225, 200, 10000)
    love.graphics.printf('PRESS ENTER TO START',small_font,350, 500, 10000)
    if love.keyboard.isDown('return') then
        map = Map()
        GAME_STATE = 'playing'
    end

    title_screen_music:setLooping(true)
    title_screen_music:setVolume(0.6)
    title_screen_music:play()
end

function display_restartScreen()
    love.audio.stop(playing_music)
    love.graphics.printf('GAME OVER', font, 450, 200, 10000, 'left')
    love.graphics.printf(' SCORE: '.. SCORE, font, 430, 300, 10000, 'left')
    if love.keyboard.isDown('return') then
        map = Map()
        LIVES = 2
        SCORE = 0
        GAME_STATE = 'playing'
    end
end