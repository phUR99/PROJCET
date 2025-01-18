;�����

;����
	ORG 	8000H
DATAOUT	EQU 	0FFF0H ;������ �ƿ��� �ּ�
DATAIN 	EQU 	0FFF1H ;������ ���� �ּ�

;segment
SEG1	EQU 	0FFC1H
SEG2	EQU 	0FFC2H
SEG3	EQU 	0FFC3H

SCORE	EQU	29H ;score
MOV	SCORE,#00H ;�ʱ�ȭ score

;DOT-MATRIX
COLGREEN   	EQU 0FFC5H
COLRED      	EQU 0FFC6H
ROW      	EQU 0FFC7H

SROW      	EQU 30H      ;SNAKE�� ROW 
SCOL      	EQU 31H      ;SNAKE�� COL
FROW      	EQU 32H      ;������ ROW
FCOL      	EQU 33H      ;������ COL

;����ġ �ʱ�ġ
MOV	SROW,#00010000B	
MOV	SCOL,#00010000B

CALL	DOTCOLG 	;�� ���

;LCD ǥ��
LCDWIR	EQU 	0FFE0H 	;LCD IR WRITE
LCDWDR	EQU 	0FFE1H 	;LCD DR WRITE
LCDRIR 	EQU 	0FFE2H 	;LCD IR READ
LCDRDR 	EQU	0FFE3H 	;LCD DR READ

;variable
INST 	EQU 	20H 	;LCD INST �� ����
DATA 	EQU 	21H 	;LCD DATA �� ����
LROW 	EQU 	22H 	;ROW �� 
LCOL 	EQU 	23H 	;COL ��
NUMFONT EQU 	24H 	;MESSAGE �� ����
FDPL	EQU 	25H 	;DPL �� ����
FDPH	EQU 	26H	;DPH �� ����

CLEAR 	EQU 	01H	;CLEAR ��� 
CUR_HOME EQU 	02H	;CURSOR HOME ��ġ�� ����
ENTRY2 	EQU 	06H 	;ADDR +1, CURSOR OR BLINK�� ��� �̵�
DCB6 	EQU 	0EH	;ǥ��, Ŀ��, ��ũ
FUN5 	EQU 	38H	;0��Ʈ 2��

LINE_1	EQU 	80H 	;LCD 1��° �ٷ� �̵�
LINE_2	EQU 	0C0H 	;LCD 2��° �ٷ� �̵�

KEY_STATE	EQU	27H ;Ű ������ ����

;���� ����

MOV	R6,#00H 	;R6 �ʱ�ȭ	
GAME_PHASE	EQU 36H ;GAME PHASE �� ����
MOV	GAME_PHASE,#00H ;GAME_PHASE �ʱ�ȭ

MOV	R7,#00H		;R7 �ʱ�ȭ
GAME_PAUSE	EQU 35H ;GAME PAUSE �� ����
MOV	GAME_PAUSE,#00H ;GAME_PAUSE �ʱ�ȭ
	
TIME	EQU	28H	;�ð� �� ����
MOV	TIME,#00H	;�ð� �ʱ�ȭ

LIFE	EQU	34H	;����� ����
MOV	LIFE,#03H	;��� �� �ʱ�ȭ(3��)


MOV	P1,#11111000B	;port diode �ʱ⼳��

;lcd �ʱ�ȭ
LCD_INIT:
	MOV 	INST, #FUN5	;#FUN5 �� INST�� �Ҵ�
	CALL 	INSTWR		;LCD ���


	MOV 	INST, #DCB6	;#DCB6 �� INST�� �Ҵ�
	CALL 	INSTWR		;LCD ���


	MOV 	INST, #CLEAR	;#CLEAR �� INST�� �Ҵ�
	CALL 	INSTWR		;LCD ���


	MOV 	INST, #ENTRY2	;#ENTRY2 �� INST�� �Ҵ�
	CALL 	INSTWR		;LCD ���


;Ÿ�̸� �ʱ�ȭ
	MOV TMOD,#00000001B	;GATE=0,TIMER MODE,RUN MODE 01
	MOV 	IE,#10000011B   ; ���ͷ�Ʈ0 �̶� Ÿ�̸�0 ���ͷ�Ʈ Ȱ��ȭ
	MOV	TH0,#00011111B  ; 57600 cycle * 16 = 1second
	MOV 	TL0,#00H	;

