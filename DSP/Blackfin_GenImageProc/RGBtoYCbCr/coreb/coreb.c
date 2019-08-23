/*******************************************************************************
Copyright(c) 2005 Analog Devices. All Rights Reserved.
Developed for Blackfin DSPs  ( Micro Signal Architecture).

By using this module you agree to the terms of the Analog Devices License
Agreement for DSP Software. 
********************************************************************************
File Name       : CodeB.c

Date Modified   : 01/18/05

Software        : VisualDSP++ 4.0

Hardware        : Tested on ADSP-BF561 EZ-KIT LITE REV. 1.1		

Description     : Disables Core B.
*******************************************************************************/

#include <cDefBF561.h>
#include <sysreg.h>
#include <ccblkfn.h>

void main()
{
	while(1)
	{
		idle();
	}
		
}
