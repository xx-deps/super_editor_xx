#!/usr/bin/env bash

# 设置 packages 根目录（根据你的项目结构修改路径）
PACKAGES_DIR="./packages"

# 检查目录是否存在
if [ ! -d "$PACKAGES_DIR" ]; then
  echo "目录 $PACKAGES_DIR 不存在"
  exit 1
fi

# 遍历 packages 目录下的每个子目录
for dir in "$PACKAGES_DIR"/*; do
  if [ -d "$dir" ] && [ -f "$dir/pubspec.yaml" ]; then
    echo "正在处理 $dir"
    (
      cd "$dir" || exit
      fvm use 3.32.8
      fvm flutter pub get
    )
  else
    echo "跳过 $dir（不是有效的 Dart package）"
  fi
done

echo "所有 packages 已处理完毕。"
