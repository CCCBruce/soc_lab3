Configuration write

![image](https://github.com/CCCBruce/soc_lab3/assets/145880763/4934ad63-9e65-43b1-b30d-9a5f307fef83)

ap_reg[2] is ap_idle, ap_reg[1] is ap_done, ap_reg[0] is ap_start.

At the initial state, the system is in an idle state, and the ap signal is set to 100. When the wdata equals 1, it indicates that the testbench (tb) is sending the ap_start signal. At this point, the system transitions to the start state, and the ap signal becomes 010. When the Finite Impulse Response (FIR) operation begins, the system enters the busy state, resulting in the ap signal being set to 000.

ap_start , ap_done ( measure # of clock cycles from ap_start to ap_done

![image](https://github.com/CCCBruce/soc_lab3/assets/145880763/6bbeb5e5-eaae-4009-8fdd-70cbd50aaf8f)
![image](https://github.com/CCCBruce/soc_lab3/assets/145880763/838ef3e0-bef8-474b-9a60-94381cc8a208)

clock cycles = (73225-715)/10 = 7251

Xn stream in, and Yn stream out
