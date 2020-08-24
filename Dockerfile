FROM fedora:32

ENV MONGOCXX_VERSION=3.6.0

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN dnf update -y && dnf install -y \
  autoconf \
  automake \
  cmake \
  curl \
  gcc \
  g++ \
  git \
  libtool \
  make \
  pkg-config \
  unzip \
  wget \
  python3 \
  golang


RUN dnf install -y mongo-c-driver-devel.x86_64 \
	libbson-devel.x86_64 \
	openssl-devel.x86_64 \
	mongo-c-driver


ENV MONGOC_VERSION=1.17.0 \
  MONGOCXX_VERSION=3.6.0

WORKDIR /opt
RUN curl -L -O https://github.com/mongodb/mongo-c-driver/releases/download/1.17.0/mongo-c-driver-1.17.0.tar.gz \
  && tar xzf mongo-c-driver-1.17.0.tar.gz \
  && cd mongo-c-driver-1.17.0 \
  && mkdir cmake-build && cd cmake-build \
  && cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/local -DBUILD_SHARED_LIBS=OFF -DENABLE_TESTS=OFF .. \
  && make -j8 \
  && make install

WORKDIR /opt
RUN curl -OL https://github.com/mongodb/mongo-cxx-driver/releases/download/r3.6.0/mongo-cxx-driver-r3.6.0.tar.gz \
  && tar -xzf mongo-cxx-driver-r3.6.0.tar.gz \
  && cd mongo-cxx-driver-r3.6.0/build \
  && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/local \
  && cmake --build . --target EP_mnmlstc_core \
  && cmake --build . \
  && sudo cmake --build . --target install

ENV STORAGE_KERNEL_BUILD_PATH /home/doc

COPY . $STORAGE_KERNEL_BUILD_PATH/src/storage_kernel/

RUN echo "-- building" && \
    mkdir -p $STORAGE_KERNEL_BUILD_PATH/out/storage_kernel && \
    cd $STORAGE_KERNEL_BUILD_PATH/out/storage_kernel && \
    cmake .. $STORAGE_KERNEL_BUILD_PATH/src/storage_kernel && \
    make