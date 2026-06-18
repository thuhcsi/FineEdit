#!/bin/bash

# 获取所有.json文件名（不含路径和扩展名）
# metadata_dir="/apdcephfs_qy3/share_1474453/shuoyizhou/data_preprocess/LibriTTS-P/metadata_new"
# speaker_files=("$metadata_dir"/*.json)

# # 提取基名并去除.json后缀
# speaker_names=()
# for fullpath in "${speaker_files[@]}"; do
#   filename=$(basename -- "$fullpath")       # 去除路径[6](@ref)
#   speaker_name=$(echo "${filename%.*}" | awk -F'-' '{print $NF}')     # 去除扩展名[6](@ref)
#   speaker_names+=("$speaker_name")
# done

# # 随机选择10个说话人
# shuffled_speakers=($(shuf -e "${speaker_names[@]}" -n 10))

shuffled_speakers=('252' '1664' '3394' '3723' '3864' '3894' '5199' '5656' '7704' '8044')
# 生成输入输出目录
input_dirs=()
output_dirs=()
for speaker in "${shuffled_speakers[@]}"; do
  input_dirs+=("/Users/zhoushuoyi/Documents/aaai/LibriTTS-R/LibriTTS_R/LibriTTS-R-speaker/$speaker")
  output_dirs+=("/Users/zhoushuoyi/Documents/aaai/LibriTTS-R/LibriTTS_R/LibriTTS-R_prosody-eval/$speaker")
done


declare -a adjustments=("speed1.5" "speed0.75" "volume3" "volume0.5" "pitch1.1" "pitch0.9")

# 创建输出目录
for output_dir in "${output_dirs[@]}"; do
    for adjustment in "${adjustments[@]}"; do
        mkdir -p "$output_dir/$adjustment"
    done
done

# 定义处理函数
process_file() {
    local file="$1"
    local adjustment="$2"
    local output_dir="$3"

    filename=$(basename "$file")
    output_file="$output_dir/$adjustment/$filename"

    if [[ $adjustment == speed* ]]; then
        speed_value=${adjustment#speed}
        ffmpeg -i "$file" -af "atempo=${speed_value}" "$output_file"
    elif [[ $adjustment == volume* ]]; then
        volume_value=${adjustment#volume}
        ffmpeg -i "$file" -af "volume=${volume_value}" "$output_file"
    elif [[ $adjustment == pitch* ]]; then
        pitch_value=${adjustment#pitch}
        ffmpeg -i "$file" -af "asetrate=24000*${pitch_value},aresample=24000" "$output_file"
    fi

    # 检查 ffmpeg 命令是否成功
    if [ $? -ne 0 ]; then
        echo "Error processing $file with adjustment $adjustment" >> error_log.txt
    fi
}

export -f process_file


# 遍历输入文件夹中的所有 .wav 文件并使用 GNU Parallel 进行并行处理
for i in "${!input_dirs[@]}"; do
    input_dir="${input_dirs[$i]}"
    output_dir="${output_dirs[$i]}"
    find "$input_dir" -type f -name "*.wav" | while read -r file; do
        for adjustment in "${adjustments[@]}"; do
            process_file "$file" "$adjustment" "$output_dir"
        done
    done
done
# --jobs 4 表示并行处理 4 个任务，你可以根据你的 CPU 核心数调整这个值
