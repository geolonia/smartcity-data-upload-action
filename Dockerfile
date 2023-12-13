# 基本となるイメージ
FROM ubuntu:latest

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    gdal-bin \
    git \
    build-essential \
    nodejs \
    npm \
    libsqlite3-dev \
    zlib1g-dev

# tippecanoe のインストール（felt リポジトリから）
RUN git clone https://github.com/felt/tippecanoe.git \
    && cd tippecanoe \
    && make -j \
    && make install

# go-pmtiles のインストール
RUN curl -LO https://golang.org/dl/go1.18.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin \
    && go install github.com/protomaps/go-pmtiles@latest

COPY bin/ /bin/
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
