Map = Class{}

function Map:init()
    self.player = Player(self)

    self.top_edge = 0
    self.left_edge = 0
    self.right_edge = 1368
    self.bottom_edge = 700

end

function Map:update(dt)
    self.player:update(dt)
end

function Map:render()
    self.player:render()
end