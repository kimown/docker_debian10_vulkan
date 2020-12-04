# run
```shell
sh download.sh
docker build -t docker_debian10_vulkan:latest .
docker run --gpus all -it docker_debian10_vulkan /bin/bash

vulkaninfo > a.txt && cat a.txt |grep non_
```