;interrupt setting
MOV   	IP, #00000001B 		; ���ͷ�Ʈ0 �켱���� ����
SETB     IT0 			; interrupt 0�� ���� ��� ����: dedge trigger

;�ʱ�ȭ��----------------------------------------------------------------------
MAINSCREEN0:
	MOV 	R0 , #02H	;R0 �� �Ҵ�

MAINSCREEN:
	DEC 	R0		;R0 �� ����
	MOV 	LROW,#01H	;ROW �� �Ҵ�
	MOV 	LCOL, R0	;COL �� �Ҵ�
	CALL 	CUR_MOV		;CURSOR �� ����

	MOV 	DPTR,#MESSAGE1	;#MESSAGE1 �Ҵ�
	MOV 	FDPL, DPL	;DPL�� �Ҵ�
	MOV 	FDPH, DPH	;DPH�� �Ҵ�
	MOV 	NUMFONT, #0EH	;MESSAGE�� ����
	CALL 	DISFONT		;LCD�� MESSAGE ���

	CALL	FINDKEYCODE	;KEYPAD �Է��� üũ

	MOV 	LROW, #02H	;ROW �� �Ҵ�
	MOV 	LCOL, R0	;COL �� �Ҵ�
	CALL 	CUR_MOV		;CURSOR �� ����

	MOV 	DPTR, #MESSAGE2	;#MESSAGE2 �Ҵ�
	MOV	FDPL, DPL	;DPL�� �Ҵ�
	MOV 	FDPH, DPH	;DPH�� �Ҵ�
	MOV 	NUMFONT, #0EH	;MESSAGE�� ����
	CALL 	DISFONT		;LCD�� MESSAGE ���


	CJNE 	R0, #00H, MAINSCREEN1	;R0���� üũ�ؼ� MAINSCREEN1���� ����
	MOV 	R0, #14H		;R0 �� �Ҵ�

MAINSCREEN1:
	CALL 	DELAY		;������ �ð���ŭ ����
	MOV 	INST,#CLEAR	;#CLEAR���� INST�� �Ҵ�
	CALL 	INSTWR		;LCD �ʱ�ȭ
	CALL	FINDKEYCODE	;�Է� üũ
	CALL	START_PRESS	;�Է� ������ Ż��
	JMP 	MAINSCREEN	;����

START_PRESS:  	CJNE   A, #0FFH, START_PRESS1 ;�ƹ��ų� ������ Ż��
		RET

START_PRESS1:  	MOV	KEY_STATE,A	;�Է� ���� �Ҵ�	
		JMP	MAIN		;MAIN ����

NO_KEY:   	RET			;�Է�X �ݺ�

;����---------------------------------------------------------

MAIN:	SETB	TCON.TR0	;Ÿ�̸� ����
	MOV	P1,#11111000B	;��� �ʱ�
	CALL	FOOD_GENERATE 	;�ʱ������ġ ����
	MOV	A,SCORE		;���� �ʱ�
	DA	A		;
	CALL	DISSEC		;SEGMENT �ʱ�ȭ
MAINLOOP:
	MOV	R3,#08H		;�ݺ�Ƚ�� �ʱ�ȭ
	
DELAY7:
	CALL	DOTCOLR_CLEAR	;�� �ʱ�ȭ 
	CALL	DOTCOLG		;��ǥ��
	CALL	DELAY4		;������ �ð���ŭ ����
	CALL	FINDKEYCODE	;�߰��߰� Ű �Է�Ȯ��
	CALL	IF_INT0		;INT0 CHECK
	CALL	DOTCOLG_CLEAR	;�� �ʱ�ȭ
	CALL	DOTCOLR		;����ǥ��
	CALL	DELAY4		;������ �ð���ŭ ����	
	CALL	FINDKEYCODE	;�Է� üũ
	DJNZ	R3,DELAY7	;8ȸ�ݺ�

	CALL	MOVE		;�̵�
	CALL	FOOD_CHECK	;���� �Ծ�����Ȯ��
	JMP	MAINLOOP	;�ݺ�

;INT0�� ���ؼ� INTERRUPT �Ǿ��� �� ����ϴ� �����ƾ
IF_INT0:
	MOV	A,GAME_PAUSE	;���ͷ�Ʈ ���� üũ
	CJNE	A,#00H,WAIT	;���ͷ�Ʈ ���Է� ������ ��� ����
	RET		

