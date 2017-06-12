
obj-m := switch_on_off.o

KERNELDIR := /lib/modules/$(shell uname -r)/build
CURRENT_PATH := $(shell pwd)

all:
	make -C $(KERNELDIR) M=$(CURRENT_PATH) modules
clean:
	make -C $(KERNELDIR) M=$(CURRENT_PATH) clean
