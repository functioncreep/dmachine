MIDIClient.init;
MIDIFunc.trace;

(
// Drums --------------------------------

SynthDef(\kick, {arg
	freq = 40,
	punch = 0.05,
	decay = 0.45,
	amp = 0.5;

	var env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
	var freqenv = EnvGen.kr(Env.perc(0.01, punch));
	var synth = SinOsc.ar(freq + (freqenv * 100), 0, env);

	Out.ar([0,1], synth * amp);
}).add;

SynthDef(\clhat, {arg
	decay = 1,
	amp = 0.5;

	var env = EnvGen.kr(Env.perc(0.001, decay, curve: -20), doneAction: 2);
	var noise = WhiteNoise.ar(env);
	var filter = RHPF.ar(noise, 7000, 0.5);

	Out.ar([0,1], filter * amp);
}).add;

SynthDef(\ohat, {arg
	gate = 1,
	decay = 0.2,
	sustain = 0.5,
	release = 0.1,
	amp = 0.5;

	var env = EnvGen.kr(Env.adsr(0.01, decay, sustain, release), gate, doneAction: 2);
	var noise = WhiteNoise.ar(env);
	var filter = RHPF.ar(noise, 8000, 0.5);

	Out.ar([0,1], filter * amp);
}).add;

SynthDef(\reso, {arg
	decay = 0.8,
	amp = 0.5,
	gate = 1;

	// Pattern: \/\/\/ change 3rd resonator freq from 300 to 320 and back every four bars
	var env = EnvGen.kr(Env.adsr(0.01, 0.3, 0.7, 2), gate, doneAction: 2);
	var reso = DynKlank.ar(`[[40, 80, 300, 400, 800, 1200], [1, 1, 3, 1, 1, 1.2], [1, 1, 1, 1, 1, 1]], PinkNoise.ar([0.01,0.01]), 0.5, decayscale: decay);

	Out.ar([0,1], (reso * env) * amp);
}).add;
)

// MIDI note assignment --------------------------------

(
MIDIdef.noteOn(\kick, {arg val, note; k = Synth(\kick); k.set(\amp, val.linexp(0,127,0.01,0.9))}, 60);
MIDIdef.noteOn(\clhat, {arg val, note; l = Synth(\clhat); l.set(\amp, val.linexp(0,127,0.01,0.9))}, 61);
MIDIdef.noteOn(\ohat, {arg val, note; m = Synth(\ohat); m.set(\amp, val.linexp(0,127,0.01,0.9), \gate, 1)}, 62);
MIDIdef.noteOff(\hatoff, {m.set(\gate, 0)}, 62);
MIDIdef.noteOn(\reso, {arg val, note; r = Synth(\reso); r.set(\amp, val.linexp(0,127,0.01,0.9))}, 63);
MIDIdef.noteOff(\resoff, {r.set(\gate, 0)}, 63);
)