WAIT:	JMP	IF_INT0		;���ͷ�Ʈ ���Է� ������ ��� ����
;**********************************************
;LCD����
;CURSOR�� ����
CUR_MOV:
	MOV 	A, LROW		;ROW �� �Ҵ�
	CJNE 	A, #01H, NEXT	;ROW �� üũ
	MOV 	A,#LINE_1	;�ּ� �Ҵ�
	ADD 	A, LCOL		;�ּ� + COL�� 
	MOV 	INST,A		;�ּ� INST�� �Ҵ�
	CALL 	INSTWR		;�ּ��� �� ���
	JMP 	RET_PT		;RETURN
NEXT:
	CJNE 	A,#02H, RET_PT	;�� CHECK
	MOV 	A, #LINE_2	;�ּ� �Ҵ�
	ADD 	A, LCOL		;�ּ� + COL�� 
	MOV 	INST ,A		;�ּ� INST�� �Ҵ�
	CALL 	INSTWR		;�ּ��� �� ���


RET_PT:				;RETURN
	RET		



DISFONT: 
	MOV 	R5, #00H	;R5�� �ʱ�ȭ
	MOV 	R6, LCOL	;COL�� �Ҵ�

FLOOP: 
	MOV 	DPL, FDPL 	;�����ߴ� DPL�� �Ҵ�
	MOV 	DPH, FDPH	;�����ߴ� DPH�� �Ҵ�
	MOV 	A, R5		;R5�� A�� �Ҵ�
	MOVC 	A,@A+DPTR	;DIODE�� �ּ� �Ҵ�
	MOV 	DATA, A		;�ּҸ� DATA�� �Ҵ�
	CALL 	DATAWR		;DATA ���
	INC 	R5		;R5+
	INC 	R6		;R6+
	CJNE 	R6,#14H,DISFONT1	;R6�� ������ CHECK
	MOV 	R6,#00H			;R6�� ������ CHECK
	MOV 	LCOL, R6		;COL�� �Ҵ�
	CALL 	CUR_MOV			;CURSOR ����
DISFONT1: 
	MOV 	A, R5			;R5 �Ҵ�
	CJNE 	A,NUMFONT,FLOOP		;NUMFONT ��
	RET				;RET
;�귯�� �ð� ǥ��
;****************************************
;100A+10B+C�� �������� 10���� ���·� SEGMENT�� �����
DISFONT_GAMETIME:
   		MOV   	A, TIME		;�ð� A �Ҵ�
   		MOV   	B, #100		;���� B �Ҵ�
   		DIV   	AB		;A/B (A��, B������)
   		MOV     DPL, FDPL	;�����ߴ� DPL�� �Ҵ�
   		MOV     DPH, FDPH	;�����ߴ� DPH�� �Ҵ�
   		MOVC    A, @A+DPTR	;DIODE�� �ּҿ� �� �Ҵ�
   		MOV     DATA, A		;�ּҸ� DATA�� �Ҵ�
   		CALL    DATAWR		;DATA ���

   		MOV   	A, B		;B SHIFT A
   		MOV   	B, #10		;B�� 10�Ҵ�
   		DIV   	AB		;A/B (A��, B������)
   		MOV     DPL, FDPL	;�����ߴ� DPL�� �Ҵ�
   		MOV     DPH, FDPH	;�����ߴ� DPH�� �Ҵ�
   		MOVC   	A, @A+DPTR	;DIODE�� �ּҿ� �� �Ҵ�	
   		MOV   	DATA, A		;�ּҸ� DATA�� �Ҵ�
   		CALL    DATAWR		;DATA ���

   		MOV   	A, B		;B SHIFT A
   		MOV   	B, #10		;B�� 10�Ҵ�
   		DIV   	AB		;A/B (A��, B������)
   		MOV   	A, B		;B SHIFT A
   		MOV     DPL, FDPL	;�����ߴ� DPL�� �Ҵ�
   		MOV     DPH, FDPH	;�����ߴ� DPH�� �Ҵ�
   		MOVC   	A, @A+DPTR	;DIODE�� �ּҿ� �� �Ҵ�
   		MOV   	DATA, A		;�ּҸ� DATA�� �Ҵ�
   		CALL   	DATAWR		;DATA ���
   		RET        		;RET
