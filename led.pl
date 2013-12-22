#!/usr/bin/perl 
use strict;
use warnings;
use Device::BCM2835;

#Device::BCM2835::set_debug(1);
Device::BCM2835::init() or die "init die";
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_V2_GPIO_P1_16,&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP) ;

while(1)
{
    # Turn it on
    Device::BCM2835::gpio_write(&Device::BCM2835::RPI_V2_GPIO_P1_16, 1);
    Device::BCM2835::delay(500); # Milliseconds
    # Turn it off
	Device::BCM2835::gpio_write(&Device::BCM2835::RPI_V2_GPIO_P1_16, 0);
    Device::BCM2835::delay(500); # Milliseconds
}

