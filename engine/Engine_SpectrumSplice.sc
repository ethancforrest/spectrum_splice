// Engine_SpectrumSplice
// Basic spectral processor for Norns
Engine_SpectrumSplice : CroneEngine {
  var <synth;
  var <fft_buf;
  var <buffer;
  var <recorder;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }
  
  alloc {
    // Allocate FFT buffer
    fft_buf = Buffer.alloc(context.server, 2048);
    
    // Allocate recording buffer (10 seconds stereo)
    buffer = Buffer.alloc(context.server, context.server.sampleRate * 10.0, 2);
    
    SynthDef(\buffer_recorder, {
      arg out=0, bufnum=0, in=0;
      var input = SoundIn.ar(in, 2);
      RecordBuf.ar(input, bufnum, loop: 0, doneAction: 2);
    }).add;
    
    SynthDef(\spectrumSplice, {
      arg out=0, amp=1.0, mix=0.5, freeze=0, shift=0, stretch=1.0, 
          fft_overlap=0.5, fft_window=0;
      
      var input, output;
      
      // Input from hardware channels
      input = SoundIn.ar([0, 1]);
      
      // Apply processing to each channel separately
      output = Array.fill(2, {|i|
        var chan_in = input[i];
        var fft_chain;
        
        // FFT analysis with configurable parameters
        fft_chain = FFT(LocalBuf(2048), chan_in, fft_overlap, fft_window);
        
        // Spectral freeze
        fft_chain = PV_Freeze(fft_chain, freeze);
        
        // Pitch shift (spectral domain)
        fft_chain = PV_BinShift(fft_chain, stretch, shift);
        
        // Convert back to time domain
        IFFT(fft_chain);
      });
      
      // Mix with dry signal
      output = (output * mix) + (input * (1 - mix));
      
      // Apply amplitude
      output = output * amp;
      
      // Output to hardware channels
      Out.ar(out, output);
    }).add;
    
    // Command handlers
    this.addCommand(\amp, "f", { arg msg;
      synth.set(\amp, msg[1]);
    });
    
    this.addCommand(\mix, "f", { arg msg;
      synth.set(\mix, msg[1]);
    });
    
    this.addCommand(\freeze, "f", { arg msg;
      synth.set(\freeze, msg[1]);
    });
    
    this.addCommand(\shift, "f", { arg msg;
      synth.set(\shift, msg[1]);
    });
    
    this.addCommand(\stretch, "f", { arg msg;
      synth.set(\stretch, msg[1]);
    });
    
    this.addCommand(\fft_overlap, "f", { arg msg;
      synth.set(\fft_overlap, msg[1]);
    });
    
    this.addCommand(\fft_window, "i", { arg msg;
      synth.set(\fft_window, msg[1]);
    });
    
    this.addCommand(\record_start, "", { arg msg;
      if(recorder.notNil, { recorder.free });
      recorder = Synth.new(\buffer_recorder, [
        \bufnum, buffer.bufnum,
        \in, context.in_b.index
      ], context.xg);
    });
    
    this.addCommand(\record_stop, "", { arg msg;
      if(recorder.notNil, { recorder.free; recorder = nil; });
    });
    
    // Wait for SynthDef to be added
    context.server.sync;
    
    // Create the synth
    synth = Synth.new(\spectrumSplice, [
      \out, context.out_b.index,
      \amp, 0.8,
      \mix, 0.5,
      \freeze, 0,
      \shift, 0,
      \stretch, 1.0,
      \fft_overlap, 0.5,
      \fft_window, 0
    ], context.xg);
  }
  
  free {
    synth.free;
    fft_buf.free;
    buffer.free;
    if(recorder.notNil, { recorder.free });
  }
}