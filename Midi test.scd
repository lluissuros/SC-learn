// MIdi test

MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.cc(\slider7toAmp,
	{
		arg val, num, chan, src;
		var amp = val.linlin(0,127,0,0.1);
		("amp: "+amp).postln;
		~amp = amp;
	}
	,7,0);



// free
MIDIdef.freeAll;