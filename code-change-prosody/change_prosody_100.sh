#!/bin/bash
# 5. 随机种子函数（用于shuf的--random-source参数）
get_seeded_random() {
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt </dev/zero 2>/dev/null
}

# 1. 配置路径
input_root="/apdcephfs_qy3/share_1474453/shuoyizhou/data_preprocess/LibriTTS-R/LibriTTS_R"         # 修改为你的输入目录
output_root="/zhiji-universal-cfs-cq2/speech/prompt_based_data/LibriTTS-R_prosody_100"           # 修改为你的输出目录

# 2. 获取所有speaker id
all_speakers=($(find "$input_root" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))

# 3. 随机选取100个speaker（可复现，种子为42）
selected_speakers=($(printf "%s\n" "${all_speakers[@]}" | shuf --random-source=<(get_seeded_random 42) | head -n 100))

# 4. 定义增强类型
declare -a adjustments=("speed1.5" "speed0.75" "volume3" "volume0.5" "pitch1.1" "pitch0.9")


# 6. 处理每个wav文件的函数
process_wav() {
    speaker="$1"
    wavfile="$2"
    input_root="$3"
    output_root="$4"
    adjustments_str="$5"
    IFS=';' read -ra adjustments <<< "$adjustments_str"
    input_file="$input_root/$speaker/$wavfile"
    filename=$(basename "$wavfile")
    output_dir="$output_root/$speaker"

    # 检查6个增强文件是否都已存在，若都存在则跳过
    all_done=1
    for adj in "${adjustments[@]}"; do
        out_file="$output_dir/$adj/$filename"
        if [ ! -f "$out_file" ]; then
            all_done=0
            break
        fi
    done
    if [ $all_done -eq 1 ]; then
        echo "Speaker $speaker, $filename 已处理，跳过"
        return
    fi

    # 创建输出子目录
    for adj in "${adjustments[@]}"; do
        mkdir -p "$output_dir/$adj"
    done

    # 处理每种增强
    for adj in "${adjustments[@]}"; do
        out_file="$output_dir/$adj/$filename"
        if [ -f "$out_file" ]; then
            continue
        fi
        if [[ $adj == speed* ]]; then
            speed_value=${adj#speed}
            ffmpeg -y -i "$input_file" -af "atempo=${speed_value}" "$out_file"
        elif [[ $adj == volume* ]]; then
            volume_value=${adj#volume}
            ffmpeg -y -i "$input_file" -af "volume=${volume_value}" "$out_file"
        elif [[ $adj == pitch* ]]; then
            pitch_value=${adj#pitch}
            ffmpeg -y -i "$input_file" -af "asetrate=24000*${pitch_value},aresample=24000" "$out_file"
        fi
        if [ $? -ne 0 ]; then
            echo "Error processing $input_file with adjustment $adj" >> error_log.txt
        fi
    done
}

export -f process_wav
export input_root output_root

# 7. 并行处理所有wav文件
adjustments_str=$(IFS=';';  echo "${adjustments[*]}")

# 生成所有待处理的wav文件列表
for speaker in "${selected_speakers[@]}"; do
    find "$input_root/$speaker" -type f -name "*.wav" | while read -r wavpath; do
        # wavpath是全路径，转为相对路径
        wavfile="${wavpath#$input_root/$speaker/}"
        echo "$speaker,$wavfile,$input_root,$output_root,$adjustments_str"
    done
done | parallel --colsep ',' --jobs 8 process_wav {1} {2} {3} {4} {5}

# --jobs 8 可根据你的CPU核心数调整