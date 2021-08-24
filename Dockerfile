FROM agners/archlinuxarm-arm32v7:latest
 
ENV container=docker  
 
ENV PIKVM_REPO_KEY=912C773ABBD1B584
ENV PIKVM_REPO_URL=https://pikvm.org/repos
ENV BOARD=rpi4 
ENV ARCH=arm
ENV WEBUI_ADMIN_PASSWD=admin
ENV IPMI_ADMIN_PASSWD=admin
ENV PLATFORM=v2-hdmiusb

COPY install-pikvm.sh /root/install-pikvm.sh

RUN /root/install-pikvm.sh \
&& pacman -Sy --noconfirm vim grep \
&& pacman -Sy --noconfirm systemd

ENTRYPOINT ["/lib/systemd/systemd"]

CMD ["--log-level=info", "--system"]
STOPSIGNAL SIGRTMIN+3

COPY container.target /etc/systemd/system/container.target
 
RUN ln -sf /etc/systemd/system/container.target /etc/systemd/system/default.target \
&& mkdir /etc/systemd/system/container.target.wants/

COPY *.service /etc/systemd/system/

RUN ln -sf /etc/systemd/system/kvmd-nginx.service /etc/systemd/system/container.target.wants/kvmd-nginx.service \
&& ln -sf /etc/systemd/system/kvmd-otg.service /etc/systemd/system/container.target.wants/kvmd-otg.service \
&&  ln -sf /etc/systemd/system/kvmd.service /etc/systemd/system/container.target.wants/kvmd.service \
&& ln -sf /etc/systemd/system/kvmd-webterm.service /etc/systemd/system/container.target.wants/kvmd-webterm.service \
&& find /lib/systemd/system/ -name '*.target' ! -name 'sysinit.target' -type f -exec rm -f {} + \
