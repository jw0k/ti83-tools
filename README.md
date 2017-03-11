# ti83-tools
Collection of programs useful for preparing a grayscale bitmap (with 4 levels of gray) and displaying in on a TI-83 calculator

## Contents
**bmpremap.py** - modifies indices in a BMP with a color table (palette)

**bmp2z80.py** - converts an indexed BMP with 4 levels of gray (white, light gray, dark gray and black) to Z80 assembler data

**fix83p.py** - fixes incorrect .83p files produced by **SPASM** Z80 assembler

**gray/gray.asm** - TI-83 assembler program that displays a 4-level grayscale bitmap

## Tutorial
### Introduction
TI-83 is a classic graphing calculator sporting a monochromatic display with 96x64 pixels. Theoretically it is only possible to display 2 colors on such display - black and white. However we can simulate intermediate levels of gray by rapidly switching pixels between black and white. **Word of caution**: alternating pixels between black and white with a frequency close to the LCD refresh rate for a prolonged period of time may degrade the LCD screen. However experimenting in a TI-83 emulator (e.g. **Wabbitemu**) should be safe :)
### Converting a picture to a 4-level grayscale bitmap
Let's start with a picture that we want to convert to grayscale and display on a TI-83:

![Picture before conversion](/tiger/tiger.png)

It is best to choose a picture with light background. This will later give best results when decreasing the picture's color depth to 4 colors. The next thing we have to do is to resize it to 96x64. In order to keep proportions it will be usually necessarry to crop the image first so it has 3:2 ratio. The result should look like this:

![Resized picture](/tiger/tiger2.png)

Now comes the hardest part - decreasing the color depth. It is often necessary to adjust the brigthness and contrast of the image before decreasing the color depth. Some experimentation is needed to achieve good results. Decreasing the color depth itself can be done in IrfanView which has Floyd-Steinberg dithering algorithm:

![Decreasing the color depth](/tiger/decr.png)

Make sure to select 4 colors and check all the boxes. Now it should look like this:

![Tiger in 4-levels grayscale](/tiger/tiger3.png)

The problem is that we cannot control how IrfanView assigns indices to pallete entries. You can see the index of a particular color by clicking and holding a pixel with that color - the index will be displayed in the caption of IrfanView's window. For further processing we need the following mapping:

* white - index 0
* light gray - index 1
* dark gray - index 2
* black - index 3

Here is where **bmpremap.py** comes into rescue. Just run: `bmpremap.py tiger3.png -sm`. The `-s` option sorts indexes in a way that the lightest color gets index 0 and the darkest color gets the last index. The `-m` option changes colors in the palette in a way that they are evenly distributed from pure white to pure black. This makes the image appear similar to the way it will look on a TI-83 screen. The final result will look like this:

![Final tiger](/tiger/tiger4.png)

### Generating assembler data from a bitmap
This step is easy. Just run `bmp2z80.py tiger4.png -o tiger.asm`. This will generate an asm file with 2 bitmaps. The `dark` bitmap contains dark gray and black pixels and the `light` bitmap contains light gray and black pixels. The trick is to alternate between `dark` and `light` bitmaps in a way that `dark` bitmap is displayed for 2 consecutive frames and `light` bitmap is displayed for 1 frame. This will create 4-level grayscale.

### Assembling the grayscale displayer
Before assembling the grayscale displayer you may want to open it (`gray/gray.asm`) in a text editor and replace all the data in `dark` and `light` sections with data generated in the previous step. To assemble it you need **[SPASM](https://github.com/alberthdev/spasm-ng)** assembler. Run `spasm gray.asm gray.83p`. Unfortunately there is a bug in current version of SPASM (v0.5-beta.1) that causes the produced 83p file to be of TI-83+ format instead of TI-83. There is currently a pull request that fixes this bug (https://github.com/alberthdev/spasm-ng/pull/40) but as of 11 Mar 2017 it hasn't been merged yet. To fix this problem type `fix83p.py gray.83p grayFixed.83p`.

### Running the grayscale displayer in Wabbitemu
