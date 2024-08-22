-- name:  Super Mania 64!
-- incompatible: gamemode
-- description: 4-Key Rhythm Game inspired by games such assertion Osu!Mania
-- pausable: true

local config = {
    fallingLane={
        [1]={
            R = 0,
            G = 100,
            B = 255
        },
        [2]={
            R = 0,
            G = 100,
            B = 255
        },
        [3]={
            R = 0,
            G = 100,
            B = 255
        },
        [4]={
            R = 0,
            G = 100,
            B = 255
        }
    },
    staticLane={
        [1]={
            R = 255,
            G = 255,
            B = 255
        },
        [2]={
            R = 255,
            G = 255,
            B = 255
        },
        [3]={
            R = 255,
            G = 255,
            B = 255
        },
        [4]={
            R = 255,
            G = 255,
            B = 255
        }
    },
    staticLaneHit={
        [1]={
            R = 100,
            G = 100,
            B = 100
        },
        [2]={
            R = 100,
            G = 100,
            B = 100
        },
        [3]={
            R = 100,
            G = 100,
            B = 100
        },
        [4]={
            R = 100,
            G = 100,
            B = 100
        }
    },
    inputDelay = 0,
    menuMusic = "menu.ogg",
    comboColor_R = 112,
    comboColor_G = 130,
    comboColor_B = 219,
    menuDesel_R = 255,
    menuDesel_G = 255,
    menuDesel_B = 255,
    menuSel_R = 50,
    menuSel_G = 0,
    menuSel_B = 255,
    backgroundColor_R = 0,
    backgroundColor_G = 0,
    backgroundColor_B = 0,
    end_SongName_R = 255,
    end_SongName_G = 255,
    end_SongName_B = 255,
    end_FinalCombo_R = 0,
    end_FinalCombo_G = 50,
    end_FinalCombo_B = 255,
    end_Notes_R = 0,
    end_Notes_G = 50,
    end_Notes_B = 255,
    end_Misses_R = 0,
    end_Misses_G = 50,
    end_Misses_B = 255,
    end_FullCombo_R = 0,
    end_FullCombo_G = 255,
    end_FullCombo_B = 0,
    end_Return_R = 255,
    end_Return_G = 255,
    end_Return_B = 255,
    songVol = 100,
    menuMusicVol = 100
}

for i, v in pairs(config) do
    if type(v) == "string" then
        if mod_storage_load(i) == nil then
            print("this never gets called?")
            mod_storage_save(i, v)
        else
            config[i] = mod_storage_load(i)
        end
    elseif type(v) == "number" then
        if mod_storage_load(i) == nil then
            mod_storage_save_number(i, v)
        else
            config[i] = tonumber(mod_storage_load(i))
        end
    elseif type(v) == "table" then
        for lane,RGB in pairs(v) do
            for r,equal in pairs(RGB) do
                if mod_storage_load(i..lane..r) == nil then
                    mod_storage_save_number(i..lane..r, equal)
                else
                    config[i][lane][r] = tonumber(mod_storage_load(i..lane..r))
                end
            end
        end
    end
end

local gGlobalSoundSource = { x = 0, y = 0, z = 0 }
local sPlayerStickX        = 0
local sPlayerStickY        = 0
local sPlayerStickMag      = 0
local sPlayerButtonPressed = 0
local sPlayerButtonDown    = 0
local laneX = {}
local laneY = 0
local audioStream = nil
local previousSec = 0
local timeInc = 0
local aproxTime = 0
local songStartTime = 0
local db = {}
local prevSongTime = 0
local combo = 0
local misses = 0
local hits = 0
local totalNotes = 0
local clock = 0
local AnimOffset = -0.15

local upcoming = {}
local onscreen = {}

local levels = {}

local state = "intro"

local index = 1

local playlistIndex = 1

_G.ManiaInstalled = true

_G.playing = false
_G.packID = 0
_G.AudioCurrentTime = 0
_G.SongIndex = 0
_G.Pause = false
_G.Stop = false
_G.songVol = config.songVol

