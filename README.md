# directional_minesweeper
a harder directional version of minesweeper

Install:

Put the .pde files in a folder called directional_minesweeper and run directional_minesweeper.pde with processing 3.x.x


Rules:

Each tile has 4 color coded trapezoidals and a number

The number on the tile is the sum of the number of mines times the multiplier in each of the 3 tile reigons around the tile

The regions consist of the tile sharing an edge with the trapezoid and the 2 tiles sharing a corner with the trapezoid

(Therefore the 4 regions cover the same 8 tiles as regular minesweeper AND each corner tile is part of 2 regions)

The multipliers are 

	0 green
  
	1 red
  
	2 blue
  

Diagram:

0 1 2

3 4 5

6 7 8


The regions around the tile 4 are

	upwards region: tile 0, tile 1, tile 2
  
	rightwards region: tile 2, tile 5, tile 8
  
	downwards region: tile 6, tile 7, tile 8
  
	leftwards region: tile 0, tile 3, tile 6
  



Controls:

Left click and drag the sliders to set the

	number of mine
  
	board width
  
	board height
  
Left click tiles to expose them

Right click tiles to mark/unmark them as mines (marked tiles cant be exposed)

Press any key to reset at eh end of the game

Press esc to go back to the menu


![sweeper](https://user-images.githubusercontent.com/34765546/211196179-cee0c168-ca02-47cd-ab70-63b0c8d59834.png)
![sweeper2](https://user-images.githubusercontent.com/34765546/211196180-086ebff3-087e-4270-91f6-5431d761f41b.png)
