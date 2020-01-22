WINAPI: fopen   MSVCRT.DLL
WINAPI: fgets   MSVCRT.DLL
WINAPI: ferror  MSVCRT.DLL
WINAPI: fclose  MSVCRT.DLL
WINAPI: _fdopen MSVCRT.DLL
WINAPI: gets    MSVCRT.DLL

: R/O S" r" DROP ;

: OPEN-FILE ( addr u mode -- file ior )
  NIP SWAP fopen NIP NIP
  DUP 0=
;
: chop ( addr -- u )
  ASCIIZ> 2DUP + 1- C@ 10 = IF 1- THEN NIP
;
: READ-LINE ( addr u file -- u2 flag ior )
  ROT ROT             ( file addr u )
  SWAP fgets          ( file u addr res )
  NIP NIP             ( file res )
  ?DUP IF NIP chop TRUE 0 EXIT THEN
  0 0 ROT ferror NIP
;
: CLOSE-FILE ( file -- ior )
  fclose NIP
;
: AsStream ( h mode -- file ior )
  SWAP _fdopen NIP NIP
  DUP 0=
;
: ACCEPT ( c-addr +n1 -- +n2 ) \ 94
\  H-STDIN READ-LINE THROW DROP
  DROP gets NIP
  ?DUP IF ASCIIZ> NIP ELSE -1 THROW THEN
;
: REFILL ( -- flag ) \ 94 FILE EXT
  CURSTR 1+!
  TIB C/L
  SOURCE-ID 0 > IF SOURCE-ID ( included text )
                   READ-LINE THROW ( ошибка чтения )
                   IF #TIB !
                   ELSE DROP FALSE EXIT THEN
                ELSE SOURCE-ID
                     IF 2DROP FALSE EXIT THEN ( evaluate string )
                     ACCEPT #TIB ! ( user input )
                THEN
  >IN 0! <PRE> -1
;
: MAIN1 ( -- )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT BYE
;
: QUIT ( -- ) ( R: i*x ) \ CORE 94
 

  BEGIN
    CONSOLE-HANDLES
    0 TO SOURCE-ID
    [COMPILE] [
    ['] MAIN1 CATCH
    ['] ERROR  CATCH DROP
 ( S0 @ SP! R0 @ RP! \ стеки не сбрасываем, т.к. это за нас делает CATCH :)
  AGAIN
;

: TEST1
  S" C:\FORTHW\1.f" R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW  10 PAUSE
  WHILE
    PAD SWAP TYPE CR
  REPEAT DROP
  R> CLOSE-FILE THROW
;

:  TYPEF ( TYPE FILE )  \  S" BLABLA.TXT "  TYPEF 
  ( S" C:\FORTHW\1.f" )  R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW  10 PAUSE
  WHILE
    PAD SWAP TYPE CR
  REPEAT DROP
  R> CLOSE-FILE THROW
;



: TYPETOCOM   ( $str count --) 
                   com2  COMWrite ( c-addr u handle -> )
                              13 com2 COMOut        \  ( send cr) 
                               
                               \ SENDKBUF  256 BLANK  \ 20 PAUSE
                               com2 COMClear 0 buffcom !  
  130 PAUSE  ; 





:  TYPEFS ( TYPE FILE SLOW )  \  S" BLABLA.TXT "  TYPEFS 
  ( S" C:\FORTHW\1.f" )  R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW  35 PAUSE
  WHILE
    PAD SWAP 2DUP TYPE CR  TYPETOCOM
  REPEAT DROP
  R> CLOSE-FILE THROW
;

REQUIRE OpenDialog ~day\joop\win\filedialogs.f

 \ Sample

FILTER: fTest

  NAME" all files" EXT" *.*"
  \ NAME" exe files" EXT" *.exe"

;FILTER


OpenDialog :new VALUE tt

: title1
     S" SELECT A FILE NAME TO TYPE TO THE SCREEN "
;


: TTEST-FILE  ( --)   \ SEND A FILE OVER SERIAL
fTest tt :setFilter
title1 tt :setTitle
tt :execute DROP
CR CR
tt :fileName  TYPEFS
;




