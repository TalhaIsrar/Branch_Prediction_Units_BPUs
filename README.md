This repo explores different branch prediction unit implementations
Generally there are some inputs from the if stage (pc to do prediction for) and some outputs for predicted pc, valid and taken/not taken
From the stage where you have your predictions verified after ALU (Jump/Branch targets calculated) There are some more connections