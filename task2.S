@
@ Assembler program to flash three LEDs connnected to the
@ Raspberry Pi GPIO using timer interrupts to trigger the
@ next LED to flash.
@

#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"
#include "hardware/regs/m0plus.h"

	.EQU RESETBUTTON, 0
	.EQU LED1, 1
	.EQU LED2, 2
	.EQU LED3, 3
	.EQU LED4, 4
	.EQU GPIO_IN, 0

	.EQU alarm0_isr_offset, 0x40

.thumb_func		@ Needed since SDK uses BX to call us
.global main	        @ Provide program starting address

	.align  4	@ necessary alignment
main:
	

@ Init each of the three pins and set them to output
	MOV R0, #RESETBUTTON
	BL gpioinit
	MOV R0, #RESETBUTTON
	MOV R1, #GPIO_IN
	BL link_gpio_set_dir
	MOV	R0, #LED1		
	BL	gpioinit
	MOV	R0, #LED2
	BL	gpioinit
	MOV	R0, #LED3
	BL	gpioinit
	MOV R0, #LED4
	BL gpioinit

lop:
	BL	set_alarm0_isr	@ set the interrupt handler
	LDR	R0, alarmtime	@ load the time to sleep
	BL	set_alarm0	@ set the first alarm

	MOV	R7, #0		@ counter
loop:

	MOV R0, #RESETBUTTON
	BL gpio_get_in
	MOV R2, #1
	CMP R2, R0
	BEQ reset
       
    B	loop	@ loop forever

reset:
	Mov R0, #0
	LDR R2, =state
	STR R3, [R2]
	B main
	