;*********************************************************
;CURSOR�� �ʱ�ȭ
SET_CUR_ZERO: 
	MOV 	LCOL, #00H		;COL �ʱ�ȭ
	JMP	CUR_MOV			;CURSOR ����
	RET				;RET



INSTWR : 
	CALL 	INSTRD			;INST�� �о����
	MOV 	DPTR,#LCDWIR		;�ּ� �Ҵ�
	MOV 	A,INST			;�� ����
	MOVX 	@DPTR ,A		;�� �Ҵ�
	RET


DATAWR: 
	CALL 	INSTRD			;�о����
	MOV 	DPTR,#LCDWDR		;�ּ� �Ҵ�
	MOV 	A,DATA			;�� ����
	MOVX 	@DPTR, A		;�� �Ҵ�
	RET


INSTRD:
	MOV 	DPTR, #LCDRIR		;�ּ� �Ҵ�
	MOVX 	A, @DPTR		;�� �Ҵ�
	JB 	ACC.7, INSTRD		
	RET
;**************************************
;DELAY ����

;������ �ð���ŭ ����
DELAY: MOV 	R3, #05H
DELAY1: MOV 	R2, #0FFH
DELAY2: MOV 	R1, #0FFH
DELAY3:	DJNZ 	R1, DELAY3
	DJNZ 	R2,DELAY2
	DJNZ 	R3,DELAY1
	RET

;������ �ð���ŭ ����
DELAY4: MOV 	R2, #070H
DELAY5: MOV 	R1, #0FFH
DELAY6:	DJNZ 	R1, DELAY6
	DJNZ 	R2,DELAY5
	RET
 
;***************************************

MESSAGE1:
	DB 	'p','r','e','s','s'
	DB 	' ','A','n','y',' '
	DB 	'K','e','y',' '

MESSAGE2:
	DB 	't','o',' ','S','t'
	DB 	'a','r','t','!',' '
	DB 	' ',' ',' ',' '

MESSAGE_pause:
	DB 	'P','a','u','s','e'
	DB 	' ',' ',' ',' ',' '
	DB 	' ',' ',' ',' '
MESSAGE_over:
	DB 	'G','a','m','e',' '
	DB 	'O','v','e','r',' '
	DB 	' ',' ',' ',' '
NUMBER:   
   	DB '0','1','2','3','4'
   	DB '5','6','7','8','9'

MESSAGE_EMPTY:
	DB 	' ',' ',' ',' ',' '
	DB 	' ',' ',' ',' ',' '
	DB 	' ',' ',' ',' '
;**********************************************
;�Է� üũ
FINDKEYCODE: 
		PUSH PSW
		SETB PSW.4
		SETB PSW.3

INITIAL: 	MOV R1, #00H		;�ʱ�ȭ
		MOV A, #11101111B	;�ʱ� ��ġ ����
		SETB C			;CARRY 1

COLSCAN:	MOV R0, A		;A�� ����
		INC R1			;R1+
		CALL SUBKEY		:DATAOUT/DATAIN ����

		CJNE A,#0FFH,RSCAN	;���� �ִ��� üũ

		MOV A,R0		;R0 �� ����
		SETB C			;CARRY 1
		RRC A			;ROTATE A
		JNC RETURN	
		JMP COLSCAN		;RET

RSCAN:		MOV R2,#00H		;R2 �ʱ�ȭ

ROWSCAN:	RRC A			;ROTATE A
		JNC MATRIX
		INC R2			;R2+
		JMP ROWSCAN		;RET

MATRIX:	MOV 	A,R2			;R2 �� ����
	MOV 	B,#05H			;B �� �Ҵ�
	MUL 	AB			;A*B
	ADD 	A,R1			;A+R1
	CALL 	INDEX			;
	CALL	PRESS4			;
	POP 	PSW			;
	RET
;
SUBKEY:	MOV DPTR,#DATAOUT		;DATAOUT �ּ� �Ҵ�
	MOVX @DPTR,A			;A �� �Ҵ�
	MOV DPTR, #DATAIN		;DATAIN �ּ� �Ҵ�
	MOVX A,@DPTR			;A �� �Ҵ�
	RET

RETURN: POP PSW
	RET

;�Լ�Ű ����
RWKEY	EQU	10H
COMMA	EQU	11H
PERIOD	EQU	12H
GO	EQU	13H
REG	EQU	14H
CD	EQU	15H
INCR	EQU	16H
ST	EQU	17H
RST	EQU	18H

