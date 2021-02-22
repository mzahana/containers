# containers
This repod has some docker images that include Ubuntu 18, ROS, CUDA 10.1, PX4. The current Docker images assume that an NVIDIA GPU is available.

The Dockerfiles of different images are located inside the `docker` folder, and linked to [my Docker hub account](https://hub.docker.com/u/mzahana), for automatic building (i.e. any changes in the Docker files will trigger builds of the corresponding Dokcker hub repos).

# Usage
* First make sure that you have Nvidia GPU drivers installed in your machine.
* Clone this package, `git clone https://github.com/mzahana/containers.git`
* Next, install docker. You can use the `scripts/setup_docker.sh` script for that.
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

# Available Docker images
To be done.