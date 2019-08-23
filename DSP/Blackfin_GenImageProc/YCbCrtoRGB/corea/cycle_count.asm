/*******************************************************************************
Copyright(c) 2000 - 2002 Analog Devices. All Rights Reserved.
Developed by Joint Development Software Application Team, IPDC, Bangalore, India
for Blackfin DSPs  ( Micro Signal Architecture 1.0 specification).
    By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************/
.extern _f1;

//This function computes cycle count of the function pointed by f1.

.section L1_code;
.global _Compute_Cycle_Count;
.align 8;
_Compute_Cycle_Count:
        P0.L = _Ret_Add;
        P0.H = _Ret_Add;
        R3 = RETS;
        [P0] = R3;

        P0.L = _Save_R7;
        P0.H = _Save_R7;
        [P0] = R7;

        P0.L = _f1;
        P0.H = _f1;
        P0 = [P0];

        NOP;NOP;NOP;NOP;

        R7 = CYCLES;
        CALL (P0);
        R0 = CYCLES;
        NOP;
        R0 = R0 - R7;
        R0 += -5;

        P0.L = _Save_R7;
        P0.H = _Save_R7;
        R7 = [P0];
        
        P0.L = _Ret_Add;
        P0.H = _Ret_Add;
        R3 = [P0];
        RETS = R3;
        
        NOP;NOP;NOP;NOP;
        RTS;

_Compute_Cycle_Count.end:
        
                
.section data1;
.align 4;
        .var _Ret_Add;
        .var _Save_R7;
