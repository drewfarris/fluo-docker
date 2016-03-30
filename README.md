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
docker run -it -P fluo-docker bash
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
in place. To do this, we need to figure out what port the SSH server on the
container is mapped to externally.

```
$> docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                                                                                                                                                            NAMES
05aa7d305b40        fluo-docker         "/bin/bash"         2 hours ago         Up 2 hours          0.0.0.0:32774->22/tcp, 0.0.0.0:32773->3000/tcp, 0.0.0.0:32772->8083/tcp, 0.0.0.0:32771->8088/tcp, 0.0.0.0:32770->18080/tcp, 0.0.0.0:32769->50070/tcp, 0.0.0.0:32768->50095/tcp   grave_newton
```

In this case, port 32774 on the docker VM is mapped to port 22 on the container.
On the mac, we'll need to forward port 32772 from the host to the docker vm.
For virtualbox, this will look something like the following:

```
docker-machine ip big
192.168.99.100
ssh -D 12345 root@192.168.99.100 -p 3277
```

Then you'll need to set up foxyproxy or your browser plugin of choice to use
localhost:12345 as the local socks proxy. This will give you the ability to
go to http://localhost:50095 for example to see the Accumulo monitor page.
