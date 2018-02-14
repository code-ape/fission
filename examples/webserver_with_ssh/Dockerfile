FROM codeape/fission:3.7-001

RUN apk add --update --no-cache nginx openssh sudo \
    # create admin user (no password)
    && adduser -D admin \
    && passwd -d admin \
    # add admin to wheel group
    && addgroup admin wheel \
    # Allow admin sudo privileges
    && echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    # Create admin ssh directory
    && sudo -u admin mkdir /home/admin/.ssh \
    # set ssh and nginx servers to run on boot
    && rc-update add sshd default \
    && rc-update add nginx default

EXPOSE 22 80
