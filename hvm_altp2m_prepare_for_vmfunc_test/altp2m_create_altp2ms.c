#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/delay.h>

#include "altp2m_test.h"

MODULE_LICENSE("GPL");

xen_hvm_altp2m_op_t *arg;

static int init_altp2m_test(void)
{
	unsigned long long t1, t2;
	int i;

	arg = (xen_hvm_altp2m_op_t *) kmalloc(sizeof(xen_hvm_altp2m_op_t), GFP_KERNEL);
	if (arg == NULL)
	    return -1;
	
	t1 = rdtsc_value();

	arg->version = HVMOP_ALTP2M_INTERFACE_VERSION;
	arg->cmd = HVMOP_altp2m_set_domain_state;
	/* The following lines is important! */
	arg->pad1 = 0;
	arg->pad2 = 0;
	arg->domain = 1;
	arg->u.domain_state.state = 1;
	hypercall2hvm_op(__HYPERVISOR_hvm_op, HVMOP_altp2m, arg);
	ndelay(1);
	arg->cmd = HVMOP_altp2m_vcpu_enable_notify;
	arg->u.enable_notify.vcpu_id = 0;
	hypercall2hvm_op(__HYPERVISOR_hvm_op, HVMOP_altp2m, arg);
	ndelay(1);
	for (i = 0; i < 9; i++) {
	    arg->cmd = HVMOP_altp2m_create_p2m;
	    arg->u.view.view = -1;
	    hypercall2hvm_op(__HYPERVISOR_hvm_op, HVMOP_altp2m, arg);
	    ndelay(1);
	}

	t2 = rdtsc_value();
	
	printk("t1 = %llu, t2 = %llu\n", t1, t2); 
	if (t2 > t1)
	    printk("Total cost %llu cycles\n", t2 - t1);
	return 0;
}

static void exit_altp2m_test(void)
{
	kfree(arg);
	printk("Goodbye, altp2m_test!\n");
}

module_init(init_altp2m_test);
module_exit(exit_altp2m_test);
