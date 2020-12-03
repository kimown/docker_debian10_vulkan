FROM docker_debian10_cuda11_nvenc10:latest

COPY . /docker_debian10_vulkan

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    libx11-xcb-dev \
    libxkbcommon-dev \
    libwayland-dev \
    libxrandr-dev \
    libegl1-mesa-dev \
    python3 \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install cmake version 3.15
RUN cd /docker_debian10_vulkan && \
    tar -xvf cmake-3.15.2-Linux-x86_64.tar.gz && cp cmake-3.15.2-Linux-x86_64/bin/cmake /usr/local/bin && \
    mkdir -p /usr/local/share/cmake-3.15 && \
    cp -r cmake-3.15.2-Linux-x86_64/share/cmake-3.15/* /usr/local/share/cmake-3.15 && \
    rm -rf cmake-3.15.2-Linux-x86_64* && unset http_proxy https_proxy

RUN echo "env start"
RUN env
RUN echo "env end"
RUN echo "nproc" && echo $(nproc)

# Download and compile vulkan components
RUN cd /docker_debian10_vulkan/Vulkan-ValidationLayers && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`) && \
    mkdir build && cd build && export MAKE_JOBS=5 && ../scripts/update_deps.py && \
    cmake -C helper.cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -j 1 && make install && ldconfig && \
    mkdir -p /usr/local/lib && cp -a Vulkan-Loader/build/install/lib/* /usr/local/lib || echo "Vulkan_Loader" && \
    mkdir -p /usr/local/include/vulkan && cp -r Vulkan-Headers/build/install/include/vulkan/* /usr/local/include/vulkan && \
    mkdir -p /usr/local/share/vulkan/registry && \
    cp -r Vulkan-Headers/build/install/share/vulkan/registry/* /usr/local/share/vulkan/registry && \
    rm -rf /opt/vulkan && unset http_proxy https_proxy

    
RUN apt-get update && apt-get install -y --no-install-recommends \
    libx11-xcb-dev \
    libxkbcommon-dev \
    libwayland-dev \
    libxrandr-dev \
    libegl1-mesa-dev && \
    rm -rf /var/lib/apt/lists/*

COPY nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json

RUN ls ls /usr/lib/x86_64-linux-gnu/libnvidia-glvkspirv.so.450.80.02
#RUN cp /docker_debian10_cuda11_nvenc10/NVIDIA-Linux-x86_64-450.80.02.run /docker_debian10_vulkan && cd /docker_debian10_vulkan  && chmod +x NVIDIA-Linux-x86_64-450.80.02.run && \
#    ./NVIDIA-Linux-x86_64-450.80.02.run --extract-only && cd NVIDIA-Linux-x86_64-450.80.02 && ls && ls /usr/lib/x86_64-linux-gnu/ && cp libnvidia-glvkspirv.so.450.80.02 /usr/lib/x86_64-linux-gnu/ 
#    
RUN cd /docker_debian10_cuda11_nvenc10 && rm -rf NVIDIA-Linux*

RUN /bin/bash /docker_debian10_vulkan/build.sh
