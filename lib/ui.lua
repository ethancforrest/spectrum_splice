-- SpectrumSplice: UI
-- Macro-focused UI for artistic spectral processing

local UI = {}
local viewport = { width = 128, height = 64, center = { x = 64, y = 32 } }

-- Initialize the UI
function UI.init()
  UI.page = 1
  UI.pages = 2
  UI.active_param = 1
  
  -- Visualization state
  UI.spectrum_data = {}
  for i = 1, 64 do
    UI.spectrum_data[i] = 0
  end
  
  -- Start timer for animation
  UI.metro = metro.init()
  UI.metro.time = 1/15
  UI.metro.event = function()
    -- Update visualization data
    for i = 1, 64 do
      if params:get("freeze") == 1 then
        -- Frozen state - minimal movement
        UI.spectrum_data[i] = UI.spectrum_data[i] * 0.98
      else
        -- Active animation
        local target = math.random() * params:get("density")
        UI.spectrum_data[i] = UI.spectrum_data[i] * 0.8 + target * 0.2
      end
    end
  end
  UI.metro:start()
end

-- Main redraw function
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
  
  screen.update()
end

-- Draw the main parameters page
function UI.draw_main_page()
  screen.font_face(1)
  screen.font_size(8)
  
  -- Draw character name prominently
  local char_names = {"Crystal", "Ink Drawing", "Watercolor", "Frost Pattern", "Particles"}
  local char_idx = params:get("character")
  
  screen.level(15)
  screen.move(viewport.center.x, 20)
  screen.text_center(char_names[char_idx])
  
  -- Draw macro controls
  local macro_params = {
    {name = "Texture", id = "texture"},
    {name = "Definition", id = "definition"},
    {name = "Structure", id = "structure"},
    {name = "Density", id = "density"}
  }
  
  for i, param in ipairs(macro_params) do
    local y_pos = 30 + (i-1) * 8
    
    -- Highlight selected parameter
    if i == UI.active_param then
      screen.level(15)
    else
      screen.level(5)
    end
    
    screen.move(2, y_pos)
    screen.text(param.name)
    
    -- Draw parameter value slider
    local value = params:get(param.id)
    local slider_width = 50
    screen.level(1)
    screen.rect(70, y_pos - 5, slider_width, 3)
    screen.fill()
    
    screen.level(i == UI.active_param and 15 or 10)
    screen.rect(70, y_pos - 5, slider_width * value, 3)
    screen.fill()
  end
  
  -- Show freeze status
  if params:get("freeze") == 1 then
    screen.level(15)
    screen.move(viewport.center.x, viewport.height - 5)
    screen.text_center("FROZEN")
  end
end

-- Draw spectral visualization page
function UI.draw_spectrum_page()
  screen.level(15)
  screen.font_face(1)
  screen.font_size(8)
  screen.move(2, 20)
  screen.text("Spectral Visualization")
  
  -- Draw spectral content visualization
  local definition = params:get("definition")
  local structure = params:get("structure")
  
  -- Draw the visualization based on character
  local char_idx = params:get("character")
  
  -- Different visualization per character
  if char_idx == 1 then -- Crystal
    -- Sharp, angular visualization
    UI.draw_crystalline(definition, structure)
  elseif char_idx == 2 then -- Ink
    -- Fine line-based visualization
    UI.draw_ink(definition, structure)
  elseif char_idx == 3 then -- Watercolor
    -- Soft, transparent visualization
    UI.draw_watercolor(definition, structure)
  elseif char_idx == 4 then -- Frost
    -- Geometric pattern visualization
    UI.draw_frost(definition, structure)
  else -- Particles
    -- Particle cloud visualization
    UI.draw_particles(definition, structure)
  end
end

-- Character-specific visualizations
function UI.draw_crystalline(definition, structure)
  screen.level(15)
  
  -- Draw sharp, crystalline structures
  for i = 1, 64, 2 do
    local x = i * 2
    local height = UI.spectrum_data[i] * 30 * definition
    
    if height > 1 then
      -- Draw angular shape
      screen.move(x, 64)
      screen.line_rel(-2 * structure, -height)
      screen.line_rel(4 * structure, 0)
      screen.line_rel(-2 * structure, height)
      screen.stroke()
    end
  end
end

function UI.draw_ink(definition, structure)
  screen.level(15)
  
  -- Draw fine ink-like lines
  for i = 1, 63 do
    local x1 = i * 2
    local x2 = (i + 1) * 2
    local y1 = 64 - (UI.spectrum_data[i] * 40 * definition)
    local y2 = 64 - (UI.spectrum_data[i+1] * 40 * definition)
    
    -- Draw line with varying thickness
    local thickness = math.max(1, math.floor(UI.spectrum_data[i] * 3))
    screen.line_width(thickness)
    screen.move(x1, y1)
    screen.line(x2, y2)
    screen.stroke()
  end
  screen.line_width(1)
end

function UI.draw_watercolor(definition, structure)
  -- Layered, transparent visualization
  for j = 1, 3 do
    screen.level(5 * j)
    
    local offset = j * 4
    local scale = 1 - (j * 0.2)
    
    screen.move(0, 64)
    for i = 1, 64 do
      local x = i * 2
      local height = UI.spectrum_data[(i + offset) % 64 + 1] * 30 * definition * scale
      screen.line(x, 64 - height)
    end
    screen.line(128, 64)
    screen.close()
    screen.fill()
  end
end

function UI.draw_frost(definition, structure)
  screen.level(15)
  
  -- Geometric pattern with connections
  for i = 1, 64, 4 do
    local x = i * 2
    local height = UI.spectrum_data[i] * 40 * definition
    
    if height > 3 then
      -- Draw node
      screen.circle(x, 64 - height, 1 + UI.spectrum_data[i] * 2)
      screen.fill()
      
      -- Draw connections between nodes
      if i > 4 and UI.spectrum_data[i-4] * 40 * definition > 3 then
        local prev_x = (i-4) * 2
        local prev_height = UI.spectrum_data[i-4] * 40 * definition
        
        screen.line_width(1)
        screen.move(prev_x, 64 - prev_height)
        screen.line(x, 64 - height)
        screen.stroke()
      end
    end
  end
end

function UI.draw_particles(definition, structure)
  -- Particle-based visualization
  for i = 1, 64 do
    local energy = UI.spectrum_data[i]
    if energy > 0.1 then
      -- Create multiple particles based on energy
      local particle_count = math.floor(energy * 10 * definition)
      
      for j = 1, particle_count do
        local x = i * 2 + math.random(-4, 4) * structure
        local y = 64 - (energy * 30) + math.random(-5, 5) * structure
        local size = math.random() * energy * 2
        
        screen.level(math.random(5, 15))
        screen.circle(x, y, size)
        screen.fill()
      end
    end
  end
end

-- Encoder function
function UI.enc(n, d)
  if n == 1 then
    -- Change page
    UI.page = util.clamp(UI.page + d, 1, UI.pages)
  elseif n == 2 then
    -- Navigate parameters on main page
    if UI.page == 1 then
      UI.active_param = util.clamp(UI.active_param + d, 1, 4)
    end
  elseif n == 3 then
    -- Adjust selected parameter
    if UI.page == 1 then
      local param_ids = {"texture", "definition", "structure", "density"}
      params:delta(param_ids[UI.active_param], d / 100)
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
      -- K3: Toggle freeze
      params:set("freeze", 1 - params:get("freeze"))
    end
  end
  
  UI.redraw()
end

return UI
