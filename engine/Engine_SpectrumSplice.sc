// Engine_SpectrumSplice.sc
// Advanced spectral processor for Norns
Engine_SpectrumSplice : CroneEngine {
  var <synth;
  var <fft_buf;
  var <character_params;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }
  
  alloc {
    // Allocate FFT buffer
    fft_buf = Buffer.alloc(context.server, 2048);
    
    // Store character preset parameters
    character_params = Dictionary.new;
    
    // Add character presets (these would be tuned during development)
    character_params.put(\crystal, Dictionary.newFrom([
      \threshold, 0.4, \sharpness, 0.8, \density, 0.3, \feedback, 0.2, \structure, 0.9
    ]));
    
    character_params.put(\ink, Dictionary.newFrom([
      \threshold, 0.6, \sharpness, 0.95, \density, 0.5, \feedback, 0.1, \structure, 0.7
    ]));
    
    character_params.put(\watercolor, Dictionary.newFrom([
      \threshold, 0.3, \sharpness, 0.4, \density, 0.7, \feedback, 0.3, \structure, 0.2
    ]));
    
    character_params.put(\frost, Dictionary.newFrom([
      \threshold, 0.5, \sharpness, 0.7, \density, 0.4, \feedback, 0.4, \structure, 0.6
    ]));
    
    character_params.put(\particles, Dictionary.newFrom([
      \threshold, 0.7, \sharpness, 0.6, \density, 0.8, \feedback, 0.2, \structure, 0.3
    ]));
    
    // Main processing SynthDef with macro controls
    SynthDef(\SpectrumSplice, {
      arg out=0, amp=1.0, mix=0.5, freeze=0, 
          texture=0.5, definition=0.5, structure=0.5, density=0.5,
          character=0, threshold=0.5, sharpness=0.5, feedback=0.2,
          fft_size=1;
      
      var input, output;
      var fft_sizes = #[512, 1024, 2048, 4096];
      var actual_size = fft_sizes[fft_size];
      
      // Input from hardware channels
      input = SoundIn.ar([0, 1]);
      
      // Apply processing to each channel separately
      output = Array.fill(2, {|i|
        var chan_in = input[i];
        var fft_chain, processed;
        
        // FFT analysis
        fft_chain = FFT(LocalBuf(actual_size), chan_in);
        
        // Spectral freeze with variable threshold
        fft_chain = PV_MagAbove(fft_chain, threshold);
        
        // Apply freeze when active
        fft_chain = PV_Freeze(fft_chain, freeze);
        
        // Several spectral transformations controlled by macro parameters
        
        // Definition control - sharpens or softens spectral content
        fft_chain = PV_MagSmear(fft_chain, (1 - definition) * 20);
        
        // Structure control - adjusts spectral organization
        fft_chain = PV_BrickWall(fft_chain, structure * 2 - 1);
        
        // Density control - affects spectral richness
        fft_chain = PV_BinShift(fft_chain, 
          1, // No stretching by default
          density * 2 - 1, // Shift bins based on density
          1 // No rotation
        );
        
        // Texture-specific processing
        // (This would be expanded with more sophisticated treatments)
        
        // Feedback path for richness
        processed = IFFT(fft_chain);
        fft_chain = FFT(LocalBuf(actual_size), 
          processed + (LocalIn.ar(1) * feedback)
        );
        
        // Final conversion back to time domain
        processed = IFFT(fft_chain);
        
        // Apply feedback
        LocalOut.ar(processed);
        
        processed;
      });
      
      // Mix with dry signal
      output = (output * mix) + (input * (1 - mix));
      
      // Apply amplitude
      output = output * amp;
      
      // Output to hardware channels
      Out.ar(out, output);
    }).add;
    
    // Command handlers for macro controls
    this.addCommand(\amp, "f", { arg msg;
      synth.set(\amp, msg[1]);
    });
    
    this.addCommand(\mix, "f", { arg msg;
      synth.set(\mix, msg[1]);
    });
    
    this.addCommand(\freeze, "f", { arg msg;
      synth.set(\freeze, msg[1]);
    });
    
    this.addCommand(\texture, "f", { arg msg;
      synth.set(\texture, msg[1]);
    });
    
    this.addCommand(\definition, "f", { arg msg;
      synth.set(\definition, msg[1]);
    });
    
    this.addCommand(\structure, "f", { arg msg;
      synth.set(\structure, msg[1]);
    });
    
    this.addCommand(\density, "f", { arg msg;
      synth.set(\density, msg[1]);
    });
    
    this.addCommand(\feedback, "f", { arg msg;
      synth.set(\feedback, msg[1]);
    });
    
    this.addCommand(\threshold, "f", { arg msg;
      synth.set(\threshold, msg[1]);
    });
    
    this.addCommand(\fft_size, "i", { arg msg;
      synth.set(\fft_size, msg[1]);
    });
    
    this.addCommand(\set_character, "s", { arg msg;
      var char_name = msg[1].asSymbol;
      var params = character_params[char_name];
      
      if(params.notNil, {
        params.keysValuesDo({ arg key, value;
          synth.set(key, value);
        });
      });
    });
    
    // Wait for SynthDef to be added
    context.server.sync;
    
    // Create the synth
    synth = Synth.new(\SpectrumSplice, [
      \out, context.out_b.index,
      \amp, 0.8,
      \mix, 0.5,
      \freeze, 0,
      \texture, 0.5,
      \definition, 0.5,
      \structure, 0.5,
      \density, 0.5,
      \feedback, 0.2,
      \threshold, 0.5,
      \fft_size, 1
    ], context.xg);
  }
  
  free {
    synth.free;
    fft_buf.free;
  }
}
