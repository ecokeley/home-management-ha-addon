FROM alpine:3.18
RUN apk add --no-cache \
    chromium \
    xorg-server \
    xf86-video-fbdev \
    x11vnc \
    supervisor \
    mesa-dri-gallium

COPY configure-desktop.sh /usr/local/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/configure-desktop.sh

EXPOSE 5900
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]