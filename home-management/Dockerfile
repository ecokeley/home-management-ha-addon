FROM alpine:3.18
RUN apk add --no-cache xfce4 xfce4-terminal lightdm chromium dbus-x11
COPY configure-desktop.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure-desktop.sh
CMD ["/usr/local/bin/configure-desktop.sh"]