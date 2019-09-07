#!/bin/bash

mkdir -p /var/run/sshd

chown -R root:root /root
mkdir -p /root/.config/pcmanfm/LXDE/
cp /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /root/.config/pcmanfm/LXDE/

# If a Oracle Java version is available, install it
if [ -f /root/host/jre-8u221-linux-x64.tar.gz ]; then
    tar xzf /root/host/jre-8u221-linux-x64.tar.gz -C /opt/
    update-alternatives --install /usr/bin/java java /opt/jre1.8.0_221/bin/java 1
    update-alternatives --set java /opt/jre1.8.0_221/bin/java
fi

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
    export VNC_PASSWORD=
fi

cd /usr/lib/web && ./run.py > /var/log/web.log 2>&1 &
nginx -c /etc/nginx/nginx.conf
exec /bin/tini -- /usr/bin/supervisord -n