set_alarm0:
	@ Set's the next alarm on alarm 0
	@ R0 is the length of the alarm

	@ Enable timer 0 interrupt
	LDR	R2, timerbase
	MOV	R1, #1		@ for alarm 0
	STR	R1, [R2, #TIMER_INTE_OFFSET]

	@ Set alarm 
	LDR	R1, [R2, #TIMER_TIMELR_OFFSET]
	ADD	R1, R0
	STR	R1, [R2, #TIMER_ALARM0_OFFSET]

	BX	LR

.thumb_func	@ necessary for interrupt handlers
@ Alarm 0 interrupt handler and state machine.
alarm_isr:
	PUSH	{LR}	@ calls other routines
	@ Clear the interrupt
	LDR	R2, timerbase
	MOV	R1, #1		@ for alarm 0
	STR	R1, [R2, #TIMER_INTR_OFFSET]

	@ Disable/enable LEDs based on state
	LDR	R2, =state @ load address of state
	LDR	R3, [R2]   @ load value of state
	MOV	R0, #1
	ADD	R3, R0	   @ increment state
	STR	R3, [R2]   @ save state
step1:	
	MOV	R1, #1	   @ case state == 1
	CMP	R3, R1
	BNE	step2	   @ not == 1 check next
	@ Number 0
	B	finish
step2:	
	MOV	R1, #2	@ case state == 2
	CMP	R3, R1
	BNE	step3	@ not == 2 then case else
	@ Number 1
	MOV R0, #LED1
	BL gpio_on
	B	finish
step3:	
	MOV	R1, #3	@ case else
	CMP R3, R1
	BNE step4
	@ Number 2
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_on
	B finish
step4:
	MOV R1, #4
	CMP R3, R1
	BNE step5
	@ Number 3
	MOV R0, #LED1
	BL gpio_on
	B finish
step5:
	MOV R1, #5
	CMP R3, R1
	BNE step6
	@ Number 4
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_off
	MOV R0, #LED3
	BL gpio_on
	B finish
step6:
	MOV R1, #6
	CMP R3, R1
	BNE step7
	@ Number 5
	MOV R0, #LED1
	BL gpio_on
	B finish
step7:
	MOV R1, #7
	CMP R3, R1
	BNE step8
	@ Number 6
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_on
	B finish
step8:
	MOV R1, #8
	CMP R3, R1
	BNE step9
	@ Number 7
	MOV R0, #LED1
	BL gpio_on
	B finish
step9:
	MOV R1, #9
	CMP R3, R1
	BNE step10
	@ Number 8
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_off
	MOV R0, #LED3
	BL gpio_off
	MOV R0, #LED4
	BL gpio_on
	B finish
step10:
	MOV R1, #10
	CMP R3, R1
	BNE step11
	@ Number 9
	MOV R0, #LED1
	BL gpio_on
	B finish
step11:
	MOV R1, #11
	CMP R3, R1
	BNE step12
	@ Number 10
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_on
	B finish
step12:
	MOV R1, #12
	CMP R3, R1
	BNE step13
	@ Number 11
	MOV R0, #LED1
	BL gpio_on
	B finish
step13:
	MOV R1, #13
	CMP R3, R1
	BNE step14
	@ Number 12
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_off
	MOV R0, #LED3
	BL gpio_on
	B finish
step14:
	MOV R1, #14
	CMP R3, R1
	BNE step15
	@ Number 13
	MOV R0, #LED1
	BL gpio_on
	B finish
step15:
	MOV R1, #15
	CMP R3, R1
	BNE step16
	@ Number 14
	MOV R0, #LED1
	BL gpio_off
	MOV R0, #LED2
	BL gpio_on
	B finish
step16:
	@ Number 15
	MOV R0, #LED1
	BL gpio_on
	Mov R0, #0
	LDR R2, =state
	STR R3, [R2]



finish:	LDR	R0, alarmtime	@ sleep time
	BL	set_alarm0	@ set next alarm
	POP	{PC}		@ return from interrupt

set_alarm0_isr:
	@ Set IRQ Handler to our routine
	LDR	R2, ppbbase
	LDR	R1, vtoroffset
	ADD	R2, R1
	LDR	R1, [R2]
	MOV	R2, #alarm0_isr_offset @ slot for alarm 0
	ADD	R2, R1
	LDR	R0, =alarm_isr
	STR	R0, [R2]

	@ Enable alarm 0 IRQ (clear then set)
	MOV	R0, #1	@ alarm 0 is IRQ0
	LDR	R2, ppbbase
	LDR	R1, clearint
	ADD	R1, R2
	STR	R0, [R1]
	LDR	R1, setint
	ADD	R1, R2
	STR	R0, [R1]
	
	BX	LR

@ Initialize the GPIO to SIO. r0 = pin to init.
gpioinit:
@ Initialize the GPIO	
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want	
	STR	R3, [R2, #SIO_GPIO_OE_SET_OFFSET]
	STR	R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]

@ Enable input and output for the pin
	LDR	R2, padsbank0
	LSL	R3, R0, #2	@ pin * 4 for register address
	ADD	R2, R3		@ Actual set of registers for pin
	MOV	R1, #PADS_BANK0_GPIO0_IE_BITS
	LDR	R4, setoffset
	ORR	R2, R4
	STR	R1, [R2, #PADS_BANK0_GPIO0_OFFSET]

@ Set the function number to SIO.
	LSL	R0, #3		@ each GPIO has 8 bytes of registers
	LDR	R2, iobank0	@ address we want
	ADD	R2, R0		@ add the offset for the pin number
	MOV	R1, #IO_BANK0_GPIO3_CTRL_FUNCSEL_VALUE_SIO_3
	STR	R1, [R2, #IO_BANK0_GPIO0_CTRL_OFFSET]
	BX	LR

@ Turn on a GPIO pin.
gpio_on:
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want
	STR	R3, [R2, #SIO_GPIO_OUT_SET_OFFSET]
	BX	LR

@ Turn off a GPIO pin.
gpio_off:
	MOV	R3, #1
	LSL	R3, R0	@ shift over to pin position
	LDR	R2, gpiobase	@ address we want
	STR	R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]
	BX	LR

	      	.align  4	@ necessary alignment
gpiobase:	.word	SIO_BASE     @ base of the GPIO registers
iobank0:	.word	IO_BANK0_BASE @ base of io config registers
padsbank0:	.word	PADS_BANK0_BASE
setoffset:	.word	REG_ALIAS_SET_BITS
timerbase:	.word	TIMER_BASE
ppbbase:	.word	PPB_BASE
vtoroffset:	.word	M0PLUS_VTOR_OFFSET
clearint:	.word	M0PLUS_NVIC_ICPR_OFFSET
setint:		.word	M0PLUS_NVIC_ISER_OFFSET
alarmtime:	.word	2000000
printstr:	.asciz	"Couting %d\n"

.data
state:		.word	0




