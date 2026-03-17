# -----------------------------------
# with ChatGPT

# 1) ファイル一覧をソース(C)だけにする
SRCS = /game/bb/lib/stds/src/*.c /game/bb/src/*.c

# 2) コンパイラ・オプションなどはそのまま
CCFLAGS        = -std=c20
CXXFLAGS       = -std=c++20
CC             = afl-clang-fast
COMPILER_FLAGS = -Werror -g -std=c17
LINKER_FLAGS   = # OSによってSDLなどのリンクオプションを加える
ifeq ($(OS), Windows_NT)
	LINKER_FLAGS =  -lmingw32 -lSDL2main -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf
else
	LINKER_FLAGS =  -lSDL2main -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lm
endif

OBJ_NAME = $(BBNAME)


# 3) 「一発ビルド」レシピ vg用フラグ込み
all:
	$(CC) $(VGTEST_UTILS) $(COMPILER_FLAGS) $(CFLAGS) $(SRCS)  \
	    $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(LINKER_FLAGS) $(LDFLAGS) $(VGFLAGS) \
	    -o /game/vgFuzz/sut/$(OBJ_NAME)


clean:
	rm -f /game/vgFuzz/sut/$(OBJ_NAME)
	rm -f *.o
# -----------------------------------