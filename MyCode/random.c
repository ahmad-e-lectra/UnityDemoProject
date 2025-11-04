
#include "random.h"
#include "pin_map.h"

void random_blink(void)
{
    GPIO_writePin(GPIO_47_GPIO47, 1);
}   

//Function Implemented
void LedTwitch_off(uint32_t pin)
{
    GPIO_writePin(pin, 0);
    SysCtl_delay(1000000);

}

void LedTwitch_on(uint32_t pin)
{
    GPIO_writePin(pin, 1);
    SysCtl_delay(1000000);

}

void LedTwitch_start(void){}
void LedTwitch_stop(void){}