local songIndex = 1
_G.LoadPlaylist = function(playlist)
    songIndex = 1
    for _, song in pairs(playlist) do
        song["id"] = playlistIndex
        song["songIndex"] = songIndex
        table.insert(levels, song)
        songIndex=songIndex+1
    end
    playlistIndex=playlistIndex+1
    return playlistIndex-1
end

local function inlineif(condition, t, f)
    if condition then return t else return f end
end

local stickDistance = 0.5

local function ifinput(bind)
    if bind ~= "L_JSTICK" and bind ~= "D_JSTICK" and bind ~= "U_JSTICK" and bind ~= "R_JSTICK" then
        return (sPlayerButtonPressed & bind) ~= 0
    else
        if bind == "L_JSTICK" then
            if gMarioStates[0].controller.stickX/64 <= -stickDistance then return true end
        elseif bind == "R_JSTICK" then
            if gMarioStates[0].controller.stickX/64 >= stickDistance then return true end
        elseif bind == "U_JSTICK" then
            if gMarioStates[0].controller.stickY/64 >= stickDistance then return true end
        elseif bind == "D_JSTICK" then
            if gMarioStates[0].controller.stickY/64 <= -stickDistance then return true end
        end
    end
    return false
end

local function ifframe1(bind)
    if db[bind] == nil then db[bind] = false end
    if db[bind] == false and ifinput(bind) then
        db[bind] = true
        return true
    end
end

local inputBindings = {["1"] = {L_JPAD, X_BUTTON, "L_JSTICK", L_CBUTTONS}, ["2"] = {D_JPAD, A_BUTTON, "D_JSTICK", D_CBUTTONS}, ["3"] = {U_JPAD, Y_BUTTON, "U_JSTICK", U_CBUTTONS}, ["4"] = {R_JPAD, B_BUTTON, "R_JSTICK", R_CBUTTONS}}
local function lanehit(lane)
    for _, binding in pairs(inputBindings[tostring(lane)]) do
        if ifinput(binding) then return true end
    end
    return false
end

local function laneframe1(lane)
    for _, binding in pairs(inputBindings[tostring(lane)]) do
        if ifframe1(binding) then return true end
    end
    return false
end

local function printCenter(text, y, scale, offset)
    if offset==nil then offset=0 end
    local half = djui_hud_measure_text(text) * scale / 2
    djui_hud_print_text(text, djui_hud_get_screen_width()/2-half+offset, y, scale)
end


local coolTextSize = 30
local menuStream
local function render_menu()
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_color(66, 135, 245, 255)
    local buttons = {
        {title="Play!", state="select"},
        {title="Options", state="options"}
    }
    printCenter("Super Mania 64!", 20+AnimOffset, 0.5, AnimOffset)
    for i, v in pairs(buttons) do
        djui_hud_set_color(inlineif(index==i,config.menuSel_R,config.menuDesel_R), inlineif(index==i,config.menuSel_G,config.menuDesel_G), inlineif(index==i,config.menuSel_B,config.menuDesel_B), 255)
        djui_hud_print_text(v.title, 20+inlineif(index==i,-AnimOffset/2,0), 100+(32*i-32)+inlineif(index==i,-AnimOffset/2,0), coolTextSize/100)
    end
    if ifframe1(D_JPAD) then
        if index+1 <= #buttons then
            index=index+1
        end
    end
    if ifframe1(U_JPAD) then
        if index-1 > 0 then
            index=index-1
        end
    end
    if ifframe1(A_BUTTON) then
        state = buttons[index]["state"]
        index = 1
    end
end

