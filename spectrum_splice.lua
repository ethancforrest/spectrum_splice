-- spectrum_splice.lua
-- Spectrum_Splice: Artistic spectral processor
--
-- E1: Change page
-- E2: Select macro parameter
-- E3: Adjust selected parameter
-- K2: Toggle page
-- K3: Toggle freeze
--
-- v0.1.0

engine.name = "SpectrumSplice"

local params_manager = include("lib/params")
local ui = include("lib/ui")

-- Data directory
local data_dir = _path.data .. "spectrum_splice/"
local pset_dir = data_dir .. "presets/"

-- Initialize script
function init()
  print("Initializing SpectrumSplice...")
  
  -- Create directories if they don't exist
  if not util.file_exists(data_dir) then util.make_dir(data_dir) end
  if not util.file_exists(pset_dir) then util.make_dir(pset_dir) end
  
  -- Set up audio
  audio.level_cut(1.0)
  audio.level_adc_cut(1.0)
  audio.level_eng_cut(1.0)
  
  -- Initialize modules
  params_manager.init()
  ui.init()
  
  -- Set encoder sensitivity
  norns.enc.sens(1, 4)  -- Make E1 less sensitive for smoother navigation
  
  -- Default parameters
  params:default()
  
  -- Start timer for UI updates
  redraw_timer = metro.init()
  redraw_timer.event = function()
    redraw()
  end
  redraw_timer.time = 1/15
  redraw_timer:start()
  
  print("SpectrumSplice initialized")
end

-- Encoder handlers
function enc(n, d)
  ui.enc(n, d)
end

-- Key handlers
function key(n, z)
  ui.key(n, z)
end

-- Screen redraw
function redraw()
  ui.redraw()
end

-- Cleanup on script close
function cleanup()
  redraw_timer:stop()
  if ui.metro then ui.metro:stop() end
end
