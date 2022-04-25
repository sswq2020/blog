#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run build

cd public

git add -A
git commit -m 'deploy'

git push -f git@github.com:sswq2020/sswq2020.github.io.git master

cd -