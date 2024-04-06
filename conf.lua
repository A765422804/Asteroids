---@diagnostic disable: lowercase-global
love = require("love")

function love.conf(app)
    -- 16:9
    app.window.width = 1280
    app.window.height = 720
    app.window.title = "Asteroids"
    app.window.display = 1
end