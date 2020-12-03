# run
```shell
sh download.sh
docker build -t docker_debian10_vulkan:latest .
docker run --gpus all -it docker_debian10_vulkan /bin/bash

```