# applesmc_t2

This project is a fork of [michalkouril/mbp2018-etc](https://github.com/michalkouril/mbp2018-etc) and [MCMrARM/mbp2018-etc](https://github.com/MCMrARM/mbp2018-etc). It aims to enable fan control support on Mac mini 2018.

## Building the module

```sh
KERNEL_VERSION=$(uname -r) # Or set it manually, eg KERNEL_VERSION="6.17.4-1-pve"
docker buildx build \
  --build-arg DEBIAN_VERSION=trixie \
  --build-arg KVER=${KERNEL_VERSION} \
  -t applesmc-t2-builder \
  --output type=local,dest=./out .
```

## Check the module

```sh
modinfo ./out/applesmc_t2_kmod.ko
```

## Installation

```sh
install -D -m 0644 applesmc_t2_kmod.ko /lib/modules/$(uname -r)/extra/applesmc_t2_kmod.ko
depmod -a
modprobe applesmc_t2_kmod
dmesg | tail -n 20
```

## Links

- [AdityaGarg8/t2-ubuntu-repo](https://github.com/AdityaGarg8/t2-ubuntu-repo)
