/*
 * sfw_timer.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_SFW_TIMER_H_
#define INC_SFW_TIMER_H_

#include "main.h"

extern uint8_t timer1_flag;

void setTimer1(uint16_t duration);
void timerRun(void);

#endif /* INC_SFW_TIMER_H_ */
