/*******************************************************************************
Copyright(c) 2000 - 2002 Analog Devices. All Rights Reserved.
Developed by Joint Development Software Application Team, IPDC, Bangalore, India
for Blackfin DSPs  ( Micro Signal Architecture 1.0 specification).

By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************
File name   : t_RBGtoYCbCr.C
Description : This file contains test cases to validate function RGBtoYCbCr().
                    
                Test case 1   :  Input is 0(low) and 255(high).
                Test case 2&3 : general test cases for validation 
*******************************************************************************/
#include <stdio.h>
#include "color_cnvr.h"

int error_flag=0;
void (*f1)();
int cycle_count[10];

void _RGBtoYCbCr();

main(void)
{
    
    int i, s, error;

    f1 = _RGBtoYCbCr;

//Test Case 1

    s = 5;

    cycle_count[0] = Compute_Cycle_Count(RGB_YCIN1,ycr,s);
                                //This function inturn calls RGBtoYCbCr()

    for(i = 0; i<s*3; i++)
    {
        error = ycr[i]-RGB_YCOUT1[i];
    
        if(abs(error) > MAX_PERMISSIBLE_ERROR)
        {
            error_flag = error_flag | 1;
        }
    }

//Test 2:   Random input test
    
    s = 50;
    
    cycle_count[1] = Compute_Cycle_Count(RGB_YCIN2, ycr,s);
                                //This function inturn calls RGBtoYCbCr()
  
    for(i = 0; i<s*3; i++)
    {
        error = ycr[i] - RGB_YCOUT2[i];
    
        if(abs(error) > MAX_PERMISSIBLE_ERROR)
        {
            error_flag = error_flag | 2;
        }
    }

//Test case : 3

     s = 50;
    
    cycle_count[2] = Compute_Cycle_Count(RGB_YCIN3, ycr,s);
                                //This function inturn calls RGBtoYCbCr()

    for(i = 0; i<s*3; i++)
    {
        error = ycr[i] - RGB_YCOUT3[i];
      
        if(abs(error) > MAX_PERMISSIBLE_ERROR)
        {
            error_flag = error_flag | 4;
        }
    }
    #ifdef PRINTF_SUPPORT
        if(error_flag & 1)
            printf("Test Case 1 failed\n");
        else
            printf("Test Case 1 passed\n");
        if(error_flag & 2)
            printf("Test Case 2 failed\n");
        else
            printf("Test Case 2 passed\n");
        if(error_flag & 4)
            printf("Test Case 3 failed\n");
        else
            printf("Test Case 3 passed\n");
    #endif
    
    printf("cycle_count[0]=%d,cycle_count[1]=%d,cycle_count[2]=%d\n",cycle_count[0],cycle_count[1],cycle_count[2]);
    
}

