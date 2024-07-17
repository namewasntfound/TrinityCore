FROM ubuntu:22.04 AS builder

RUN apt-get update && \
    apt-get install -yq git clang cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mysql-server p7zip

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

RUN useradd -m wowclassic
USER wowclassic

WORKDIR /home/wowclassic

COPY . .

RUN cmake -S . -B bin -DCMAKE_INSTALL_PREFIX=check_install -DWITH_WARNINGS=1

WORKDIR /home/wowclassic/bin

RUN make && make -j $(nproc) install

FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -yq clang cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mysql-server p7zip
COPY --from=builder /home/wowclassic/check_install/bin /usr/local