INDEX:	MOVC A,@A+PC
	RET

KEYBASE:	DB ST
		DB INCR		
		DB CD
		DB REG
		DB GO
		DB 0CH
		DB 0DH
		DB 0EH
		DB 0FH
		DB COMMA
		DB 08H	
		DB 09H
		DB 0AH
		DB 0BH		
		DB PERIOD
		DB 04H
		DB 05H		
		DB 06H
		DB 07H
		DB RWKEY		
		DB 00H
		DB 01H
		DB 02H		
		DB 03H
		DB RST
;--------------------------------------------------------------------
;Űüũ
PRESS4:   	CJNE   A, #04H, PRESS5   ; �Է°��� 4(����)���� Ȯ��
   		MOV    KEY_STATE, A	;KEY STATE ����
   		RET

PRESS5:   	CJNE   A, #05H, PRESS6   ; �Է°��� 5(�Ʒ�)���� Ȯ��
   		MOV    KEY_STATE, A	;KEY STATE ����
   		RET

PRESS6:   	CJNE   A, #06H, PRESS9   ; �Է°��� 6(����)���� Ȯ��
   		MOV    KEY_STATE, A	;KEY STATE ����
   		RET	

PRESS9:   	CJNE   A, #09H, NOTPRESS   ; �Է°��� 9(��)���� Ȯ��
   		MOV    KEY_STATE, A	;KEY STATE ����
NOTPRESS:   	RET

MOVE:		MOV	A,KEY_STATE		;KEY STATE ����

MOVE_LEFT:	CJNE	A,#04H,MOVE_DOWN;KEYPAD '4' CHECK
		MOV	A,SCOL		;COL �� ����
		CLR	C		;CARRY 0
		RRC	A		;ROTATE RIGHT
		JC	LIFE_DECREASE	;���� �ε����� �������
		MOV	SCOL,A		;����� COL �� �Ҵ�
		RET

MOVE_DOWN:	CJNE	A,#05H,MOVE_RIGHT;KEYPAD '5' CHECK
		MOV	A,SROW		;ROW �� ����
		CLR	C		;CARRY 0
		RLC	A		;ROTATE LEFT
		JC	LIFE_DECREASE	;���� �ε����� �������
		MOV	SROW,A		;����� ROW �� �Ҵ�
		RET

MOVE_RIGHT:	CJNE	A,#06H,MOVE_UP	;KEYPAD '6' CHECK
		MOV	A,SCOL		;COL �� ����
		CLR	C		;CARRY 0
		RLC	A		;ROTATE LEFT
		JC	LIFE_DECREASE	;���� �ε����� �������
		MOV	SCOL,A		;����� COL �� �Ҵ�
		RET

MOVE_UP:	CJNE	A,#09H,NOT_MOVE ;KEYPAD '9' CHECK
		MOV	A,SROW		;ROW �� ����
		CLR	C		;CARRY 0
		RRC	A		;ROTATE RIGHT
		JC	LIFE_DECREASE	;���� �ε����� �������
		MOV	SROW,A		;����� ROW �� �Ҵ�
NOT_MOVE:	RET

;---------------------------------------------------------------
;dot matrix
;�ʷϻ� ����

DOTCOLG_CLEAR:
   	MOV	DPTR, #COLGREEN 	;COLGREEN �ּ� �Ҵ�
	MOV   	A, #00H			;A �ʱ�ȭ
	MOVX   	@DPTR, A		;DPTR �ʱ�ȭ
	MOV    	DPTR,#ROW		;#ROW �ּ� �Ҵ�
	MOV    	A, #00H			;A �ʱ�ȭ
	MOVX   	@DPTR,A			;DPTR �ʱ�ȭ
	RET

;������ ����
DOTCOLR_CLEAR:
   	MOV	DPTR, #COLRED		;COLRED �ּ� �Ҵ�
	MOV   	A, #00H			;A �ʱ�ȭ
	MOVX   	@DPTR, A		;DPTR �ʱ�ȭ
	MOV    	DPTR,#ROW		;#ROW �ּ� �Ҵ�
	MOV    	A, #00H			;A �ʱ�ȭ
	MOVX   	@DPTR,A			;DPTR �ʱ�ȭ
	RET

