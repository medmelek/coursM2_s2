/*******************************************************************************
Copyright(c) 2000 - 2002 Analog Devices. All Rights Reserved.
Developed by Joint Development Software Application Team, IPDC, Bangalore, India
for Blackfin DSPs  ( Micro Signal Architecture 1.0 specification).

By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************
Module Name     : YCbCrtoRGB.asm
Label Name      : __YCbCrtoRGB
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

Description     : In this function the range of Y, Cb and Cr is 0 to 255 and the
                  output range of R, G and B is also 0 to 255.

                  The formula implemented is as below:

                     R = Y + 1.402 (Cr - 128)     = Y +(Cr-128) + 0.402(Cr-128)
                     G = Y - 0.34414 (Cb - 128) - 0.71414 (Cr - 128) 
                     B = Y + 1.772 (Cb - 128)     = Y + (Cb-128) + 0.772(Cb-128)

Prototype       : void YCbCrtoRGB(unsigned char input[], unsigned char out[], 
                                  int N);

                     input[] - Input YCbCr array 
                       out[] - Out put  array to store in RGB format
                           N - Number of inputs

Registers used  : A0, A1, R0-R7, I1, B1, L1, P0-P2, LC0.

Performance     :
                Code Size     : 164 bytes
                Cycle count   : 13*N + 31 cycles
                              : 96 Cycles (for N = 5)
*******************************************************************************/
.section    L1_code;
.global     __YCbCrtoRGB;
.align      8;
    
__YCbCrtoRGB:   [--SP] = (R7:4);
                            // Pushing the Registers on stack. 
    SP += -8;               // SP modified to store coefficients
    I1 = SP;                //
    B1 = I1;                // Initialize base register B1 and I1  for circular 
                            // buffer
    L1 = 8;                 // Initialize length for circular buffer
    
    R6.L = 0x3374;
    R6.H = 0xA498;          // Coefficients 0.402 and -0.34414  are stored in R6
    R7.L = 0xD3F4;
    P0 = R0;                // Address of input YCbCr array    
    R7.H = 0x62D0;          // Coefficients -0.71414 and 0.772  are stored in R7
    
    P2 = R1;                // Address of output array to store RGB values
    P1 = R2;                // Number of inputs N
    
    R4.L = 0xFF;                       
    R4 = PACK(R4.L,R4.L) || R0 = B[P0++](Z) || [I1++] = R6;
                            // Initialize R4.H to 255 and fetch Y value 
                            // and store coefficients 0.402 and -0,34414 to
                            // temp. location
    R5 = R7-R7(NS) || R1 = B[P0++] (Z)|| [I1++] = R7;
                            // Clear R5 and fetch Cb  value and store 
                            // coefficients 
                            // -0.71414 and 0,772 in temp. location
    R7 = 128;               // Initialize R7 to 128
    R1 = R1 - R7(NS) || R2 = B[P0++](Z);
                            // R1 = Cb-128  and fetch Cr value 
    R6.L = 0X7FFF;          // Initialize R6 to maximum positive value
    
    LSETUP(YCB_STRT, YCB_END) LC0 = P1;
YCB_STRT:
        R2 = R2 - R7;       // R2 = Cr-128
        A1 = R0.L * R6.L,   A0 = R0.L * R6.L || R3 = [I1++];
                            // Get Y value in A1 and A0  and fetch coefficients 
        A1 += R2.L * R3.H, A0 += R2.L * R3.L || R3 = [I1++];
                            // Multiply (Cr -128) value with coefficients 0.402 
                            // and -0.71414
        R2.L = (A0 += R2.L * R6.L);
                            // Add (Cr-128) value to A0 to get R value 
        R2.H = (A1 += R1.L * R3.L), A0 = R1.L * R3.H;
                            // multiply  (Cb-128) with  -0.34414 and add to A1, 
                            // A0= 0.772(Cb-128) 
        R2 = MAX(R2,R5)(V); // check if value is within 0 and 255
        R2 = MIN(R2,R4)(V); // R2.L contains R value and R2.H contains B value
        A0 += R0.L * R6.L || B[P2++] = R2;
                            // Add Y value to A0 and store R value 
        R2 = R2 >> 16 || R0 = B[P0++](Z);
                            // Leftshift to get B value  in lower half and fetch
                            // next Y data 
        R3.L = (A0 += R1.L * R6.L) || B[P2++] = R2;
                            // Add (Cb-128) value to A0 and store B value 
        R3 = MAX(R3,R5)(V) || R1 = B[P0++](Z);
                            // Check if value is within the limit 0 to 255 and 
                            // fetch next Cb data 
        R3 = MIN(R3,R4)(V) || R2 = B[P0++](Z);
                            // fetch next Cr value 
YCB_END:
        R1 = R1 - R7(NS) || B[P2++] = R3;
                            // R1 = Cb-128 and store B data 
    
    SP += 8;                // Clear temp. location
    (R7:4) = [SP++];        // Pop up the saved registers.
    RTS; 
    NOP;                    //to avoid one stall if LINK or UNLINK happens to be
                            //the next instruction after RTS in the memory.
__YCbCrtoRGB.end:                            
