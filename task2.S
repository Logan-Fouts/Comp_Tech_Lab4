/*
Task 2: Binary counter with reset button
Connect four LEDs in a row to make a binary counter. The counter should
count from 0000 to 1111. The picture below shows the counter counting
from 0000 to 0011. Also, you have to implement a reset button that resets the
counter to 0000 when pressed. 

The LEDs should be connected to ports GP1, GP2, GP3 and GP4 and the
reset button to GP0.
Requirements:
 There should be 2 seconds interval between the counter values.
 Stop the count when the counter reaches its maximum value 1111.
 At any time, the Reset button should reset the counter to 0000.
 You have to use timer interrupts to handle the counter, not the
sleep_ms function!
 The reset button must have a fast response, and one should not be
required to hold the button for some time before the counter resets!
This can be made possible by using timer interrupts. 
 */