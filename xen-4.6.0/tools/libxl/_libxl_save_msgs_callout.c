/* AUTOGENERATED by libxl_save_msgs_gen.pl DO NOT EDIT */

#include "libxl_osdeps.h"

#include <assert.h>
#include <string.h>
#include <stdint.h>
#include <limits.h>

#include "libxl_internal.h"

static int bytes_get(const unsigned char **msg,
		     const unsigned char *const endmsg,
		     void *result, int rlen)
{
    if (endmsg - *msg < rlen) return 0;
    memcpy(result,*msg,rlen);
    *msg += rlen;
    return 1;
}

static int int_get(const unsigned char **msg,
                        const unsigned char *const endmsg,
                        int *result)
{
    return bytes_get(msg, endmsg, result, sizeof(*result));
}

static int uint16_t_get(const unsigned char **msg,
                        const unsigned char *const endmsg,
                        uint16_t *result)
{
    return bytes_get(msg, endmsg, result, sizeof(*result));
}

static int uint32_t_get(const unsigned char **msg,
                        const unsigned char *const endmsg,
                        uint32_t *result)
{
    return bytes_get(msg, endmsg, result, sizeof(*result));
}

static int unsigned_get(const unsigned char **msg,
                        const unsigned char *const endmsg,
                        unsigned *result)
{
    return bytes_get(msg, endmsg, result, sizeof(*result));
}

static int unsigned_long_get(const unsigned char **msg,
                        const unsigned char *const endmsg,
                        unsigned long *result)
{
    return bytes_get(msg, endmsg, result, sizeof(*result));
}

static int BLOCK_get(const unsigned char **msg,
                      const unsigned char *const endmsg,
                      const uint8_t **result, uint32_t *result_size)
{
    if (!uint32_t_get(msg,endmsg,result_size)) return 0;
    if (endmsg - *msg < *result_size) return 0;
    *result = (const void*)*msg;
    *msg += *result_size;
    return 1;
}

static int STRING_get(const unsigned char **msg,
                      const unsigned char *const endmsg,
                      const char **result)
{
    const uint8_t *data;
    uint32_t datalen;
    if (!BLOCK_get(msg,endmsg,&data,&datalen)) return 0;
    if (datalen == 0) return 0;
    if (data[datalen-1] != '\0') return 0;
    *result = (const void*)data;
    return 1;
}

unsigned libxl__srm_callout_enumcallbacks_save(const libxl__srm_save_autogen_callbacks *cbs)
{
    unsigned cbflags = 0;
    if (cbs->suspend) cbflags |= (1u<<3);
    if (cbs->postcopy) cbflags |= (1u<<4);
    if (cbs->checkpoint) cbflags |= (1u<<5);
    if (cbs->switch_qemu_logdirty) cbflags |= (1u<<6);
    return cbflags;
}

int libxl__srm_callout_received_save(const unsigned char *msg, uint32_t len, void *user)
{
    const unsigned char *const endmsg = msg + len;
    uint16_t mtype;
    if (!uint16_t_get(&msg,endmsg,&mtype)) return 0;
    switch (mtype) {

    case 1: { /* log */
        uint32_t level;
        uint32_t errnoval;
        const char *context;
        const char *formatted;
        if (!uint32_t_get(&msg,endmsg,&level)) return 0;
        if (!uint32_t_get(&msg,endmsg,&errnoval)) return 0;
        if (!STRING_get(&msg,endmsg,&context)) return 0;
        if (!STRING_get(&msg,endmsg,&formatted)) return 0;
        if (msg != endmsg) return 0;
        libxl__srm_callout_callback_log(level, errnoval, context, formatted, user);
        return 1;
    }

    case 2: { /* progress */
        const char *context;
        const char *doing_what;
        unsigned long done;
        unsigned long total;
        if (!STRING_get(&msg,endmsg,&context)) return 0;
        if (!STRING_get(&msg,endmsg,&doing_what)) return 0;
        if (!unsigned_long_get(&msg,endmsg,&done)) return 0;
        if (!unsigned_long_get(&msg,endmsg,&total)) return 0;
        if (msg != endmsg) return 0;
        libxl__srm_callout_callback_progress(context, doing_what, done, total, user);
        return 1;
    }

    case 3: { /* suspend */
        if (msg != endmsg) return 0;
        const libxl__srm_save_autogen_callbacks *const cbs =
            libxl__srm_callout_get_callbacks_save(user);
        cbs->suspend(user);
        return 1;
    }

    case 4: { /* postcopy */
        if (msg != endmsg) return 0;
        const libxl__srm_save_autogen_callbacks *const cbs =
            libxl__srm_callout_get_callbacks_save(user);
        cbs->postcopy(user);
        return 1;
    }

    case 5: { /* checkpoint */
        if (msg != endmsg) return 0;
        const libxl__srm_save_autogen_callbacks *const cbs =
            libxl__srm_callout_get_callbacks_save(user);
        cbs->checkpoint(user);
        return 1;
    }

    case 6: { /* switch_qemu_logdirty */
        int domid;
        unsigned enable;
        if (!int_get(&msg,endmsg,&domid)) return 0;
        if (!unsigned_get(&msg,endmsg,&enable)) return 0;
        if (msg != endmsg) return 0;
        const libxl__srm_save_autogen_callbacks *const cbs =
            libxl__srm_callout_get_callbacks_save(user);
        cbs->switch_qemu_logdirty(domid, enable, user);
        return 1;
    }

    case 8: { /* complete */
        int r;
        int retval;
        int errnoval;
        if (!int_get(&msg,endmsg,&retval)) return 0;
        if (!int_get(&msg,endmsg,&errnoval)) return 0;
        if (msg != endmsg) return 0;
        r = libxl__srm_callout_callback_complete(retval, errnoval, user);
        libxl__srm_callout_sendreply(r, user);
        return 1;
    }

    default:
        return 0;
    }}

