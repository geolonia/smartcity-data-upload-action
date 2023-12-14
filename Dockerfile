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

# Pythonとpipをインストール
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 仮想環境の作成とアクティベート
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# AWS CLIを仮想環境にインストール
RUN pip3 install awscli

# 現在のディレクトリを ディレクトリ構成を維持して / にコピー
COPY . /app

ENTRYPOINT ["/app/entrypoint.sh"]
