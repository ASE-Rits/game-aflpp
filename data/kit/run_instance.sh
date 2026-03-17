#!/bin/bash

# 設定ファイル読み込み
source ./test.conf


test_name=$test_name
project_folder=$project_folder
test_time=$test_time
initfuzz_folder=$initfuzz_folder
testcase_time=$testcase_time
memory_limit=$memory_limit
additional_args=$additional_args

# [想定コマンド]: run_dict_instance.sh [グループ番号] [インスタンス番号]

if [ "$#" -lt 1 ]; then
  INSTANCE_NUM="NaN"
  GROUP_NUM="NaN"
elif [ "$#" -lt 2 ]; then
  GROUP_NUM="$1"
  INSTANCE_NUM="NaN"
else
  GROUP_NUM="$1"
  INSTANCE_NUM="$2"
fi

if [ "$INSTANCE_NUM" = "NaN" ]; then
    AFL_MODE=""
    if [ "$GROUP_NUM" = "NaN" ]; then
        OUT_NAME=""
    else
        OUT_NAME="test$GROUP_NUM"
    fi
elif [ "$INSTANCE_NUM" = "1" ]; then
    AFL_MODE="-M instance1"
    OUT_NAME="test$GROUP_NUM"
else
    AFL_MODE="-S instance${INSTANCE_NUM}"
    OUT_NAME="test$GROUP_NUM"
fi



# ファジング開始
# 繰り返し実行するとAlsaがエラーを出すため(原因不明)、SDL_AUDIODRIVER=dummyを指定
SDL_AUDIODRIVER=dummy afl-fuzz -V $test_time -t $testcase_time $AFL_MODE -m $memory_limit $additional_args -i /game/fuzz/in/$initfuzz_folder -o $project_folder/$test_name/$OUT_NAME -- /game/fuzz/sut/$test_name