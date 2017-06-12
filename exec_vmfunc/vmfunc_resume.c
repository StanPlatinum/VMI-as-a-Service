#include <stdio.h>
#include <stdlib.h>

#define DURATION 100

unsigned long long rdtsc_value(void)
{
	unsigned long lo, hi;
	asm volatile (
		"lfence\n"
		"rdtsc"
		: "=a"(lo), "=d"(hi) );
	return (unsigned long long) ((hi << 32)|(lo));
}

int do_vmfunc(unsigned long func_number, unsigned long dest_index)
{
	asm volatile (
		"vmfunc"
		:
		: "a"(func_number), "c"(dest_index)
		: "memory"
	);
}

int main(void)
{
	do_vmfunc(0, 0);
	printf("vmfunc resume\n");
	return 0;
}
