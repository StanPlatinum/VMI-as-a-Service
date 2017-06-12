/* AUTOGENERATED by libxl_save_msgs_gen.pl DO NOT EDIT */

typedef struct libxl__srm_save_autogen_callbacks {
    void (*suspend)(void *user);
    void (*postcopy)(void *user);
    void (*checkpoint)(void *user);
    void (*switch_qemu_logdirty)(int domid, unsigned enable, void *user);
} libxl__srm_save_autogen_callbacks;

struct save_callbacks;
typedef struct libxl__srm_restore_autogen_callbacks {
    void (*checkpoint)(void *user);
} libxl__srm_restore_autogen_callbacks;

struct restore_callbacks;
void libxl__srm_callout_callback_checkpoint(void *user);
int libxl__srm_callout_callback_complete(int retval, int errnoval, void *user);
void libxl__srm_callout_callback_log(uint32_t level, uint32_t errnoval, const char *context, const char *formatted, void *user);
void libxl__srm_callout_callback_postcopy(void *user);
void libxl__srm_callout_callback_progress(const char *context, const char *doing_what, unsigned long done, unsigned long total, void *user);
void libxl__srm_callout_callback_restore_results(unsigned long store_mfn, unsigned long console_mfn, void *user);
void libxl__srm_callout_callback_suspend(void *user);
void libxl__srm_callout_callback_switch_qemu_logdirty(int domid, unsigned enable, void *user);
unsigned libxl__srm_callout_enumcallbacks_restore(const libxl__srm_restore_autogen_callbacks *cbs);
unsigned libxl__srm_callout_enumcallbacks_save(const libxl__srm_save_autogen_callbacks *cbs);
const libxl__srm_restore_autogen_callbacks * libxl__srm_callout_get_callbacks_restore(void *data);
const libxl__srm_save_autogen_callbacks * libxl__srm_callout_get_callbacks_save(void *data);
int libxl__srm_callout_received_restore(const unsigned char *msg, uint32_t len, void *user);
int libxl__srm_callout_received_save(const unsigned char *msg, uint32_t len, void *user);
void libxl__srm_callout_sendreply(int r, void *user);
