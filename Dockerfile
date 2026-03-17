FROM aflplusplus/aflplusplus:v4.34c

# ==================================================================
# テストキットの準備
# ==================================================================
RUN mkdir /game && \
    mkdir /game/fuzz && \
    mkdir /game/fuzz/in && \
    mkdir /game/fuzz/out && \
    mkdir /game/fuzz/sut && \
    mkdir /game/fuzz/tools


# ==================================================================
# SDL2のセットアップ
# =================================================================
RUN apt-get update && \
    apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev && \
    apt-get clean && \
    apt update && \
    apt install -y x11-apps \
    pulseaudio \
    ffmpeg \
    alsa-utils \
    xserver-xorg \
    && rm -rf /var/lib/apt/lists/*
# x11-appsはおまけ


# ==================================================================
# Tetrisセットアップ(対象ゲームに合わせて変更)
# ==================================================================
RUN mkdir /game/tetris && \
    git clone https://github.com/brenns10/tetris.git /game/tetris &&\
    apt install -y cmake libncurses5-dev


# # ==================================================================
# # Brick Breakerのセットアップ
# # ==================================================================
# RUN mkdir /game/bb && \
#     git clone https://github.com/joshuacrotts/brick-breaker.git /game/bb


USER root
WORKDIR /home/root