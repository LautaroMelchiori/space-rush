Animation = Class{}

function Animation:init(params)

    self.x = params.xPos
    self.y = params.yPos

    -- images defining this animation
    self.frames = params.frames or {}

    self.interval = params.interval

    -- stores amount of time that has elapsed
    self.timer = 0

    self.currentFrame = 1

    self.sound = params.sound
    
    -- a flag to check if a full animation cycle has been completed
    self.cycle_completed = false 

    self.sound:play()
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    -- iteratively subtract interval from timer to proceed in the animation,
    -- in case we skipped more than one frame
    while self.timer > self.interval do
        self.timer = self.timer - self.interval
        self.currentFrame = (self.currentFrame + 1) % #self.frames
        if self.currentFrame == 0 then 
            self.currentFrame = 1 
            self.cycle_completed = true
        end
    end
end
