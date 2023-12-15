FROM node:20

WORKDIR /action/workspace

# 現在のディレクトリを ディレクトリ構成を維持して / にコピー
COPY . .

# 必要なパッケージのインストール
# 一度に実行してキャッシュを効率的に利用
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    gdal-bin \
    git \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev \
    python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip3 install awscli && \
    npm install

ENV PATH="/opt/venv/bin:$PATH"

ARG TIPPECANOE_VERSION=2.37.1

# tippecanoe のインストール
RUN curl -L https://github.com/felt/tippecanoe/archive/refs/tags/${TIPPECANOE_VERSION}.tar.gz -o tippecanoe.tar.gz \
    && tar -xzvf tippecanoe.tar.gz \
    && cd tippecanoe-${TIPPECANOE_VERSION} \
    && make -j \
    && make install

ARG GO_PMTILES_VERSION=1.11.1

# go-pmtiles のインストール
RUN curl -L https://github.com/protomaps/go-pmtiles/releases/download/v${GO_PMTILES_VERSION}/go-pmtiles_${GO_PMTILES_VERSION}_Linux_x86_64.tar.gz -o go-pmtiles.tar.gz \
    && mkdir -p go-pmtiles && cd go-pmtiles \
    && tar -xzvf ../go-pmtiles.tar.gz \
    && chmod +x pmtiles \
    && mv pmtiles /usr/local/bin/

# node イメージの ENTRYPOINT をクリアする
ENTRYPOINT []

# entrypoint.sh を実行する
CMD ["/action/workspace/entrypoint.sh"]
