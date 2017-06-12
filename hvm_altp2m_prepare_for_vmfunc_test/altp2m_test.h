#define __HYPERVISOR_hvm_op 	34
#define HVMOP_altp2m 		25
#define HVMOP_ALTP2M_INTERFACE_VERSION	0x00000001
#define HVMOP_altp2m_get_domain_state	1
#define HVMOP_altp2m_set_domain_state	2
#define HVMOP_altp2m_vcpu_enable_notify	3
#define HVMOP_altp2m_create_p2m		4
#define HVMOP_altp2m_destroy_p2m	5
#define HVMOP_altp2m_switch_p2m		6
#define HVMOP_altp2m_set_mem_access	7
#define HVMOP_altp2m_change_gfn		8

typedef uint16_t domid_t;

struct xen_hvm_altp2m_domain_state {
    /* IN or OUT variable on/off */
    uint8_t state;
};

struct xen_hvm_altp2m_vcpu_enable_notify {
    uint32_t vcpu_id;
    uint32_t pad;
    /* #VE info area gfn */
    uint64_t gfn;
};

struct xen_hvm_altp2m_view {
    /* IN/OUT variable */
    uint16_t view;
    /* Create view only: default access type */
    uint16_t hvmmen_default_access; /* xenmem_access_t */
};

struct xen_hvm_altp2m_set_mem_access {
    /* view */
    uint16_t view;
    /* memory type */
    uint16_t hvmmem_access; /* xenmem_access_t */
    uint32_t pad;
    /* gfn */
    uint64_t gfn;
};

struct xen_hvm_altp2m_change_gfn {
    /* view */
    uint16_t view;
    uint16_t pad1;
    uint32_t pad2;
    /* old gfn */
    uint64_t old_gfn;
    /* new gfn, INVALID_GFN(~0UL) means revert */
    uint64_t new_gfn;
};

struct xen_hvm_altp2m_op {
    uint32_t version;
    uint32_t cmd;
    domid_t domain;
    uint16_t pad1;
    uint32_t pad2;
    union {
	struct xen_hvm_altp2m_domain_state		domain_state;
	struct xen_hvm_altp2m_vcpu_enable_notify	enable_notify;
	struct xen_hvm_altp2m_view			view;
	struct xen_hvm_altp2m_set_mem_access		set_mem_access;
	struct xen_hvm_altp2m_change_gfn		change_gfn;
	uint8_t pad[64];
    } u;
};
typedef struct xen_hvm_altp2m_op xen_hvm_altp2m_op_t;

unsigned long long rdtsc_value(void)
{
	unsigned long lo, hi;
	asm volatile ( "rdtsc"
			: "=a"(lo), "=d"(hi) );
	return (unsigned long long) ((hi << 32)|(lo));
}

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