local function render_select()
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    djui_hud_set_font(FONT_MENU)
    for i, v in pairs(levels) do
        if i == index then
            djui_hud_set_color(config.menuSel_R, config.menuSel_G, config.menuSel_B, 255);
        else
            djui_hud_set_color(config.menuDesel_R, config.menuDesel_G, config.menuDesel_B, 255);
        end
        djui_hud_print_text(v["name"], 10+inlineif(index==i,-AnimOffset/2,0), djui_hud_get_screen_height()/2+(32*i-32*index)+inlineif(index==i,-AnimOffset/2,0), coolTextSize/100);
    end
    if ifframe1(D_JPAD) then
        if index+1 <= #levels then
            index=index+1
        end
    end
    --U_JPAD
    if ifframe1(U_JPAD) then
        if index-1 > 0 then
            index=index-1
        end
    end
    --L_JPAD
    if ifinput(L_JPAD) then
        coolTextSize=coolTextSize+1
    end
    --R_JPAD
    if ifinput(R_JPAD) then
        coolTextSize=coolTextSize-1
    end
    --A_BUTTON
    if ifframe1(A_BUTTON) then
        _G.songVol = config.songVol
        combo = 0
        totalNotes = 0
        hits = 0
        misses = 0
        _G.AudioCurrentTime = 0
        prevSongTime = 0
        onscreen = {}
        upcoming = {}
        audio_stream_stop(menuStream)
        menuStream = nil
        for _, timing in pairs(levels[index]["notes"]) do
            for _ in pairs(timing) do
                totalNotes = totalNotes + 1
            end
        end
        state = "song"
        if levels[index]["id"] then
            _G.packID = levels[index]["id"]
            _G.SongIndex = levels[index]["songIndex"]
            _G.playing = true
        else
            audio_stream_play(audio_stream_load(levels[index]["song"]), true, config.songVol/100);
        end
        upcoming = {}
        for time, circles in pairs(levels[index].notes) do upcoming[time] = circles end
        songStartTime = aproxTime-config.inputDelay
    end
    if ifframe1(B_BUTTON) then
        index = 1
        state = "menu"
    end
end

local padding = 8
local distance = 8
local noteSize = 4
local moveTime = 1


local function hit()
    hits=hits+1
    combo=combo+1
end

local function miss()
    misses=misses+1
    combo=0
end

local circ = get_texture_info('circ')
local function render_circles()
    
    laneY = djui_hud_get_screen_height()-25.6-padding

    djui_hud_set_color(
        inlineif(lanehit(1), config.staticLaneHit[1].R, config.staticLane[1].R),
        inlineif(lanehit(1), config.staticLaneHit[1].G, config.staticLane[1].G),
        inlineif(lanehit(1), config.staticLaneHit[1].B, config.staticLane[1].B),
        255)
    laneX[1] = -12.8 + djui_hud_get_screen_width()*((50-distance*1.5)/100)
    djui_hud_render_texture(circ, laneX[1], laneY, noteSize/100, noteSize/100)
    
    djui_hud_set_color(
        inlineif(lanehit(2), config.staticLaneHit[2].R, config.staticLane[2].R),
        inlineif(lanehit(2), config.staticLaneHit[2].G, config.staticLane[2].G),
        inlineif(lanehit(2), config.staticLaneHit[2].B, config.staticLane[2].B),
        255)
    laneX[2] = -12.8 + djui_hud_get_screen_width()*((50-distance*0.5)/100)
    djui_hud_render_texture(circ, laneX[2], laneY, noteSize/100, noteSize/100)
    
    djui_hud_set_color(
        inlineif(lanehit(3), config.staticLaneHit[3].R, config.staticLane[3].R),
        inlineif(lanehit(3), config.staticLaneHit[3].G, config.staticLane[3].G),
        inlineif(lanehit(3), config.staticLaneHit[3].B, config.staticLane[3].B),
        255)
    laneX[3] = -12.8 + djui_hud_get_screen_width()*((50+distance*0.5)/100)
    djui_hud_render_texture(circ, laneX[3], laneY, noteSize/100, noteSize/100)
    
    djui_hud_set_color(
        inlineif(lanehit(4), config.staticLaneHit[4].R, config.staticLane[4].R),
        inlineif(lanehit(4), config.staticLaneHit[4].G, config.staticLane[4].G),
        inlineif(lanehit(4), config.staticLaneHit[4].B, config.staticLane[4].B),
        255)
    laneX[4] = -12.8 + djui_hud_get_screen_width()*((50+distance*1.5)/100)
    djui_hud_render_texture(circ, laneX[4], laneY, noteSize/100, noteSize/100)
end