unsigned libxl__srm_callout_enumcallbacks_restore(const libxl__srm_restore_autogen_callbacks *cbs)
{
    unsigned cbflags = 0;
    if (cbs->checkpoint) cbflags |= (1u<<5);
    return cbflags;
}

int libxl__srm_callout_received_restore(const unsigned char *msg, uint32_t len, void *user)
{
    const unsigned char *const endmsg = msg + len;
    uint16_t mtype;
    if (!uint16_t_get(&msg,endmsg,&mtype)) return 0;
    switch (mtype) {

    case 1: { /* log */
        uint32_t level;
        uint32_t errnoval;
        const char *context;
        const char *formatted;
        if (!uint32_t_get(&msg,endmsg,&level)) return 0;
        if (!uint32_t_get(&msg,endmsg,&errnoval)) return 0;
        if (!STRING_get(&msg,endmsg,&context)) return 0;
        if (!STRING_get(&msg,endmsg,&formatted)) return 0;
        if (msg != endmsg) return 0;
        libxl__srm_callout_callback_log(level, errnoval, context, formatted, user);
        return 1;
    }

    case 2: { /* progress */
        const char *context;
        const char *doing_what;
        unsigned long done;
        unsigned long total;
        if (!STRING_get(&msg,endmsg,&context)) return 0;
        if (!STRING_get(&msg,endmsg,&doing_what)) return 0;
        if (!unsigned_long_get(&msg,endmsg,&done)) return 0;
        if (!unsigned_long_get(&msg,endmsg,&total)) return 0;
        if (msg != endmsg) return 0;
        libxl__srm_callout_callback_progress(context, doing_what, done, total, user);
        return 1;
    }

    case 5: { /* checkpoint */
        if (msg != endmsg) return 0;
        const libxl__srm_restore_autogen_callbacks *const cbs =
            libxl__srm_callout_get_callbacks_restore(user);
        cbs->checkpoint(user);
        return 1;
    }

    case 7: { /* restore_results */
        unsigned long store_mfn;
        unsigned long console_mfn;
        if (!unsigned_long_get(&msg,endmsg,&store_mfn)) return 0;
        if (!unsigned_long_get(&msg,endmsg,&console_mfn)) return 0;
        if (msg != endmsg) return 0;
        libxl__srm_callout_callback_restore_results(store_mfn, console_mfn, user);
        return 1;
    }

    case 8: { /* complete */
        int r;
        int retval;
        int errnoval;
        if (!int_get(&msg,endmsg,&retval)) return 0;
        if (!int_get(&msg,endmsg,&errnoval)) return 0;
        if (msg != endmsg) return 0;
        r = libxl__srm_callout_callback_complete(retval, errnoval, user);
        libxl__srm_callout_sendreply(r, user);
        return 1;
    }

    default:
        return 0;
    }}

