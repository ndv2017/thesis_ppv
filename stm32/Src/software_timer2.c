/*
 * software_timer2.c
 *
 *      Author: Viet Nguyen Duc
 */


#include "software_timer2.h"


uint8_t timer2_flags[TIMER2_NUMBER];
static uint16_t timer2_counters[TIMER2_NUMBER];

// 1 duration == 1ms
void setTimer2(uint16_t duration, uint8_t index)
{
	if (index >= 0 && index < TIMER2_NUMBER)
	{
		timer2_counters[index] = duration;
		timer2_flags[index] = 0;
	}
}

void timer2Run(void)
{
	for (uint8_t i = 0; i < TIMER2_NUMBER; i++)
	{
		if (timer2_counters[i] > 0) {
		    timer2_counters[i]--;
		    if (timer2_counters[i] == 0) timer2_flags[i] = 1;
		}
	}
}