;�ʷϹ� ǥ��
DOTCOLG:
	MOV	DPTR,#COLGREEN		;COLGREEN �ּ� �Ҵ�
	MOV	A,SCOL			;SCOL ����
	MOVX	@DPTR,A			;SCOL ���
	MOV	DPTR,#ROW		;ROW �ּ� �Ҵ�
	MOV	A,SROW			;SROW ����
	MOVX	@DPTR,A			;SROW ���
	RET
;�������� ǥ��
DOTCOLR:
	MOV	DPTR,#COLRED		;COLRED �ּ� �Ҵ�
	MOV	A,FCOL			;FCOL ����
	MOVX	@DPTR,A			;FCOL ���
	MOV	DPTR,#ROW		;ROW �ּ� �Ҵ�
	MOV	A,FROW			;FROW ����
	MOVX	@DPTR,A			;FROW ���
	RET
;----------------------------------------------------
;LIFE DECRAESE ���,���ӿ���

LIFE_DECREASE:
	MOV	A,LIFE			;LIFE �� �� ����
	CJNE	A,#00H,LIFE_DOWN	;����� 0���� CHECK
	
GAME_OVER:
	CLR	TCON.TR0	;�׾����� Ÿ�̸� ����
	MOV	LROW,#01H	;LCDROW �� �Ҵ�
	MOV 	LCOL,#02H	;LCDCOL �� �Ҵ�
	CALL 	CUR_MOV		;CURSOR ��ġ ����

	MOV 	DPTR,#MESSAGE_over ;�޽��� ���
	MOV 	FDPL, DPL		;DPL �� ����
	MOV 	FDPH, DPH		;DPH �� ����
	MOV 	NUMFONT, #0EH		;NUMFONT 0EH ����
	CALL 	DISFONT			;���
	JMP	GAME_OVER		;��
;��Ʈ ���̿��� �ϳ�����
LIFE_DOWN:
	DEC	A		;A-
	MOV	LIFE,A		;��� �ϳ� ����

	MOV	R1,A		;��� �� ����
	MOV	A,#03H		;A 3 �Ҵ�
	SUBB	A,R1		;A-R1
	MOV	R1,A		;R1 A �� ����
	MOV	A,#11111000B	;��ġ �ʱ�ȭ

AGAIN:	RR	A		;ROTATE R 
	DJNZ	R1,AGAIN	;R1�� CHECK
	ORL	A,#11111000B	;A�� �Ҵ�
	MOV	P1,A
	;���������� �� �����̰� ����ġ �ʱ�ȭ 1 
	MOV	DPTR,#COLRED	;COLRED �ּ� �Ҵ�
	MOV	A,#11111111B	;A�� �Ҵ�
	MOVX	@DPTR,A		;A MATRIX ���

	MOV	DPTR,#ROW	;ROW �ּ� �Ҵ�
	MOV	A,#11111111B	;A�� �Ҵ�
	MOVX	@DPTR,A		;A MATRIX ���

	CALL   	DELAY		;DELAY
	;���������� �� �����̰� ����ġ �ʱ�ȭ 2
	MOV	DPTR,#COLRED	;COLRED �ּ� �Ҵ�
	MOV	A,#00000000B	;A�� �Ҵ�
	MOVX	@DPTR,A		;A MATRIX ���

	MOV	DPTR,#ROW	;ROW �ּ� �Ҵ�
	MOV	A,#00000000B	;A�� �Ҵ�
	MOVX	@DPTR,A		;A MATRIX ���S

   	CALL   	DELAY		;����

	MOV	SROW,#00010000B	;����ġ �ʱ�ġ
	MOV	SCOL,#00010000B

	RET
;---------------------------------------------------
;���� �Ծ����� Ȯ��
FOOD_CHECK:
	MOV	A,FCOL		;FCOL �Ҵ�
	CJNE	A,SCOL,NO_EAT	;��ǥ ������ Ȯ��
	MOV	A,FROW		;FROW �Ҵ�
	CJNE	A,SROW,NO_EAT   ;��ǥ ������ Ȯ��
	 
	MOV	A,SCORE		;SCORE �Ҵ�
	INC	A		;SCORE+
	MOV	SCORE,A		;�� �Ҵ�
	DA	A
	CALL	DISSEC		;SEGMENT ����(SCORE)

