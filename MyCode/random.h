
#ifndef MY_H
#define MY_H

#include "gpio.h"
#include "device.h"

void random_blink(void);
void LedTwitch_off(uint32_t pin);
void LedTwitch_on(uint32_t pin);

void LedTwitch_start(void);
void LedTwitch_stop(void);

#endif
