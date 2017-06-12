
obj-m := altp2m_create_altp2ms.o

KERNELDIR := /lib/modules/$(shell uname -r)/build
CURRENT_PATH := $(shell pwd)

all:
	make -C $(KERNELDIR) M=$(CURRENT_PATH) modules
clean:
	make -C $(KERNELDIR) M=$(CURRENT_PATH) clean
