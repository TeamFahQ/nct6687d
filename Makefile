obj-m += nct6687.o

curpwd      := $(shell pwd)
kver        ?= $(shell uname -r)
commitcount := $(shell git rev-list --all --count 2>/dev/null)
commithash  := $(shell git rev-parse --short HEAD 2>/dev/null)
fedoraver   := $(shell sed -n 's/.*Fedora release \([^ ]*\).*/\1/p' /etc/fedora-release 2>/dev/null || echo 0)

# Detect if the kernel was built with clang/LLVM and use the same compiler
KERNEL_CC := $(shell grep -qs CONFIG_CC_IS_CLANG=y /lib/modules/${kver}/build/.config && echo clang)
ifeq ($(KERNEL_CC),clang)
  LLVM_FLAGS := LLVM=1
endif

build:
	rm -rf ${curpwd}/${kver}
	mkdir -p ${curpwd}/${kver}
	cp ${curpwd}/Makefile ${curpwd}/nct6687.c ${curpwd}/${kver}
	make -C /lib/modules/${kver}/build M=${curpwd}/${kver} $(LLVM_FLAGS) modules
install: build
	sudo cp ${curpwd}/${kver}/nct6687.ko /lib/modules/${kver}/kernel/drivers/hwmon/
	sudo depmod
	sudo modprobe nct6687
clean:
	[ -d "${curpwd}/${kver}" ] && make -C /lib/modules/${kver}/build M=${curpwd}/${kver} $(LLVM_FLAGS) clean || true
