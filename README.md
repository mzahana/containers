# containers
Contains some docker containers that includes Ubuntu 18, ROS, CUDA 10.1, PX4.

The Dockerfiles of different images are located inside the `docker` folder, and linked to [my Docker hub account](https://hub.docker.com/u/mzahana)

# Usage
* First, you need to install docker. You can use the `script/setup_docker.sh` script for that.
  ```bash
  cd scripts
  chmod +x setup_docker.sh
  ./setup_docker.sh
  ```
* To pull docker image and run it, use
  ```sh
  cd scripts
  ./run_docker.sh px4
  ```
  `px4` is a name of your choice of the container.

**NOTE**: The docker containers will run with a user named `arrow`, and with password `arrow`, in case it's needed.