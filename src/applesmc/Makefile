obj-m += applesmc_t2_kmod.o

MY_CFLAGS += -g -DDEBUG
ccflags-y += ${MY_CFLAGS}
CC += ${MY_CFLAGS}

all:
        make -C $(KDIR) M=$(PWD) modules

clean:
        make -C $(KDIR) M=$(PWD) clean

install:
        make -C $(KDIR) M=$(PWD) modules_install
        depmod -a
