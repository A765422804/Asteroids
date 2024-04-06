---@diagnostic disable: lowercase-global
lunajson = require("lunajson")

-- 创建全局变量
ASTEROID_SIZE = 100
SHOW_DEBUGGING = false
DESTROY_AST = false
MOUSE_RADIUS = 10
-- 建立一个枚举变量，表示爆炸状态
EXPLOADING = {
    not_exploading = 0,
    exploading = 1,
    done_exploading = 2
}

function calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2);
end

function readJSON(file_name)
    local file = io.open("src/data/" .. file_name .. ".json","r")
    local data = file:read("a")
    file:close()

    return lunajson.decode(data) -- 转换json
end

function writeJSON(file_name,data)
    local file = io.open("src/data/" .. file_name .. ".json","w")
    file:write(lunajson.encode(data))
    file:close()
end

readJSON("save")