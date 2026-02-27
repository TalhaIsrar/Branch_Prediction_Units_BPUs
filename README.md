# Branch Prediction units (BPUs) exploration for CPUs

This repo explores different branch prediction unit implementations.

Generally there are some inputs from the if stage (pc to do prediction for) and some outputs for predicted pc, valid and taken/not taken.

From the stage where you have your predictions verified after ALU (Jump/Branch targets calculated) There are some more connections.

Each implementation has been verified as part of a [RISC-V Core](https://github.com/TalhaIsrar/RISCV-Optimized-Processor). To use each version nagivate to backups>final.

## 🧩 Versions

* [1 Bit Saturating BTB BPU](1_bit_saturating_btb/) – It uses a 1 bit counter for branch prediction. There are 2 states: Taken or Not Taken.
The BTB used is a 2-way set assosciative BTB with LRU replacement policy. The size is configurable by parameter N in top module.

* [2 Bit Saturating BTB BPU](2_bit_saturating_btb/) – It uses a 2 bit saturating counter for branch prediction. There are 4 states: Weak/Strong Taken and Weak/Strong Not Taken.
The BTB used is a 2-way set assosciative BTB with LRU replacement policy. The size is configurable by parameter N in top module.


* [Tage with BTB BPU](tage_with_btb/) – It has a baseline implementation of Tage with global history. It also has a direct mapped BTB to store the targets for addresses. 
There are some signals that need to pass through the pipeline stages from prediction stage and re-enter the top module in update stage. The number of tables, size of BTB, Bimodal Tables, Tage Tables, the history length of each table, tage size for each table can be modified using the parameters in top module.


* [Tage-SC with BTB BPU](tage_sc_with_btb/) – It has a baseline implementation of Tage with a statisctial corrector and with global history. It also has a direct mapped BTB to store the targets for addresses. 
There are some signals that need to pass through the pipeline stages from prediction stage and re-enter the top module in update stage. The number of tables, size of BTB, Bimodal Tables, Tage Tables, SC tables, the history length of each table, tage size, and SC threshold for each table can be modified using the parameters in top module.


## 📄 License

This project is released under the Apache License. See the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributions

Contributions, suggestions, and issue reports are welcome! Feel free to fork and open pull requests.

---

*Created by Talha Israr*  