local function render_notes()
    for i, note in pairs(onscreen) do
        if note["Lane"] ~= 1 and note["Lane"] ~= 2 and note["Lane"] ~= 3 and note["Lane"] ~= 4 then goto continue end
        local moveSpeed = laneY/30/moveTime
        note["Y"]=note["Y"]+moveSpeed
        if note["Y"] >= djui_hud_get_screen_height() then
            onscreen[i] = nil
            miss()
        end
        djui_hud_set_color(config.fallingLane[note["Lane"]].R,config.fallingLane[note["Lane"]].G,config.fallingLane[note["Lane"]].B,255)
        djui_hud_render_texture(circ, laneX[note["Lane"]], note["Y"], noteSize/100, noteSize/100)
        ::continue::
    end
end


local finishAfterSame = 15
local finishCount = 0
local pauseStart = 0
local function render_game()
    _G.Paused = false
    render_circles()
    for time, circles in pairs(upcoming) do
        if aproxTime-songStartTime >= time-moveTime*1000 then
            for _, note in pairs(circles) do
                table.insert(onscreen, {["Lane"] = note["Lane"], ["Y"] = 0})
            end
            upcoming[time] = {}
        end
    end
    for lane = 1, 4 do
        if (laneframe1(lane)) then
            for i, note in pairs(onscreen) do
                if note["Lane"] == lane and (note["Y"] >= laneY-hitDistanceUP/2) and (note["Y"] <= laneY+hitDistanceDOWN/2) then
                    onscreen[i] = nil
                    hit()
                    break
                end
            end
        end
    end
    djui_hud_set_font(FONT_MENU);
    djui_hud_set_color(config.comboColor_R, config.comboColor_G, config.comboColor_B, 255)
    djui_hud_print_text("COMBO: "..combo, 10, 30, coolTextSize/200)
    render_notes()
    if prevSongTime == _G.AudioCurrentTime and _G.AudioCurrentTime ~= 0 then
        finishCount=finishCount+1
        if finishCount >= finishAfterSame then
            _G.AudioCurrentTime = 0
            prevSongTime = 0
            state = "results"
        end
    else finishCount=0 end
    prevSongTime = _G.AudioCurrentTime
    if (ifframe1(START_BUTTON)) then
        pauseStart = aproxTime
        state="pause"
    end
end

local function render_paused()
    --Just send to song select. I don't even wanna know why this doesn't work
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    state = "select"
    _G.Stop = true
    --[[_G.Paused = true
    print((aproxTime-pauseStart))
    if (ifframe1(START_BUTTON)) then
        songStartTime=songStartTime+(aproxTime-pauseStart)
        state="song"
    end]]
end

local function render_results()
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_color(config.end_SongName_R, config.end_SongName_G, config.end_SongName_B, 255)
    printCenter(levels[index]["name"], 20, coolTextSize/80)
    djui_hud_set_color(config.end_FinalCombo_R, config.end_FinalCombo_G, config.end_FinalCombo_B, 255)
    printCenter("Final Combo: "..combo, 80, coolTextSize/150)
    djui_hud_set_color(config.end_Notes_R, config.end_Notes_G, config.end_Notes_B, 255)
    printCenter("Hit: "..hits.." / "..totalNotes.." notes", 110, coolTextSize/150)
    djui_hud_set_color(config.end_Misses_R, config.end_Misses_G, config.end_Misses_B, 255)
    printCenter("Misses: "..misses, 140, coolTextSize/150)
    if misses==0 then
        djui_hud_set_color(config.end_FullCombo_R, config.end_FullCombo_G, config.end_FullCombo_B, 255)
        printCenter("Full Combo!", 160, coolTextSize/100)
    end
    djui_hud_set_color(config.end_Return_R, config.end_Return_G, config.end_Return_B, 255)
    printCenter("Press A to return to song list.", 200, coolTextSize/100)
    if ifframe1(A_BUTTON) then state = "select" end
end

