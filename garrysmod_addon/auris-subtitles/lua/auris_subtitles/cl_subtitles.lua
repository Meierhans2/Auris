local RNDX     = include("auris_subtitles/rndx.lua")
local LIFETIME   = 3.0
local FADE_START = 2.5

---@type table<GEntity, table[]>
local subtitles = {}

local FONT_WORLD = "AurisSubtitle_World"
surface.CreateFont(FONT_WORLD, {
    font      = "Roboto",
    size      = 18,
    weight    = 300,
    antialias = true,
})

---@param ply Player
---@param text string
local function onSubtitle(ply, text)
    if not IsValid(ply) then return end
    local stack = subtitles[ply]
    if not stack then stack = {} subtitles[ply] = stack end
    stack[#stack + 1] = { text = text, spawnTime = RealTime() }
end

net.Receive("auris_subtitle", function()
    local ply  = net.ReadEntity()
    local text = net.ReadString()
    if not IsValid(ply) then return end
    if #text > 150 then text = string.sub(text, 1, 147) .. "..." end
    onSubtitle(ply, text)
end)

---@param text string
---@return string[]
local function wrapWords(text)
    local lines, words, count = {}, {}, 0
    for word in text:gmatch("%S+") do
        words[#words + 1] = word
        count = count + 1
        if count == 6 then
            lines[#lines + 1] = table.concat(words, " ")
            words, count = {}, 0
        end
    end
    if #words > 0 then lines[#lines + 1] = table.concat(words, " ") end
    return lines
end

-- Glass label in world space — perspective gives free distance scaling (close=big, far=small).
-- Right edge aligned to anchor (x=0); text wraps every 6 words.
---@param text string
---@param pos GVector
---@param ang GAngle
---@param a number 0-1 opacity multiplier
local function drawGlassLabel3D2D(text, pos, ang, a)
    cam.Start3D2D(pos, ang, 0.15)
        surface.SetFont(FONT_WORLD)
        local lines = wrapWords(text)
        local padX, padY = 12, 8

        local maxW = 0
        local lineH = 0
        for _, line in ipairs(lines) do
            local lw, lh = surface.GetTextSize(line)
            if lw > maxW then maxW = lw end
            lineH = lh
        end

        local w = maxW + padX * 2
        local h = lineH * #lines + padY * 2
        local rad = 6
        -- centered above head
        local x = -w / 2

        RNDX.Draw(rad, x, 0, w, h, nil, RNDX.BLUR + RNDX.SHAPE_IOS)
        RNDX.Draw(rad, x, 0, w, h, Color(255, 255, 255, math.floor(18 * a)), RNDX.SHAPE_IOS)
        RNDX.DrawOutlined(rad, x, 0, w, h, Color(255, 255, 255, math.floor(80 * a)), 1, RNDX.SHAPE_IOS)

        for idx, line in ipairs(lines) do
            draw.SimpleText(line, FONT_WORLD, x + padX, padY + (idx - 1) * lineH,
                Color(255, 255, 255, math.floor(230 * a)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        surface.SetDrawColor(255, 255, 255, math.floor(200 * a))
        surface.DrawRect(x + padX, padY + lineH * #lines + 3, maxW, 1)
    cam.End3D2D()
end

hook.Add("PostPlayerDraw", "AurisSubtitles_Draw", function(ply)
    local now = RealTime()
    local lp  = LocalPlayer()
    if ply == lp then return end

    local stack = subtitles[ply]
    if not stack then return end

    local i = 1
    while i <= #stack do
        if now - stack[i].spawnTime >= LIFETIME then table.remove(stack, i)
        else i = i + 1 end
    end
    if #stack == 0 then subtitles[ply] = nil return end

    local entry = stack[#stack]
    local age   = now - entry.spawnTime
    local a     = age < FADE_START and 1
                  or (1 - (age - FADE_START) / (LIFETIME - FADE_START))

    local shoulderPos = ply:GetPos() + Vector(0, 0, 85)

    -- LOS check: hide label when player is behind geometry
    local tr = util.TraceLine({
        start  = lp:EyePos(),
        endpos = shoulderPos,
        filter = { lp, ply },
        mask   = MASK_SOLID_BRUSHONLY,
    })
    if tr.Hit then return end

    -- angle facing local player, corrected for 3D2D orientation
    local ang = (shoulderPos - EyePos()):GetNormalized():Angle()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    drawGlassLabel3D2D(entry.text, shoulderPos, ang, a)
end)