;���� ����
FOOD_GENERATE:
	CLR   	TCON.TR0	;TIMER ����
	MOV	A,TL0		;TL0 �� �Ҵ�
	MOV	B,#03H		;B �� �Ҵ�
	MUL	AB		;A*B
	MOV	R1,A		;R1 �� �Ҵ�
	MOV	A,TL0		;TL0 �� �Ҵ�
	MOV	B,#07H		;B �� �Ҵ�
	MUL	AB		;A*B
	MOV	R2,A		;R2 �� �Ҵ�
	SETB	TCON.TR0	;TIMER ����
	MOV	A,#00000001B	;MATRIX �� �Ҵ�
; ������ COL ����
COL_GENERATE:
	RL	A		;ROTATE LEFT
	DJNZ	R1,COL_GENERATE	;R1 �� CHECK
	MOV	R1,A		;A �� �Ҵ�
	MOV	FCOL,A		;COL ���� FCOL�� �Ҵ�
	MOV	A,#00000001B
;������ ROW ����
ROW_GENERATE:
	RR	A		;ROTATE RIGHT
	DJNZ	R2,ROW_GENERATE	;R2 �� CHECK
	MOV	R1,A		;A �� �Ҵ�
	MOV	FROW,A		;ROW ���� FROW�� �Ҵ�
;���� ���� ��ġ�� ���� ��ġ�� ������ �ٽ� ����
	MOV	A,FCOL		
	CJNE	A,SCOL,NO_EAT	;SNAKE�� COL�� ��

	MOV	A,FROW          ;
	CJNE	A,SROW,NO_EAT	;SNAKE�� ROW ��

	JMP	FOOD_GENERATE 	;��ġ �����

NO_EAT:	RET

DISSEC:	MOV	DPTR,#SEG1	;SEG1 �ּ� �Ҵ�
	MOVX	@DPTR,A		;A �� ����
	MOV	A,#00H		;�ʱ�ȭ
	MOV	DPTR,#SEG2	;SEG2 �ּ� �Ҵ�
	MOVX	@DPTR,A		;A �� ����
	MOV	DPTR,#SEG3	;SEG3 �ּ� �Ҵ�
	MOVX	@DPTR,A		;A �� ����
	RET



;-----------------------------------------------------------------
;Ÿ�̸� ���ͷ�Ʈ
;ORG 9F0BH
;JMP TIMER

TIMER:	CLR    	TCON.TR0	;TIMER COUNTER �ʱ�ȭ
	SETB	TCON.TR0	;TIMER ����
	MOV	A,GAME_PHASE	;GAME PHASE �� �Ҵ�
	INC	A		;16�� �ݺ��� COUNT ����
	CJNE	A,#16,NOTCOUNT	;57600 cycle * 16 = 1second

COUNT:	MOV	A,#00H	
	MOV	GAME_PHASE,A	
	MOV  	A, TIME		;lcd�ð�������Ʈ
   	INC   	A
   	MOV   	TIME, A
	MOV 	INST,#CLEAR
	CALL 	INSTWR
	MOV     LROW,#02H
        MOV     LCOL,#02H
        CALL    CUR_MOV
        MOV     DPTR,#NUMBER
        MOV     FDPL,DPL
        MOV     FDPH,DPH
        CALL    DISFONT_GAMETIME
   	RETI

NOTCOUNT:
	MOV	GAME_PHASE,A 
	RETI

;------------------------------------------------------------
;���ͷ�Ʈ0
;ORG     9F03H
;JMP     INT0

INT0:	
	MOV	A,	GAME_PAUSE
	CJNE	A, #00H, OUT_LOOP
	CLR    	TCON.TR0
	MOV	A, #01H
	MOV	GAME_PAUSE,A
	
INT_LOOP:
	MOV	LROW,#01H
	MOV 	LCOL,#02H
	CALL 	CUR_MOV
	MOV 	DPTR,#MESSAGE_pause
	MOV 	FDPL, DPL
	MOV 	FDPH, DPH
	MOV 	NUMFONT, #0EH
	CALL 	DISFONT
	RETI

OUT_LOOP:	
	MOV	LROW,#01H
	MOV 	LCOL,#02H
	CALL 	CUR_MOV
	MOV 	DPTR,#MESSAGE_EMPTY
	MOV 	FDPL, DPL
	MOV 	FDPH, DPH
	MOV 	NUMFONT, #0EH
	CALL 	DISFONT
	MOV	A,#00H
	MOV	GAME_PAUSE,A
	SETB    TCON.TR0
	RETI


ORG     9F03H
JMP     INT0
ORG 9F0BH
JMP TIMER

END
