#!/bin/bash

# -*- 統計用データ抽出マクロ -*-
# プロジェクトフォルダから、各instanceフォルダ内のfuzzer_stats, plot_data, crashesを抽出


# 抽出元のプロジェクトパス
proj_dir="/game/vgFuzz/out/251229"

# 出力先
output_dir="/game/host/proj251229"

# 想定ディレクトリ構造:
# method_dir
# ├── test1
# │   ├── instance1
# │   ├── ...
# │   └── instanceN
# ├── test2
# │   ├── ...
# │   └── ...
# └── testM
#     ├── ...
#     └── ...

for proj in "$proj_dir"/*; do
    echo "Processing project: $proj"

    # 各instanceフォルダ内のfuzzer_stats, plot_data, crashesを取得, projフォルダの名前を付加した専用出力先に保存
    for test_dir in "$proj"/test*; do
        if [ -d "$test_dir" ]; then
            # Check for both instance* and default folders
            for instance_dir in "$test_dir"/instance* "$test_dir"/default; do
                if [ -d "$instance_dir" ]; then
                    data_write_dir="$output_dir/$(basename "$proj")/$(basename "$test_dir")/$(basename "$instance_dir")"
                    mkdir -p "$data_write_dir"
                    if [ -f "$instance_dir/fuzzer_stats" ]; then
                        cp "$instance_dir/fuzzer_stats" "$data_write_dir/"
                    else
                        echo "        Failed to retrieve fuzzer_stats in $data_write_dir."
                    fi
                    
                    # plot_dataの取得
                    if [ -f "$instance_dir/plot_data" ]; then
                        # Save plot_data as plot_data.txt for consistency in output naming
                        cp "$instance_dir/plot_data" "$data_write_dir/"
                    else
                        echo "        Failed to retrieve plot_data in $data_write_dir."
                    fi

                    # crashesの取得
                    crashes_dir="$instance_dir/crashes"
                    if [ -d "$crashes_dir" ]; then
                        mkdir -p "$data_write_dir/crashes"
                        cp "$crashes_dir"/* "$data_write_dir/crashes/"
                    else
                        echo "        No crashes directory found in $data_write_dir."
                    fi
                fi
            done
        fi
    done
done