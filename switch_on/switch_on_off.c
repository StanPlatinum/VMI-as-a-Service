#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>

#include "switch_on_off.h"

#define DURATION 100

static int init_switch_on(void)
{
	hypercall1intercept_rdtsc(__HYPERVISOR_intercept_rdtsc, 1);
	printk("Switch on\n");
	return 0;
}

static void exit_switch_off(void)
{
	hypercall0disable_intercept_rdtsc(__HYPERVISOR_disable_intercept_rdtsc);
	printk("Switch off\n");
}

module_init(init_switch_on);
module_exit(exit_switch_off);
MODULE_LICENSE("GPL");
