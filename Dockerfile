# 基本となるイメージ
FROM node:latest

WORKDIR /app

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    gdal-bin \
    git \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev

# tippecanoe のインストール（felt リポジトリから）
RUN git clone https://github.com/felt/tippecanoe.git \
    && cd tippecanoe \
    && make -j \
    && make install

# go-pmtiles のインストール
RUN curl -L https://github.com/protomaps/go-pmtiles/releases/download/v1.11.1/go-pmtiles_1.11.1_Linux_x86_64.tar.gz -o go-pmtiles_1.11.1_Linux_x86_64.tar.gz \
    && tar -xzvf go-pmtiles_1.11.1_Linux_x86_64.tar.gz \
    && chmod +x pmtiles \
    && mv pmtiles /usr/local/bin/

# 現在のディレクトリを ディレクトリ構成を維持して / にコピー
COPY . /app

ENTRYPOINT ["/app/entrypoint.sh"]
