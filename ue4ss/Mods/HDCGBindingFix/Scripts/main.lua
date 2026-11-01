-- HD CG Binding Fix 1.0.0. Tested on PBZ Steam build 26266538.
-- Uses the same recovery operation as the successful diagnostic experiment.
local attempted = {}
local pending = false
local reportedError = false
local function log(message) print('[HDCGBindingFix] ' .. message .. '\n') end
local function scan()
    local textures = FindAllOf('MediaTexture') or {}
    for _, texture in ipairs(textures) do
        if texture:IsValid() then
            local name = texture:GetFullName()
            if name:find('/Game/Movies/Flow/FirstPlayer_VideoTexture.', 1, true) then
                local player = texture:GetMediaPlayer()
                if not player or not player:IsValid() or not player:IsPlaying() or not player:IsReady() then
                    attempted[name] = nil
                else
                    local key = player:GetFullName() .. '|' .. player:GetUrl():ToString()
                    if texture:GetWidth() <= 2 and texture:GetHeight() <= 2 and attempted[name] ~= key then
                        attempted[name] = key
                        -- Reattach the SAME player: no file replacement, resize,
                        -- restart, seek, audio change, or persisted asset changes.
                        texture:SetMediaPlayer(nil)
                        local ok, err = pcall(function() texture:SetMediaPlayer(player) end)
                        if not ok then
                            -- Best-effort restore before surfacing the error.
                            pcall(function() texture:SetMediaPlayer(player) end)
                            error(err)
                        end
                        log('Rebound placeholder cutscene texture: ' .. key)
                    end
                end
            end
        end
    end
end
log('v1.0.0 loaded; original CG resolution retained.')
LoopAsync(2000, function()
    if not pending then
        pending = true
        ExecuteInGameThread(function()
            local ok, err = pcall(scan)
            if not ok and not reportedError then
                log('Recovery scan error: ' .. tostring(err))
                reportedError = true
            end
            pending = false
        end)
    end
    return false
end)
