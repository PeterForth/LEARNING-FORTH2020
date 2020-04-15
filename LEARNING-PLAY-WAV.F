\ Play a sound wav file 
\ (c) Valentin First, February 17, 2004, Tuesday, 23:34 
\ adapted by PeterForth April2020

REQUIRE LOAD-CONSTANTS ~yz/lib/const.f
S" ~vsp/cons/mmedia.const" LOAD-CONSTANTS

WINAPI: PlaySound WINMM.DLL


CASE-INS OFF

: play-wav ( s -- )
  DROP >R (* SND_NODEFAULT SND_FILENAME *) 0 R> PlaySound DROP ;

: play-asynchro-wav ( s -- )
  DROP >R W: SND_FILENAME W: SND_ASYNC OR W: SND_NODEFAULT OR 0 R> 
  PlaySound DROP ;

: play-system-event-sound ( s -- )
 DROP >R (* SND_SYNC SND_ASYNC *) 0 R> PlaySound DROP
;

: play-synchro-system-event-sound ( s -- )
  DROP >R (* SND_SYNC SND_SYNC *) 0 R> PlaySound DROP ;


: stop-wave W: SND_APPLICATION 0 0 PlaySound DROP ;

: TEST-WAV  S" SYSTEMEXIT" play-system-event-sound  ; 