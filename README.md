# ti83-tools
Collection of programs useful for preparing a grayscale bitmap (with 4 levels of gray) and displaying it on a TI-83 calculator

## Contents
**bmpremap.py** - modifies indices in a BMP with a color table (palette)

**bmp2z80.py** - converts an indexed BMP with 4 levels of gray (white, light gray, dark gray and black) to Z80 assembler data

**fix83p.py** - fixes incorrect .83p files produced by SPASM Z80 assembler

**gray/gray.asm** - TI-83 assembler program that displays a 4-level grayscale bitmap

## Tutorial
### Introduction
TI-83 is a classic graphing calculator sporting a monochromatic display with 96x64 pixels. Theoretically it is only possible to display 2 colors on such display - black and white. However we can simulate intermediate levels of gray by rapidly switching pixels between black and white. **Word of caution**: alternating pixels between black and white at frequency close to the LCD refresh rate for a prolonged period of time may degrade the LCD screen. However experimenting on a TI-83 emulator (e.g. Wabbitemu) should be safe :) You will need Python 2.7.x installed on your computer to run scripts, some image editing tool (e.g. IrfanView) and [SPASM](https://github.com/alberthdev/spasm-ng) - a Z80 assembler with TI calculators support.

### Converting a picture to a 4-level grayscale bitmap
Let's start with a picture that we want to convert to grayscale and display on a TI-83:

![Picture before conversion](/images/tiger.png)

It is best to choose a picture with light background. This will later give best results when decreasing the picture's color depth to 4 colors. The next thing we have to do is to resize it to 96x64. In order to keep proportions it will be usually necessary to crop the image first so it has 3:2 ratio. The result should look like this:

![Resized picture](/images/tiger2.png)

Now comes the hardest part - decreasing the color depth. It is often necessary to adjust the brigthness and contrast of the image before decreasing the color depth. Some experimentation is needed to achieve good results. Decreasing the color depth itself can be done in IrfanView (choose Image->Decrease Color Depth...):

![Decreasing the color depth](/images/decr.png)

Make sure to select 4 colors and check all the boxes. Now it should look like this:

![Tiger in 4-levels grayscale](/images/tiger3.png)

The problem is that we cannot control how IrfanView assigns indices to pallete entries. You can see the index of a particular color by clicking and holding a pixel with that color - the index will be displayed in the caption of IrfanView's window. For further processing we need the following mapping:

* white - index 0
* light gray - index 1
* dark gray - index 2
* black - index 3

Here is where **bmpremap.py** comes into rescue. Just run: `bmpremap.py tiger3.png -sm`. The `-s` option sorts indexes in a way that the lightest color gets index 0 and the darkest color gets the last index. The `-m` option changes colors in the palette in a way that they are evenly distributed from pure white to pure black. This makes the image appear similar to the way it will look on a TI-83 screen. The final result will look like this:

![Final tiger](/images/tiger4.png)

### Generating assembler data from a bitmap
This step is easy. Just run `bmp2z80.py tiger4.png -o tiger.asm`. This will generate an asm file with 2 bitmaps. The `dark` bitmap contains dark gray and black pixels and the `light` bitmap contains light gray and black pixels. The trick is to alternate between `dark` and `light` bitmaps in a way that `dark` bitmap is displayed for 2 consecutive frames and `light` bitmap is displayed for 1 frame. This will create 4-level grayscale.

### Assembling the grayscale displayer
Before assembling the grayscale displayer you may want to open it (`gray/gray.asm`) in a text editor and replace all the data in `dark` and `light` sections with data generated in the previous step. To assemble it run `spasm gray.asm gray.83p`. Unfortunately there is a bug in current version of SPASM (v0.5-beta.1) that causes the produced 83p file to be of TI-83+ format instead of TI-83. There is currently a pull request that fixes this bug (https://github.com/alberthdev/spasm-ng/pull/40) but as of 11 Mar 2017 it hasn't been merged yet. To fix this problem type `fix83p.py gray.83p grayFixed.83p`.

### Running the grayscale displayer in Wabbitemu
To run the grayscale displayer drag&drop `grayFixed.83p` to the Wabbitemu window. Next, enter the following command in the emulator:

![Wabbitemu1](/images/wabbit1.png)

The `Send(9` is a hidden feature of TI-83 which lacks the `Asm` command found on later models (TI-83+). It will run an assembly program. This is the final result:

![Wabbitemu2](/images/wabbit2.png)

You can adjust frequency by modifing delay between frames using up/down arrows for coarse adjustments and left/right arrows for fine adjustments. It is also possible to adjust LCD parameters in Wabbitemu options.
