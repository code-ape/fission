# Fission Example: Web Server with SSH


The following demo builds a docker container using the Dockerfile content pasted below, copied your SSH public key into it, and runs it.

**NOTE**: Use the environmental variable `SSH_PUB_KEY` to specify which key you'd like to copy.

# Step 1: Run try_me.sh

In your terminal run `./try_me.sh`. If you need sudo to use Docker then run `sudo -E ./try_me.sh`. This will effectively launch a Docker container built with the following Dockerfile and launch it in an attached mode. This means you'll see the container logs from `openrc` and can press `ctrl-C` at any time to stop the container which will then be automatically deleted.

```Dockerfile
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
```

# Step 2: Test your container via SSH

The `try_me.sh` script exposes the SSH and HTTP server on your local machine only.
To try out SSH run the following in another terminal:

```bash
ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -p '2200' 'admin@localhost'
```

> **NOTE:** The two long `-o ...` options passed makes it such that SSH won't save the host key nor ask you to verify it. This is just a minor convenience to save you from having to delete the container key's fingerprint from `~/.ssh/known_hosts` every time you do this.

You can check that syslog is working correctly by looking at the contents of `tail /var/log/messages` which should have a line related to you SSH'ing in that looks something like:

```
Feb 14 16:41:57 c2c1fb7c3409 auth.info sshd[188]: Accepted publickey for admin from 172.17.0.1 port 54526 ssh2: ED25519 SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

# Step 3: Test your container via HTTP

Open up a browser and go to `http://localhost:8800`. You should see a 404 page from the Nginx since we haven't configured the server to have any content. You can even check this request was logged by running `sudo cat /var/log/nginx/access.log ` which should have a single line for the page we just requested that looks something like:

```
172.17.0.1 - - [14/Feb/2018:16:42:16 +0000] "GET / HTTP/1.1" 404 162 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0" "-"
```

# Conclusion

Congrats! With a simple Dockerfile you've seen how to use a Fission container to set up an Nginx server with SSH access. If you have any questions or found anything in this example unclear please drop an issue in this repo. Thanks! 
