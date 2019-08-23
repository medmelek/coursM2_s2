/*******************************************************************************
Copyright(c) 2000 - 2002 Analog Devices. All Rights Reserved.
Developed by Joint Development Software Application Team, IPDC, Bangalore, India
for Blackfin DSPs  ( Micro Signal Architecture 1.0 specification).

By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************
File name   : t_YCbCrtoRGB.c
Description : This file contains  test cases for validating function 
              YCbCrtoRGB().

                Test case 1  :   test for black and white color
                Test case 2&3:   general validation routine
******************************************************************************/
#include <stdio.h>
#include "color_cnvr.h"

int error_flag = 0;
void (*f1)();
int cycle_count[10];

void _YCbCrtoRGB();

main(void)
{
    
    int i, s, error ;

    f1 = _YCbCrtoRGB;       

//Test case 1 :

    s = 5;

    cycle_count[0] = Compute_Cycle_Count(RGB_YCOUT1, rgb,s);
                                    //This function inturn calls YCbCrtoRGB()

    for(i = 0; i<s*3; i++)
    {
        error = rgb[i] - RGB_YCIN1[i];
      
        if(abs(error) > MAX_PERMISSIBLE_ERROR)
        {
            error_flag = error_flag | 1;
        }
    }

//Test case 2

    s = 50;

    cycle_count[1] = Compute_Cycle_Count(RGB_YCOUT2, rgb,s);
                                   //This function inturn calls YCbCrtoRGB()

    for(i = 0; i<s*3; i++)
    {
        error = rgb[i] - RGB_YCIN2[i];
      
        if(abs(error) > MAX_PERMISSIBLE_ERROR)
        {
            error_flag = error_flag | 2;
        }
    }

//Test case 3

    s = 50;

    cycle_count[2] = Compute_Cycle_Count(RGB_YCOUT3, rgb,s);
                            //This function inturn calls YCbCrtoRGB()

    for(i = 0; i<s*3; i++)
    {
        error = rgb[i] - RGB_YCIN3[i];
      
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

