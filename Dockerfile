# 基本となるイメージ
FROM ubuntu:latest

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    gdal-bin \
    git \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# tippecanoe のインストール（felt リポジトリから）
RUN git clone https://github.com/felt/tippecanoe.git \
    && cd tippecanoe \
    && make -j \
    && make install

# go-pmtiles のインストール
RUN curl -L https://github.com/protomaps/go-pmtiles/releases/download/v1.11.1/go-pmtiles_1.11.1_Linux_arm64.tar.gz -o go-pmtiles_1.11.1_Linux_arm64.tar.gz \
    && tar -xzvf go-pmtiles_1.11.1_Linux_arm64.tar.gz \
    && chmod +x pmtiles \
    && mv pmtiles /usr/local/bin/

COPY package.json /package.json
COPY package-lock.json /package-lock.json
COPY bin/ /bin/
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
