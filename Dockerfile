# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie

FROM public.ecr.aws/debian/debian:${DEBIAN_VERSION} AS builder

ARG DEBIAN_VERSION=trixie
ARG KVER

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN test -n "${KVER:-}" || (echo "ERROR: set --build-arg KVER=<kernel-version>, e.g. 6.17.4-1-pve or 6.1.0-18-amd64" && exit 2)

RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
      bc \
      build-essential \
      ca-certificates \
      curl \
      git \
      gnupg \
      libelf-dev \
      pkg-config \
    && \
    rm -rf /var/lib/apt/lists/*

RUN if [[ "${KVER}" == *"-pve"* ]]; then \
      curl -fsSL "https://enterprise.proxmox.com/debian/proxmox-archive-keyring-${DEBIAN_VERSION}.gpg" \
        -o /usr/share/keyrings/proxmox-archive-keyring.gpg; \
      printf '%s\n' \
        'Types: deb' \
        'URIs: http://download.proxmox.com/debian/pve' \
        "Suites: ${DEBIAN_VERSION}" \
        'Components: pve-no-subscription' \
        'Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg' \
        > /etc/apt/sources.list.d/proxmox.sources; \
      apt-get update -qq; \
      apt-get install -yqq --no-install-recommends \
        "proxmox-headers-${KVER%-pve}"; \
    else \
      apt-get update -qq; \
      apt-get install -yqq --no-install-recommends \
        "linux-headers-${KVER}"; \
    fi \
    && rm -rf /var/lib/apt/lists/*

COPY ./src /work/src
WORKDIR /work/src/applesmc

RUN KDIR="/lib/modules/${KVER}/build"; \
    if [[ ! -e "${KDIR}/Makefile" ]]; then \
      if [[ "${KVER}" == *"-pve"* ]]; then \
        KDIR="/usr/src/linux-headers-${KVER%-pve}"; \
      else \
        KDIR="/usr/src/linux-headers-${KVER}"; \
      fi; \
    fi; \
    test -e "${KDIR}/Makefile" || (echo "ERROR: kernel build dir not found: ${KDIR}" && ls -la /lib/modules /usr/src || true && exit 3); \
    make KDIR="${KDIR}" KVER="${KVER}" all

RUN install -D -m 0644 applesmc_t2_kmod.ko /out/applesmc_t2_kmod.ko

# ---- Export-only stage ----
FROM scratch AS artifact
COPY --from=builder /out/applesmc_t2_kmod.ko /applesmc_t2_kmod.ko
