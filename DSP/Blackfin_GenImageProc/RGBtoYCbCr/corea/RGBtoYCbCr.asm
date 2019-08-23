/*******************************************************************************
Copyright(c) 2000 - 2002 Analog Devices. All Rights Reserved.
Developed by Joint Development Software Application Team, IPDC, Bangalore, India
for Blackfin DSPs  ( Micro Signal Architecture 1.0 specification).

By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************
Module Name     : RGBtoYCbCr.asm
Label Name      : __RGBtoYCbCr
Version         :   1.3
Change History  :

                Version     Date          Author        Comments
                1.3         11/18/2002    Swarnalatha   Tested with VDSP++ 3.0
                                                        compiler 6.2.2 on 
                                                        ADSP-21535 Rev.0.2
                1.2         11/13/2002    Swarnalatha   Tested with VDSP++ 3.0
                                                        on ADSP-21535 Rev. 0.2
                1.1         02/28/2002    Raghavendra   Modified to match
                                                        silicon cycle count
                1.0         05/16/2001    Raghavendra   Original 

Description     : In this function the range of R, G and B is 0 to 255 and the 
                  output range of Y, Cb and Cr is also 0 to 255.
                  The formula implemented is as below:

                    Y  = 0.299R  +  0.587G  +  0.114B          
                    Cb = -0.169R -  0.331G  +  0.500B + 128    
                    Cr = 0.500R  -  0.419G  -  0.081B + 128    

                  128 is added to Cb and Cr to get the output in the range 0 to 
                  255.

Assumption      : The input is gamma corrected values of RGB are present in RGB
                  order and result will be stored in YCbCr order.  

Prototype       : void RGBtoYCbCr(unsigned char input[], unsigned char out[], 
                                  int N);

                               input[] - Input RGB array 
                               out[]   - Out put  array to store in YCbCr format
                               N       - Number of inputs

Registers Used  : A0, A1, R0-R3, R5-R7, I1, B1, M0, L1, P0-P2, LC0.

Performance     :
                Code Size    : 172 bytes
                Cycle count  : 8 * N + 41 Cycles
                             : 81 Cycles (for N = 5)
*******************************************************************************/

.section               L1_code;
.global                 __RGBtoYCbCr;
.align                  8;
    
__RGBtoYCbCr:   [--SP] = (R7:5);
                            // Push R7-5 the Registers on stack. 
    SP += -20;              // Decrement stack by 20 bytes to store coefficients
    I1 = SP;                // Initialize I1  and B1 registers for circular 
                            // buffer
    B1 = SP;                    
    M0 = 12;                // To fetch the proper coefficients
    P0 = SP;                // Initialize to store the coefficients
    R3.L = 0XEA5F;
    R3.H = 0X4000;
    R5.L = 0XD5A2;
    R5.H = 0XCA5F;
    R6.L = 0X4000;          //9 coefficients are initialized and stored in stack
    R6.H = 0XF5A2;
    R7.L = 0X2645;
    R7.H = 0X4B22; 
    [P0++] = R3;
    [P0++] = R5;
    [P0++] = R6;
    [P0++] = R7;
    R3.L = 0X0E97;
    W[P0++] = R3;
    P2 =  R1;               // Address of output array
    P1 = R2;                // number of inputs
    P0 = R0;                // Address of input RGB array
    
    R6 = 128;               // Initialize 128 to increment Cb and Cr component
    L1 = 18;                // Initialize for Circular buffer to fetch 
                            // coefficient
    R7 = 0x7FFF;            // Initialize r7 to 1.0
    I1 += M0;               // modified the Index reg. I1 to fetch 0.299 and 
                            // 0.587
    R0  = B[P0++] (Z)|| R3 = [I1++];
                            // Fetch R value and coefficients 0.299 and 0.587 
    A0 = R0.L * R3.L || R1 = B[P0++] (Z)|| R3.L = W[I1++];
                            //multiply R value with 0.299,fetch G  and 
                            // coefficient 0.114 
    A0 += R1.L * R3.H || R2 = B[P0++](Z);
                            // multiply G with 0.587 and fetch B value 

    LSETUP(L1_STRT, L1_END)LC0 = P1;
L1_STRT:
        R5.L = (A0 += R2.L * R3.L);
                            // multiply B with 0.114 and  R5.L contains Y value 
        A1 = R7.L * R6.L,A0 = R7.L * R6.L || B[P2++] = R5 || R3 = [I1++];
                            // get 128 in A1,A0, store Y value and fetch 
                            // Coefficients -0.169 and 0.5 
        A1 += R0.L * R3.H, A0 += R0.L * R3.L || R0 = B[P0++](Z) || R3 = [I1++];
                            // Multiply R with -0.169 and 0.5 
                            // Fetch next R value and coefficients -0.331 and
                            // -0.419
        A1 += R1.L * R3.H, A0 += R1.L * R3.L || R1 = B[P0++](Z) || R3 = [I1++];
                            // Multiply G value with -0.331 and -0.419 and 
                            // Accumulate the result 
                            //fetch next G value and coefficients 0.5 and -0.081
        R5.H = (A1 += R2.L * R3.H), R5.L = (A0 += R2.L * R3.L ) 
        || R2 = B[P0++](Z) ||R3 = [I1++];
                            // Multiply B value with  0.5 and -0.081 
                            // R5.L contains the Cb and  R5.H contains Cr value
                            // fetch next B value and coefficients 0.299 and 
                            // 0.587
        A0 = R0.L * R3.L || B[P2++] = R5 || R3.L = W[I1++];
                            // multiply R  with 0.299, store Cb value and fetch 
                            // Coefficient 0.114 
        R5 = R5 >> 16;      // shift r5 to get Cr value in lower half of the 
                            // register
L1_END: A0+=R1.L * R3.H || B[P2++] = R5;
                            // multiply G value with 0.587 and store Cr value 
    SP += 20;               // Clear temporary location in stack
    (R7:5)  =  [SP++];      // Pop up the saved registers from stack
    RTS; 
    NOP;                    //to avoid one stall if LINK or UNLINK happens to be
                            //the next instruction after RTS in the memory.
__RGBtoYCbCr.end:                             
