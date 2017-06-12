#define __HYPERVISOR_intercept_rdtsc		43
#define __HYPERVISOR_disable_intercept_rdtsc	44

/*
 * usage: case HVMOP_altp2m:
 *		rc = do_altp2m_op(arg);
 */
void hypercall2hvm_op(int callno, unsigned long  op, void * arg)
{
	asm volatile( "vmcall"
			:
			:"a"(callno), "D"(op), "S"(arg)
		);
}

/*
 * usage: case HVMOP_intercept_rdtsc:
 *		rc = do_intercept_rdtsc(arg);
 */
void hypercall1intercept_rdtsc(int callno, int scale)
{
	asm volatile( "vmcall"
			:
			: "a"(callno), "D"(scale)
		);
}

void hypercall0disable_intercept_rdtsc(int callno)
{
	asm volatile( "vmcall"
			:
			: "a"(callno)
		);
}

unsigned long long rdtsc_value(void)
{
	unsigned long lo, hi;
	asm volatile ( "rdtsc"
			: "=a"(lo), "=d"(hi) );
	return (unsigned long long) ((hi << 32)|(lo));
}
