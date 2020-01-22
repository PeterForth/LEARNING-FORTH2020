\ LEARNING-TERMINAL.F

\ -----------------------------------------------------------------------------
\  original file  ComPort v1.0 for Windows by Pretorian  
\  Adapted and translated to ForthWin  by Peter Forth Sept.2019
\ -----------------------------------------------------------------------------

\ THE FILE  "FILE-TYPE-stream2.f"  must be present on the same directory

\ TRUE - strings are equal ignoring case

CASE-INS OFF    \  UP OR LOWER CASE IS DETECTED !!


\ handle  
0 VALUE com1
0 VALUE com2
0 VALUE com3
0 VALUE com4
0 VALUE com5
0 VALUE com6

\ buffer for reading / writing com port
CREATE buffcom 256 ALLOT

MODULE: HIDDEN

WINAPI: GetCommState		KERNEL32.DLL
WINAPI: SetCommState		KERNEL32.DLL
WINAPI: SetCommTimeouts		KERNEL32.DLL
WINAPI: PurgeComm		KERNEL32.DLL
WINAPI: TransmitCommChar	KERNEL32.DLL
WINAPI: WaitCommEvent		KERNEL32.DLL
WINAPI: GetCommMask		KERNEL32.DLL

\ Port Read / Write Constants
-2147483648 CONSTANT GENERIC_READ
1073741824  CONSTANT GENERIC_WRITE

VARIABLE tempcom
VARIABLE ReadBuffer
VARIABLE EvtMask


0
CELL -- DCBlength \ sets the length, in bytes, of the DCB structure. 
CELL -- BaudRate \ baud rate. 
CELL -- Mode \ enables the binary exchange mode (these are flags). 
2 -- wReserved \ is not used, should be set to 0. 
2 -- XonLim \ the minimum number of characters in the receive buffer before sending the XON character. 
2 -- XoffLim \ the number of bytes in the receive buffer before sending the XOFF character. 
1 -- ByteSize \ the number of information bits in the transmitted and received bytes. 4-8
1 -- Parity \ parity scheme 
	\ 0-4 = complement to parity, 1, absent, supplement to odd, 0 
 1 -- StopBits \ sets the number of stop bits. 0,1,2 = 1, 1.5, 2
1 -- XonChar \ sets the XON character used for both reception and transmission. 
1 -- XoffChar \ sets the XOFF character used for both reception and transmission. 
1 -- ErrorChar \ sets the character used to replace characters with error parity. 
1 -- EofChar \ sets the character used to signal the end of the data. 
1 -- EvtChar \ sets the character used to signal an event. 
2 -- wReserved1 \ is reserved and not used. 
CONSTANT DCB
HERE DUP >R DCB DUP ALLOT ERASE VALUE MyDCB

0   
CELL -- ReadIntervalTimeout \ Maximum time, in milliseconds, allowed between two consecutive characters read from a communication line. 
CELL -- ReadTotalTimeoutMultiplier \ Specifies the multiplier, in milliseconds, used to calculate the total timeout of a read operation. 
CELL -- ReadTotalTimeoutConstant \ Sets the constant, in milliseconds, used to calculate the total timeout of a read operation. 
CELL -- WriteTotalTimeoutMultiplier \ Specifies the multiplier, in milliseconds, used to calculate the total timeout of a write operation.
CELL -- WriteTotalTimeoutConstant \ Sets the constant, in milliseconds, used to calculate the total timeout of a write operation.
CONSTANT COMMTIMEOUTS
HERE DUP COMMTIMEOUTS DUP ALLOT ERASE VALUE CommTimeouts

\ 
\ Opening com port by his name
: ComOpen ( á-addr u -> handle )
DROP >R
0 0 OPEN_EXISTING 0 0 GENERIC_READ GENERIC_WRITE OR R> CreateFileA
DUP -1 = IF DROP 0 THEN ;

\ Initial port initialization
: ComInit ( handle -> ior )
	>R
	DCB MyDCB DCBlength !
	MyDCB R> DUP >R GetCommState DROP
	\ 9600 MyDCB BaudRate ! 
    19200 MyDCB BaudRate ! 
	0x80000000 MyDCB Mode !
	8 MyDCB ByteSize C!
	1 MyDCB StopBits C!
	 0 MyDCB Parity C!
 \   0 MyDCB Parity C!
	MyDCB R> SetCommState ; 


\ Set timeouts for reading / writing to the port
: Timeouts ( handle ms -> flag )
	SWAP >R
	10  CommTimeouts ReadIntervalTimeout !   \ 10 
	1   CommTimeouts ReadTotalTimeoutMultiplier !
	    CommTimeouts ReadTotalTimeoutConstant !
	70 CommTimeouts WriteTotalTimeoutMultiplier !    \ 100 ****************
	1   CommTimeouts WriteTotalTimeoutConstant !
	    CommTimeouts R> SetCommTimeouts ;


EXPORT
\ Opens port com1
: COM1 ( -> flag )
	S" COM1" ComOpen DUP TO com1 0<> 
	IF com1 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\ Opens com2 port
: COM2 ( -> flag )
	S" COM2" ComOpen DUP TO com2 0<> 
	IF com2 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\ Opens com3 port
: COM3 ( -> flag )
	S" COM3" ComOpen DUP TO com3 0<> 
	IF com3 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\   com4\ Opens com4 port
