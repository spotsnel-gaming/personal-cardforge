ARG BASE_IMAGE="quay.io/fedora/fedora"
ARG BASE_VERSION="41"

FROM ${BASE_IMAGE}:${BASE_VERSION} AS base

LABEL org.opencontainers.image.source = "https://github.com/spotsnel-gaming/personal-cardforge"

USER root

# Add user with the expected ID (automated setup does not work atm)
RUN useradd -l -u 1000 -G wheel -md /home/forge -p forge forge \
    && sed -i.bkp -e 's/%wheel\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%wheel ALL=NOPASSWD:ALL/g' /etc/sudoers

# essential packages
RUN dnf install -y \
        dnf-plugins-core openssh-server \
    && dnf clean all \
    && rm -rf /var/cache/yum

# install tailscale
RUN dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
    && dnf install -y \
        tailscale \
    && dnf clean all \
    && rm -rf /var/cache/yum \
    && mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

# graphical
RUN dnf install -y \
        x11vnc \
	xrdp \
        i3 \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN dnf install -y https://github.com/spotsnel/AltRPMS-KasmVNC/releases/download/1.3.3/kasmvncserver-1.3.3-1.fc41.x86_64.rpm \
    && dnf clean all \
    && rm -rf /var/cache/yum \
    && usermod -a -G kasmvnc-cert forge

# tailscale
RUN sed -i 's/^FLAGS=".*"/FLAGS="--tun=userspace-networking"/' /etc/default/tailscaled

RUN dnf install -y java-21-openjdk \
    && dnf clean all \
    && rm -rf /var/cache/yum

USER forge

# prepare VNC server environment
RUN mkdir -p ~/Downloads ~/Applications/Cardforge \
    && cd ~/Downloads \
    && curl -fsSL https://github.com/Card-Forge/forge/releases/download/forge-2.0.00/forge-installer-2.0.00.tar.bz2 -o forge-install.tar.bz2 \
    && tar -xjvf forge-install.tar.bz2 -C ~/Applications/Cardforge/ \
    && rm -f forge-install.tar.bz2 \
    && mkdir -p ~/.vnc ~/.config/i3 \
    && echo "exec ~/Applications/Cardforge/forge.sh " >> ~/.config/i3/config \
    && /bin/bash -c "echo -e 'password\npassword\n\n' | kasmvncpasswd -u forge -w" \
    && echo $'#!/bin/sh\ni3 &' > ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup \
    && touch ~/.vnc/.de-was-selected

# ensure to become root for systemd
USER root

RUN systemctl enable tailscaled

ENTRYPOINT ["/sbin/init"]
