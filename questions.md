# Questions

## Stuff I've had to ask about or intend to ask about

### Compiler stuff:

---

#### Question 1

*Q* How do these 2 examples have the same effect as putting red in the background colour?

Why is 

```
dc.w	$180,$600	
```

the same as:

```
dc.w	$180
dc.w	$600
```

The first example sets red into the system register for background colour (DC.W DESTINATION:SOURCE). The second example is equivalent - how? Does the compiler 'know' that $180 within a copperlist is a special register and just accepts the next DC.w it comes across as the value? 

If you put the following in the copper list at the end, no complaints, code still runs. Is it putting $600 into location $700? What is the difference here?
```
dc.w	$700
dc.w	$600
```

The notes mention the equivalence [here](https://github.com/matthewdeaves/ramjamexamples/blob/f665095b002e28c2c511a8b7fb6a9d244eb8f473/SORGENTI/LEZIONE3c_colours.s#L235)

#### *Answer*

First, [watch this video](https://www.youtube.com/watch?v=ZPJW3wIfL4I)

An assembled program is loaded into memory starting from one starting address. Each memory address can can be thought of as a box that can hold a byte of data. See this example using ```h.w``` (hex dump of memory by size ```WORD```). Notice on the left column how the memory address increments.

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a4.png)

It's useful to use the h (hex dump) command to study this. The whole program is represented by each memory location laid out one after the other with its execution starting at the base address. If you start your program with a label such as

```
Init:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)		; Disable multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
```

You can use ```h.w Init``` to show the contents of memory from the address of the ```Init``` label:

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a3.png)

```dc``` writes directly to the memory sequentially. This is why the above examples are the same. To prove it start with the code:

```
BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79
	dc.w	$180,$600	; COLOR0 - I start the red zone: red at 6
```

Then use ```h.w BAR``` to show

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a1.png)


Then change the code to

```
BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79
	dc.w	$180 		; COLOUR0
	dw.w	600  		; red at 6 to start
```

Then use ```h.w BAR``` to show

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a2.png)

Notice it is the same data in the memory location of BAR whichever method we choose. There is still some magic to me in that the instruction at memory location ```$00000970```  being run by the copper results in register $dff180 taking the value of $0600 (red).

You can see ```FFFF FFFE``` in the pictures, which we know when run in the copper means the end of the copper list. This is because my code for these exmaples is

```

BAR:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79

	dc.w	$180
	dc.w	$600	; COLOR0 - I start the red zone: red at 6

	dc.w	$FFFF,$FFFE	; END OF COPPERLIST

	end
```

---

#### Question 2

*Q* What exactly is stored at each memory location? How is it organised?



#### *Answer*

Each memory location can store 1 byte. The below picture show using the memory command to inspect the memory contents for the label BARRA ```m BARRA```

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a5.png)

You can see BARRA starts are memory location ```$00016EC8``` and it contains a byte with value of ```79```. Each subsequent byte shown on the same line is the value stored at the next memory location. So ```$00016EC9``` contains 1 byte with value ```07``` and so on.

The debugger is showing us the memory contents 16 bytes per line which is why the second line of the output is labelled on the left with address ```$00016ED8```. I label each memory location on the first line to illustrate this.

If we look at the code where BARRA is defined, you can see the memory output matches what we would expect

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a6.png)

---

#### Question 3

*Q* Dispaying an image correctly - were am I going wrong with my example?

For example 4 code [here](https://github.com/matthewdeaves/ramjamexamples/blob/main/SORGENTI2/LEZIONE4b.s)

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q3.png)

Images used listed below (sizes seem messed up):

[Original 3 bit plane .iff](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/earth.iff)

[AGAiff exported no colour raw](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/earth_320x256x0.raw)

[AGAiff exported 3 bit plane raw](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/earth_320x256x3.raw)

#### *Answer*

The colours used to render the image are hard coded in the copper list in the code. See [this line onwards](https://github.com/matthewdeaves/ramjamexamples/blob/7ee1c1bd3649ed7f2bdd7d15db76672783dc2dae/SORGENTI2/LEZIONE4b.s#L115)

