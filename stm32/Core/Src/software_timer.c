/*
 * sfw_timer.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "software_timer.h"


uint16_t timer1_counter = 0;
uint8_t timer1_flag = 0;


void setTimer1(uint16_t duration)
{
	timer1_counter = duration;
	timer1_flag = 0;
}

void timerRun(void)
{
	if (--timer1_counter <= 0)	timer1_flag = 1;
}