: COM4 ( -> flag )
	S" COM4" ComOpen DUP TO com4 0<> 
	IF com4 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;

: COM6 ( -> flag )
	S" COM6" ComOpen DUP TO com6 0<> 
	IF com6 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;


\ Close com port
: COMClose ( handle -> ior )
	CloseHandle ;

\ Read line from com to buffer
: COMRead ( handle -> c-addr u )
	>R 0 tempcom 256 buffcom R> ReadFile DROP
	buffcom ASCIIZ> 1- DUP 0< IF DROP 0 THEN ;

\ Write string to com port
: COMWrite ( c-addr u handle -> )
	>R SWAP 0 tempcom 2SWAP R> WriteFile DROP ;

\ Print to the console a line from the com buffer
: .COM ( c-addr u -> )
	TYPE  buffcom 256 ERASE   0 buffcom !   0 tempcom ! ;


\ Receive character from port
: COMIn ( handle -- char )
	0 ReadBuffer ! >R 0 tempcom 1 ReadBuffer R> ReadFile DROP
	ReadBuffer C@ ;

\ Transmit a character to an open port
: COMOut ( char handle -- )
	TransmitCommChar DROP ;

\ Port setting
: COMSet ( handle BaudRate ByteSize StopBits Parity -> ior )
 MyDCB Parity C!
 MyDCB StopBits C!
 MyDCB ByteSize C!
 MyDCB BaudRate !
 MyDCB SetCommState 0 <> ;


\ Clears the transmit / receive queue in the com port driver
: COMClear ( handle -> )
	DUP 12 SWAP PurgeComm DROP ;


;MODULE

\  : KEY-SEND0    KEY   com2   COMOut 10 PAUSE ;    \ ( char handle -- )

0 VALUE CHARSS
CREATE SENDKBUF  256 ALLOT

: KEY-SEND  ( --)       CR                          \ 20 PAUSE    
         SENDKBUF  80 ACCEPT  ?DUP IF               \ Write string to com port
                              SENDKBUF SWAP com2  COMWrite ( c-addr u handle -> )
                              13 com2 COMOut        \  ( send cr) 
                               THEN 
                               SENDKBUF  256 BLANK  \ 20 PAUSE
                               com2 COMClear 0 buffcom ! \ buffcom 256 BLANK
   ;        
   
\ Transmit a character to an open port
\  : COMOut ( char handle -- )
\  : COMWrite ( c-addr u handle -> ) >R SWAP 0 tempcom 2SWAP R> WriteFile DROP ;

: EXITCOM CR ." --CLOSING COM2, RETURN TO FORTHWIN !-- " CR  com2 COMClose DROP ;
\ : COMClose ( handle -> ior )

\ =============================================================

REQUIRE  TTEST-FILE   c:\forthw2big\FILE-TYPE-stream2.f  

\ =============================================================


\ FILE-TYPE-stream2.f


: main   ( --) 
           CR    ." ------COMMUNICATION PROGRAM------" CR
           CR    ." ------   ESC  TO EXIT   ---------" CR           
           SENDKBUF  256 BLANK 
	  COM2
	IF  ." COM2  19200 N 8  1 Open "  CR  
        ." USE  'SPACE'  TO SEND ANY COMMAND " CR CR 
	COMClear
	 BEGIN
	 
	  com2 COMRead .COM
     
      KEY? IF KEY CASE  27 OF  EXITCOM EXIT ENDOF 
                        8  OF  TTEST-FILE ( FILE SEND)     ENDOF   ( CTRL G OR CTRL F 6) 
                     KEY-SEND   
                     ENDCASE 
                  
           THEN  

	 AGAIN
	THEN
;

  main


 
 
\EOF

By default, com ports have settings:
 - speed: 9600
 - data bit: 8
 - parity: no
 - stop bits: 1

com1 (-> handle) - handle of com1 after initialization
com2 (-> handle) - handle of com2 after initialization
com3 (-> handle) - handle of com3 after initialization
com4 (-> handle) - handle of com4 after initialization

COM1 (-> flag) - opens com1 port
COM2 (-> flag) - opens com2 port
COM3 (-> flag) - opens com3 port
COM4 (-> flag) - opens com4 port
COMClose (handle -> ior) - close com port
COMRead (addr u handle -> c-addr u) - read a string from com into the buffer
COMWrite (c-addr u handle ->) - write a line to com port
COMIn (handle - char) - receiving a character from a port
COMOut (char handle -) - transmit character to open port
COMSet (handle BaudRate ByteSize StopBits Parity -> ior) - setting
		port
COMClear (handle ->) - clears the send / receive queue in the port driver com



\EOF

VARIABLE BUFCOM
VARIABLE READBYTE
VARIABLE WRITEBYTE

: COMMLOOPTEST    COM2  IF  COMClear ELSE EXIT THEN 
 ." Type any key" CR
 BEGIN
   KEY
   DUP ." Write to Com:" . CR
   DUP BUFCOM !
   com6 ( @ )  BUFCOM 4 READBYTE 0 WriteFile DROP

   0 BUFCOM !
    com2 ( @ )  BUFCOM 4 WRITEBYTE 0 ReadFile DROP
   BUFCOM @ ." Read From Com:" . CR

   0x1B =               \ escape to quit
 UNTIL
;

