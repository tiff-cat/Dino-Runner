# Dino-Runner

We recreated the Chrome T-rex Runner game in Verilog. The game can be downloaded onto a DE1-SoC FPGA chip, and controlled by using the DE1-SoC's key inputs. The graphics are displayed through the board's VGA output. 

## Features

Our process can be broken into three milestones, in each one we implement a unique feature. 
#### Milestone 1

  In this phase, we implemented the animation on VGA of the dinosaur's running movements and the appearance of obstacles. To 
  generate obstacles of random height, we used a **linear feedback shift register**. To keep track of the score, we used the built-in CLOCK-50 and a rate divider to display on the HEX the length of time the player has stayed alive.
  
#### Milestone 2

  Our goal in phase 2 was to implement the logic behind the dinosaur jumping to key presses. To do this, we used a **finite state machine** to keep track of whether the dinosaur is currently in the air. 
  
#### Milestone 3

  In phase 3 we took care of **collision detection** between the dinosaur and the obstacles. For collision detection, we used a module which keeps track of the obstacle locations and dinosaur coordinates. A separate module checks at each CLOCK-50 posedge if the dinosaur has coordinates overlapping with an obstacle. If the dinosaur has not cleared the obstacle, the game ends and the animations are stopped. By pressing a reset button, the game is cleared and set to its initial state where and the player can restart. 
