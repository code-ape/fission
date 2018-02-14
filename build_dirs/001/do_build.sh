#!/usr/bin/env sh

# Partial credit to Mohammad Abdoli Rad who has also created an Alpine based
# container that uses OpenRC which this build script borrows some code from:
#  https://github.com/dockage/alpine-openrc

set -ex

script_dir="/mnt/build_dir"

# Install dumb-init and openrc
apk add --update --no-cache openrc dumb-init

# Copy over config files
cp "$script_dir/inittab" /etc/inittab
cp "$script_dir/fission_init" /sbin/fission_init
cp "$script_dir/syslog.init" /etc/init.d/syslog
cp "$script_dir/crond.init" /etc/init.d/crond

# Sed actions in order of occurance:
#   1. Change subsystem type to "docker"
#   2. Allow all variables through
#   3. Start crashed services
#   4. Define extra dependencies for services
sed -i \
    -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
    -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
    -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
    -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
    -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
    /etc/rc.conf

# Remove unnecessary services
rm -f \
    /etc/init.d/hwdrivers \
    /etc/init.d/hwclock \
    /etc/init.d/hwdrivers \
    /etc/init.d/modules \
    /etc/init.d/modules-load \
    /etc/init.d/modloop

# Can't do cgroups
sed -i 's/cgroup_add_service /# cgroup_add_service /g' \
    /lib/rc/sh/openrc-run.sh
sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

# Add syslog and crond to run at default level
rc-update add syslog default
rc-update add crond default
