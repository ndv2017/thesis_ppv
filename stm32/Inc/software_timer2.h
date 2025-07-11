/*
 * software_timer2.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef SRC_SOFTWARE_TIMER2_H_
#define SRC_SOFTWARE_TIMER2_H_

#include "main.h"

#define TIMER2_NUMBER 8		//timer num 3 4 5 6 for DC's parameters
// timer num 7 for torque

extern uint8_t timer2_flags[TIMER2_NUMBER];

void setTimer2(uint16_t duration, uint8_t index);
void timer2Run(void);

#endif /* SRC_SOFTWARE_TIMER2_H_ */
