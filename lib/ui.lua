-- SpectrumSplice: UI
-- Basic UI displaying parameters and status

local UI = {}
local viewport = { width = 128, height = 64, center = { x = 64, y = 32 } }
local recording_active = false

-- Initialize the UI
function UI.init()
  UI.page = 1
  UI.pages = 2
  UI.active_param = 1
  UI.recording_timer = 0
  UI.recording_blink = false
  
  -- Start a timer for recording animation
  UI.metro = metro.init()
  UI.metro.time = 0.5
  UI.metro.event = function()
    if recording_active then
      UI.recording_timer = UI.recording_timer + 0.5
      UI.recording_blink = not UI.recording_blink
    end
  end
  UI.metro:start()
end

-- UI Redraw Function
function UI.redraw()
  screen.clear()
  
  -- Draw title
  screen.font_face(1)
  screen.font_size(8)
  screen.level(15)
  screen.move(0, 10)
  screen.text("SpectrumSplice")
  
  -- Draw current page indicator
  screen.level(5)
  screen.move(viewport.width - 10, 10)
  screen.text(UI.page .. "/" .. UI.pages)
  
  -- Page specific content
  if UI.page == 1 then
    UI.draw_main_page()
  else
    UI.draw_spectrum_page()
  end
  
  -- Recording indicator
  if recording_active then
    screen.level(UI.recording_blink and 15 or 0)
    screen.circle(viewport.width - 5, 5, 3)
    screen.fill()
    
    screen.level(15)
    screen.move(viewport.width - 15, 7)
    screen.text_right(string.format("%.1fs", UI.recording_timer))
  end
  
  screen.update()
end

-- Draw the main parameters page
function UI.draw_main_page()
  screen.font_face(1)
  screen.font_size(8)
  
  -- Draw parameters
  local params_to_show = {
    {name = "Amplitude", value = params:get("amp")},
    {name = "Mix", value = params:get("mix")},
    {name = "Freeze", value = params:get("freeze") == 1 and "On" or "Off"},
    {name = "Shift", value = params:get("shift") .. " st"},
    {name = "Stretch", value = params:get("stretch") .. "x"}
  }
  
  for i, param in ipairs(params_to_show) do
    local y_pos = 20 + (i-1) * 10
    
    -- Highlight selected parameter
    if i == UI.active_param then
      screen.level(15)
      screen.rect(0, y_pos - 8, viewport.width, 10)
      screen.level(0)
      screen.fill()
      screen.level(15)
    else
      screen.level(5)
    end
    
    screen.move(2, y_pos)
    screen.text(param.name)
    screen.move(viewport.width - 2, y_pos)
    screen.text_right(param.value)
  end
end

-- Draw spectral visualization page
function UI.draw_spectrum_page()
  screen.level(15)
  screen.font_face(1)
  screen.font_size(8)
  screen.move(2, 20)
  screen.text("Spectral Display")
  
  -- Buffer visualization
  screen.level(5)
  screen.move(2, 30)
  screen.text("Buffer: ")
  
  -- Draw waveform representation
  local x_pos = 40
  local width = 80
  local height = 20
  screen.rect(x_pos, 25, width, height)
  screen.stroke()
  
  -- Show recording status
  if recording_active then
    screen.level(15)
    screen.circle(x_pos + width - 5, 28, 3)
    screen.fill()
  end
  
  -- Show freeze status
  if params:get("freeze") == 1 then
    screen.level(15)
    screen.move(x_pos + 5, 40)
    screen.text("FROZEN")
  end
  
  -- Simple placeholder for spectrum visualization
  screen.level(3)
  screen.rect(0, 45, viewport.width, 19)
  screen.fill()
  
  -- Draw a placeholder visualization
  screen.level(15)
  for i = 0, viewport.width - 1 do
    local height = 6
    if params:get("freeze") == 1 then
      -- Static pattern when frozen
      height = 3 + math.abs(((i + 30) % 7) - 3) * 2
    else
      -- Dynamic pattern when not frozen
      height = 3 + math.abs(math.sin(i / 8 + (os.time() % 10)) * 6)
    end
    screen.move(i, 64 - height)
    screen.line(i, 64)
    screen.stroke()
  end
end

-- Set recording status
function UI.set_recording(state)
  recording_active = state
  if not state then
    UI.recording_timer = 0
    UI.recording_blink = false
  end
end

-- Encoder function
function UI.enc(n, d)
  if n == 1 then
    -- Change page
    UI.page = util.clamp(UI.page + d, 1, UI.pages)
  elseif n == 2 then
    -- Navigate parameters
    if UI.page == 1 then
      UI.active_param = util.clamp(UI.active_param + d, 1, 5)
    end
  elseif n == 3 then
    -- Adjust selected parameter
    if UI.page == 1 then
      if UI.active_param == 1 then
        params:delta("amp", d)
      elseif UI.active_param == 2 then
        params:delta("mix", d)
      elseif UI.active_param == 3 then
        params:delta("freeze", d > 0 and 1 or -1)
      elseif UI.active_param == 4 then
        params:delta("shift", d)
      elseif UI.active_param == 5 then
        params:delta("stretch", d)
      end
    end
  end
  
  UI.redraw()
end

-- Key function
function UI.key(n, z)
  if z == 1 then
    if n == 2 then
      -- K2: Toggle page
      UI.page = 3 - UI.page  -- Toggle between 1 and 2
    elseif n == 3 then
      -- K3: Toggle recording/freeze
      if not recording_active then
        params:set("rec_start", 1)
        UI.set_recording(true)
      else
        params:set("rec_stop", 1)
        UI.set_recording(false)
      end
    end
  end
  
  UI.redraw()
end

return UI