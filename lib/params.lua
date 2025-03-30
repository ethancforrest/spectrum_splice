-- SpectrumSplice: Parameter management
-- Handles parameter setup and actions

local Params = {}
local specs = {}

-- Define parameter specifications
specs.AMP = controlspec.new(0, 2, "lin", 0.01, 0.8, "")
specs.MIX = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.FREEZE = controlspec.new(0, 1, "lin", 1, 0, "")

-- Macro control specs
specs.TEXTURE = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.DEFINITION = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.STRUCTURE = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.DENSITY = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.FEEDBACK = controlspec.new(0, 0.95, "lin", 0.01, 0.2, "")
specs.THRESHOLD = controlspec.new(0, 1, "lin", 0.01, 0.5, "")

-- Initialize parameters
function Params.init()
  params:add_separator("SpectrumSplice")
  
  -- Input/Output
  params:add_group("Input/Output", 3)
  
  params:add_control("amp", "Amplitude", specs.AMP)
  params:set_action("amp", function(value)
    engine.amp(value)
  end)
  
  params:add_control("mix", "Dry/Wet", specs.MIX)
  params:set_action("mix", function(value)
    engine.mix(value)
  end)
  
  params:add_option("monitor", "Monitor Input", {"Off", "On"}, 2)
  params:set_action("monitor", function(value)
    if value == 1 then 
      audio.level_monitor(0)
    else 
      audio.level_monitor(1)
    end
  end)
  
  -- Character Presets
  params:add_group("Character", 2)
  
  params:add_option("character", "Character", {"Crystal", "Ink Drawing", "Watercolor", "Frost Pattern", "Particles"}, 1)
  params:set_action("character", function(value)
    local characters = {"crystal", "ink", "watercolor", "frost", "particles"}
    engine.set_character(characters[value])
  end)
  
  params:add_option("fft_size", "FFT Size", {"512", "1024", "2048", "4096"}, 2)
  params:set_action("fft_size", function(value)
    engine.fft_size(value - 1) -- 0-indexed in engine
  end)
  
  -- Macro Controls
  params:add_group("Texture Controls", 5)
  
  params:add_control("texture", "Texture", specs.TEXTURE)
  params:set_action("texture", function(value)
    engine.texture(value)
  end)
  
  params:add_control("definition", "Definition", specs.DEFINITION)
  params:set_action("definition", function(value)
    engine.definition(value)
  end)
  
  params:add_control("structure", "Structure", specs.STRUCTURE)
  params:set_action("structure", function(value)
    engine.structure(value)
  end)
  
  params:add_control("density", "Density", specs.DENSITY)
  params:set_action("density", function(value)
    engine.density(value)
  end)
  
  params:add_control("feedback", "Feedback", specs.FEEDBACK)
  params:set_action("feedback", function(value)
    engine.feedback(value)
  end)
  
  -- Special Controls
  params:add_group("Special", 2)
  
  params:add_binary("freeze", "Freeze", "toggle", 0)
  params:set_action("freeze", function(value)
    engine.freeze(value)
  end)
  
  params:add_control("threshold", "Threshold", specs.THRESHOLD)
  params:set_action("threshold", function(value)
    engine.threshold(value)
  end)
  
  -- Set initial parameter values
  params:bang()
end

return Params
