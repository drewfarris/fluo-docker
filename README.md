fluo-docker
=====================

The intent of this Dockerfile is to help you build a Docker image that will
help you run fluo-dev. The vm is rather barebones. This requires you to have
Docker installed. Go to https://docs.docker.com/ to get started.

fluo-dev will run an entire Hadoop, Yarn, Accumulo, Graphan and InfluxDB stack
within a single Docker container, so if you are using something like
docker-machine in conjunction with virtualbox, be sure to have around 8g of
memory available to the VM within which the docker container will be running,
e.g:

```
docker-machine create --virtualbox-memory 8192 --virtualbox-cpu-count 2 --virtualbox-disk-size 65536 --driver virtualbox big
```

The rest of this file assumes you have this main docker VM running.

Begin by building an image named `fluo-docker` using the Dockerfile provided.

```
docker build -t fluo-docker .
```

After the image is built, start a container running the bash shell:

```
docker run -it --memory-swappiness=0 -p 22222:22/tcp fluo-docker bash
```

In the resulting shell, start sshd and run fluo-dev setup. The various components
we are starting expect to be able to execute `ssh localhost` and be able connect
without a password.

```
service sshd start
/root/fluo-dev/bin/fluo-dev setup
```

Once everything has started, you'll need a way to connect to the various
web-based user interface components to monitor what's going on. The easiest
way to do this is to connect to the docker container via SSH with a socks proxy
in place. In the run command above, we mapped port 22 on the container to
port 22222 on the host. In the shell that started with docker-run, you'll need
to append your ssh public key to /root/.ssh/authorized_keys

Once that's done, all that's left is to determine the ip of the machine
we're running on and fire up a socks proxy based on that
```

```
docker-machine ip big
192.168.99.100
ssh -N -f -D 12345 root@192.168.99.100 -p 222222
```

Then you'll need to set up foxyproxy or your browser plugin of choice to use
localhost:12345 as the local socks proxy. This will give you the ability to
go to http://localhost:50095 for example to see the Accumulo monitor page.
