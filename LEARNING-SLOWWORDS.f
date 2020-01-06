\ LEARNING  SLOW WORDS 
\  SLOW WORDS =  "SWORDS"  WILL LIST 
\  ALL  VOCABULARIES CONTENT 
\  AT A SLOWER SPEED THAN THE NORMAL  "WORDS"  

REQUIRE /SYSTEMTIME lib/include/facil.f
 
0 VALUE start-time

: get-local-time ( -- )         \ get the local computer date and time
  SYSTEMTIME GetLocalTime DROP
;

: ms@ ( -- ms )
  get-local-time
  SYSTEMTIME wHour         W@     60 *
  SYSTEMTIME wMinute       W@ +   60 *
  SYSTEMTIME wSecond       W@ + 1000 *
  SYSTEMTIME wMilliseconds W@ +
;

: time-reset ( -- )  ms@ TO start-time ;

: .elapsed ( -- )
  ms@ start-time -
  1000 /MOD
  60 /MOD
  60 /MOD
  ." Elapsed time: "
  2 .0 [CHAR] : EMIT
  2 .0 [CHAR] : EMIT
  2 .0 [CHAR] : EMIT
  3 .0
;

: elapse ( -<commandline>- )
  time-reset EVALUATE CR .elapsed
;


: DELAY-SECONDS ( n --) 
                         time-reset
      BEGIN
     	  time-reset  
              GET-LOCAL-TIME	 
          SYSTEMTIME wSecond   W@ + 1000 *
	   DUP
	  UNTIL
DROP ;

 

USER >OUT
USER W-CNT

: NLIST ( A -> )
  @
  >OUT 0! CR W-CNT 0!
  BEGIN
    DUP KEY? 0= AND
  WHILE  30 PAUSE
    W-CNT 1+!
    DUP C@ >OUT @ + 74 >
    IF CR >OUT 0! THEN
    DUP ID.
    DUP C@ >OUT +!
    15 >OUT @ 15 MOD - DUP >OUT +! SPACES
    CDR
  REPEAT DROP KEY? IF KEY DROP THEN
  CR CR ." Words: " BASE @ DECIMAL W-CNT @ U. BASE ! CR
;

: SWORDS ( -- ) CR ." ---------SLOW WORDS STOP WITH ESC--------------- " CR \
  CONTEXT @ NLIST
   CR ." ---------------------------------------------------- " CR
;
