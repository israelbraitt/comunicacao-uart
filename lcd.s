.global lcd_init
.global set_out
.global write
.global clear_lcd
.global delay
.global cgram_addr
.global set_cursor

.global map_e
.global map_rs
.global map_d7
.global map_d6
.global map_d5
.global map_d4

.include "gpio.s"

.macro nanoSleep time
        LDR R0,=\time      
        LDR R1,=\time        
        MOV R7, #162  
        SWI 0                
.endm

@ branch que pega um bit do valor hexadecimal do caractere
.macro get_bit
        MOV R2,#1 @ Move 1 para o registrador R0
        LSL R2,R0 @ Desloca para esquerda o valor em R2 para a posição do bit passado em R0
        AND R1, R6,R2 @ Realiza a operação lógica and para que seja pego apenas o bit desejado
        LSR R1,R0 @ Desloca para o bit menos significativo o bit da posição desejada
	
	.ltorg
.endm
@ Da um pulso no pino enable o ligando e desligando.
.macro enable
        GPIOTurn e, #0
        nanoSleep time1ms

        GPIOTurn e,#1
        nanoSleep time1ms

        GPIOTurn e, #0
        nanoSleep time1ms
        .ltorg
.endm

.macro fset_init

        GPIOTurn rs,#0

        GPIOTurn d7,#0

        GPIOTurn d6,#0

        GPIOTurn d5, #1

        GPIOTurn d4, #0

        enable
        .ltorg
.endm

.macro command data,rs_value
        MOV R6, \data

        GPIOTurn rs, #\rs_value

        MOV R0,#7
        get_bit
        GPIOTurn d7, R1

        MOV R0,#6
        get_bit
        GPIOTurn d6, R1

        MOV R0,#5
        get_bit
        GPIOTurn d5, R1

        MOV R0,#4
        get_bit
        GPIOTurn d4, R1

        enable

        GPIOTurn rs, #\rs_value

        MOV R0,#3
        get_bit
        GPIOTurn d7, R1


        MOV R0,#2
        get_bit
        GPIOTurn d6, R1


        MOV R0,#1
        get_bit
        GPIOTurn d5, R1


        MOV R0,#0
        get_bit
        GPIOTurn d4, R1

        enable
        .ltorg
.endm

offset_led:
	MOV R5,R0
	MOV R6,R1
	MOV R9,R2

	LDR R4,=led
	STR R5,[R4]
	
	LDR R4,=led
	ADD R4,#4
	STR R6,[R4]

	LDR R4,=led
	ADD R4,#8
	STR R9,[R4]
	BX LR

map_e:
	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=e
        STR R5,[R4]

        LDR R4,=e
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=e
        ADD R4,#8
        STR R9,[R4]
        BX LR

map_rs:

	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=rs
        STR R5,[R4]

        LDR R4,=rs
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=rs
        ADD R4,#8
        STR R9,[R4]
        BX LR

map_d7:
	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=d7
        STR R5,[R4]

        LDR R4,=d7
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=d7
        ADD R4,#8
        STR R9,[R4]
        BX LR

map_d6:
	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=d6
        STR R5,[R4]

        LDR R4,=d6
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=d6
        ADD R4,#8
        STR R9,[R4]
        BX LR

map_d5:
	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=d5
        STR R5,[R4]

        LDR R4,=d5
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=d5
        ADD R4,#8
        STR R9,[R4]
        BX LR

map_d4:
	MOV R5,R0
        MOV R6,R1
        MOV R9,R2

        LDR R4,=d4
        STR R5,[R4]

        LDR R4,=d4
        ADD R4,#4
        STR R6,[R4]

        LDR R4,=d4
        ADD R4,#8
        STR R9,[R4]
        BX LR

on_led:
	GPIOTurn led,#0
	BX LR

off_led:
	GPIOTurn led,#1
	BX LR

out_led:
	GPIODirectionOut led
	BX LR

lcd_init:
	command #0x01,0
	fset_init
	fset_init
	fset_init
	fset_init
	command #0x0e,0
	command #0x06,0
	BX LR
	
set_cursor:
	MOV R9,#0x80
	MOV R10,R0
	ORR R11,R9,R10
	command R11,0
	
	BX LR 
	
write:
	MOV R9,R0
	command R9,1
	
	BX LR
	
cgram_addr:
	MOV R6,R0
	MOV R5,#0x40
	ADD R5,R6
	command R5,0
	
	BX LR
	
clear_lcd:
	command #0x01,0
	BX LR

@ Seta todos os pinos do lcd como saída.
set_out:
        GPIODirectionOut e
        GPIODirectionOut rs
        GPIODirectionOut d7
        GPIODirectionOut d6
        GPIODirectionOut d5
        GPIODirectionOut d4
	
	BX LR
	
.data

.time1ms:
	.word 0
	.word 1000000
led:
	.word 0
	.word 0
	.word 0
@ Lcd

rs:
	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear
e:
	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear
d4: 
	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear
d5:
	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear 
d6:
	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear
d7:
 	.word 0 @ offset para selecionar o registrador de função
	.word 0 @ offset do pino no registrador de função
	.word 0 @ offset do pino no registrador de set e clear
