-- SpectrumSplice: Parameter management
-- Handles parameter setup and actions

local Params = {}
local specs = {}

-- Define parameter specifications
specs.AMP = controlspec.new(0, 2, "lin", 0.01, 0.8, "")
specs.MIX = controlspec.new(0, 1, "lin", 0.01, 0.5, "")
specs.FREEZE = controlspec.new(0, 1, "lin", 1, 0, "")
specs.SHIFT = controlspec.new(-24, 24, "lin", 0.1, 0, "semitones")
specs.STRETCH = controlspec.new(0.25, 4, "exp", 0.01, 1, "x")
specs.FFT_OVERLAP = controlspec.new(0.1, 0.99, "lin", 0.01, 0.5, "")

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
  
  -- Buffer Controls
  params:add_group("Buffer", 4)
  
  params:add_trigger("rec_start", "Start Recording")
  params:set_action("rec_start", function() 
    engine.record_start() 
    -- Add visual feedback
    params:set("freeze", 0)
  end)
  
  params:add_trigger("rec_stop", "Stop Recording")
  params:set_action("rec_stop", function() 
    engine.record_stop() 
  end)
  
  -- Spectral Processing
  params:add_group("Spectral", 5)
  
  params:add_binary("freeze", "Freeze", "toggle", 0)
  params:set_action("freeze", function(value)
    engine.freeze(value)
  end)
  
  params:add_control("shift", "Pitch Shift", specs.SHIFT)
  params:set_action("shift", function(value)
    engine.shift(value)
  end)
  
  params:add_control("stretch", "Stretch", specs.STRETCH)
  params:set_action("stretch", function(value)
    engine.stretch(value)
  end)
  
  params:add_control("fft_overlap", "FFT Overlap", specs.FFT_OVERLAP)
  params:set_action("fft_overlap", function(value)
    -- Note: Need to add this command to Engine_SpectrumSplice.sc
    -- engine.fft_overlap(value)
  end)
  
  params:add_option("fft_window", "FFT Window", {"Hann", "Hamming", "Sine", "Rect"}, 1)
  params:set_action("fft_window", function(value)
    -- Note: Need to add this command to Engine_SpectrumSplice.sc
    -- engine.fft_window(value - 1) -- SuperCollider uses 0-index for windows
  end)
  
  -- Note: We've commented out the FFT overlap and window parameters since 
  -- they reference engine commands that don't exist yet in your engine file.
  -- You'll need to add these commands to Engine_SpectrumSplice.sc
  
  -- Set initial parameter values
  params:bang()
end

return Params