local introFont = FONT_NORMAL
local gingerphoenix10 = get_texture_info('gingerphoenix10')
local function render_intro()
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    if clock/4 == math.floor(clock/4) then
        introFont=inlineif(introFont==FONT_NORMAL,FONT_ALIASED,FONT_NORMAL)
    end
    djui_hud_set_font(introFont)
    djui_hud_set_color(255,255,255,255)
    printCenter("A MOD BY", djui_hud_get_screen_height()/4, 1.25)
    if clock >= 90 then
        djui_hud_render_texture(gingerphoenix10, djui_hud_get_screen_width()/2-(256*0.1)+AnimOffset, djui_hud_get_screen_height()/2+AnimOffset, 0.1, 0.1)
    end
    if clock >= 180 or ifframe1(A_BUTTON) or ifframe1(START_BUTTON) or ifframe1(B_BUTTON) then
        state = "menu"
    end
end

local function render_options()
    if not menuStream then
        menuStream = audio_stream_load(config.menuMusic)
        audio_stream_play(menuStream, true, config.menuMusicVol/100)
        audio_stream_set_looping(menuStream, true)
    end
    djui_hud_set_color(255,255,255,255)
    djui_hud_set_font(FONT_MENU)
    printCenter("Not implemented yet. Sorry :)", djui_hud_get_screen_height()/2, coolTextSize/100)
    printCenter("Press B to return to Main Menu.", djui_hud_get_screen_height()/2+coolTextSize/50+30, coolTextSize/100)
    if ifframe1(B_BUTTON) then state = "menu" end
end

local function disable_inputs(m)
    m.controller.rawStickX = 0
    m.controller.rawStickY = 0
    --m.controller.stickX = 0
    --m.controller.stickY = 0
    m.controller.stickMag = 0
    m.controller.buttonPressed = m.controller.buttonDown & (START_BUTTON | CONT_R)
    m.controller.buttonDown = m.controller.buttonDown & (START_BUTTON | CONT_R)
    m.controller.extStickX = 0
    m.controller.extStickY = 0
    set_mario_action(m, ACT_IDLE, 0)
    m.actionState = 0
    m.actionTimer = 0
end

local function before_mario_update(m)
    if m.playerIndex == 0 then
        sPlayerStickX = m.controller.stickX
        sPlayerStickY = m.controller.stickY
        sPlayerStickMag = m.controller.stickMag
        sPlayerButtonPressed = m.controller.buttonPressed
        sPlayerButtonDown = m.controller.buttonDown
    end
    disable_inputs(m)
end

local function mario_update(m)
    disable_inputs(m)
end

local function clear_screen()
    for _, behaviorId in ipairs({ id_bhvTree, id_bhvBird, id_bhvBirdsSoundLoop }) do
        local obj = obj_get_first_with_behavior_id(behaviorId)
        while obj ~= nil do
            obj_mark_for_deletion(obj)
            obj = obj_get_next_with_same_behavior_id(obj)
        end
    end
    for i = 0, 99 do stop_background_music(i) end
    stop_shell_music()
    stop_cap_music()
    hud_hide()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(config.backgroundColor_R, config.backgroundColor_G, config.backgroundColor_B, 0xFF)
    djui_hud_set_font(FONT_HUD)
    djui_hud_render_rect(-1, -1, djui_hud_get_screen_width() + 2, djui_hud_get_screen_height() + 2)
    djui_hud_set_resolution(RESOLUTION_N64)
end

local function getAproxTime()
    if previousSec ~= get_time() then
        timeInc = 0
        aproxTime = get_time()*1000
    else
        timeInc = timeInc + 1
        aproxTime = (get_time()+timeInc/30)*1000
    end
    previousSec = get_time()
end

local function f1Checks()
    for i,v in pairs(db) do
        if (not ifinput(i)) and v then
            db[i] = false
        end
    end
end


local function render_hud()
    clear_screen()
    f1Checks()
    getAproxTime()
    clock=clock+1
    if clock/4 == math.floor(clock/4) then
        AnimOffset=inlineif(AnimOffset==-0.15,0.15,-0.15)
    end
    if state == "select" then
        render_select()
    elseif state == "song" then
        render_game()
    elseif state == "results" then
        render_results()
    elseif state == "pause" then
        render_paused()
    elseif state == "intro" then
        render_intro()
    elseif state == "menu" then
        render_menu()
    elseif state == "options" then
        render_options()
    end
end

hook_event(HOOK_ON_HUD_RENDER, render_hud)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)