// MIdi test

// ask your OS, see postwindow, what midi devices are connected to your HW.
MIDIClient.init;

// Easiest way to connect, connects to all available devices
MIDIIn.connectAll;

//post nano info
MIDIdef.cc(\testBasic, {|val, num, chan, src|
	[val, num, chan].postln;
});

//use val.linexp(0,127,0,0.1) or linexp to map from 127 to good values!!!
MIDIdef.cc(\testNanoSlider8, {|val, num, chan, src|
	var amp = val.linlin(0,127,0,0.1);
	("amp: "+amp).postln;
	~amp = amp;
	}
	,7,0);



// free
MIDIdef.freeAll;


/*
       3. Finishing touch: Pitchbend!
       - pitch bend on all current notes
       - pitch bend to be a global state, so current pitch position is used by new notes.
       we need a third MIDIdef
*/





/*PLAYING KEYBOARD*/

//if you want to play a keyboard, need to listen to noteOn and noteOff. To keep track of all notes, we create an array with 128 position, each one repereseting a key.

~notes = Array.newClear(128);

// keep track of the pitchwheel position
// MIDIdef will update this value every time the pitchwheel is moved
~bend = 8192;

(
MIDIdef.bend(\bendTest, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);
)

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	["note on", vel, nn].postln;
	~notes[nn] = Synth.new(\tone, [
		\freq, nn.midicps,
		\amp, vel.linexp(1, 127, 0.01, 0.3),
		\gate, 1,
		// new notew, check current bent position first, remap.
		\bend, ~bend.linlin(0, 16383, -2, 2),
	]);
});
)

(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	["note off", vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});
)

// sound generator, adjust for bend
(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0, bend=0;
	var sig, env;
	sig = LFTri.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)