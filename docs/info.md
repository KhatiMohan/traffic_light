<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The project implements a traffic light controller that operates in a sequential pattern, allowing traffic to flow in all four directions (North, East, South, and West). The controller is synchronized with a counter that generates 1-second and 5-second time pulses to control the transitions between different traffic states.

## How to test

Assert RESET_N low (ui[0] = 0) to initialize, then set high (ui[0] = 1) to start.

Observe uo_out to verify traffic light transitions every 5 seconds for green and 1 second for yellow

## External hardware

LEds
