# Fission Base Container

> Pull most recent image: `docker pull codeape/fission:3.7-001`

> Dockerhub page for Fission: [https://hub.docker.com/r/codeape/fission/](https://hub.docker.com/r/codeape/fission/)


Fission is a minimal base container image based on an Alpine container but with a proper init system (OpenRC) which runs syslog and cron by default.
It has the following key traits:

1. **Small Size:** Like Alpine, Fission is very light weight. The image is only 7MB in size uncompressed and adds a single 3MB layer on top of a regular Alpine container.
2. **Standard Alpine:** Fission uses Alpine's standard init system, OpenRC, meaning that you can start, stop, and configure services the exact same way you would on a standard Alpine machine.
3. **Not dependent on container runtime:** Fission uses syslog by default for logging, meaning users are required to tailor their logging setup to get logs from their container runtime, such as Docker.
4. **PID 1 zombie reaping:** Fission's root process is `dumb-init`, meaning there is no worry for zombie processes.
5. **Maximum flexibility:** Fission strives to deliver a bare minimum needed to do whatever you want. You can do anything with it you can do with regular Alpine Linux, within the confines of a container of course.
6. **Static tags:** All Fission builds have a number on the end which corresponds to the build used in the `builds/` directory. This means that any new builds of Fission will have a different number. Thus, if you use `codeape/fission:3.7-001` you can have confidence this will always refer to the same container. Note that the tags without a trailing number, like `codeape/fission:3.7` aren't static and simply reflect the most recent build of Fission.

## Quick Start

To try out Fission simply do the following.

```bash
# Pull image
docker pull codeape/fission:3.7-001
# Start container
docker run -d --name fission-demo codeape/fission:3.7-001
# View init logs
docker logs fission-demo
# Get a shell into the container
docker exec -it fission-demo sh
#  ... take a look around the container and exit ...
# Stop and delete the container
docker stop fission-demo
docker rm fission-demo
```

## Examples

To see a more complex example of using Fission look at the [`examples/webserver_with_ssh`](examples/webserver_with_ssh) directory which will show you how to set up a Fission container with an Nginx web server, a SSH server, and an admin user who can SSH into the container.

## Important Notes for Using Fission

1. Do not create or run containers with the `-t/--tty` flag. For unknown reasons this prevents more than one service from starting when the container launches.
2. Logging is done through syslog by default but you can use a different logging system if you so wish.

# Design

Fission is so simple that the easiest way to understand its design is simply by following the build process. If you are familiar with Docker and Alpine Linux then doing this should be easy.

Start by looking at `bin/build-3.7-001` which is the script used to build `codeape/fission:3.7-0001`. This simply makes use of Docker and anyone familiar with it should find it easy to follow. The gist of the script's operation is that it takes an Alpine image, creates a new container that mounts `build_dirs/001`, runs `build_dirs/001/do_build.sh`, and then commits this into a new image which uses the init setup `do_build.sh` configured. Following the changes done by `do_build.sh` should be easy for anyone familiar with Alpine Linux.
