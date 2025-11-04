/*
 * gpio.h
 *
 *  Created on: Oct 29, 2025
 *      Author: User
 */

#ifndef HARDWARETESTPRO_TEST_SUPPORT_GPIO_H_
#define HARDWARETESTPRO_TEST_SUPPORT_GPIO_H_


#include "stdint.h"

typedef enum
{
    GPIO_DIR_MODE_IN = 0,
    GPIO_DIR_MODE_OUT
} GPIO_Direction;

#define DEVICE_GPIO_PIN_LED1        31U             // GPIO number for LED1


void SysCtl_delay(uint32_t count);
void GPIO_setDirectionMode(uint32_t pin, GPIO_Direction pinIO);
void GPIO_writePin(uint32_t pin, uint32_t val);



#endif /* HARDWARETESTPRO_TEST_SUPPORT_GPIO_H_ */
