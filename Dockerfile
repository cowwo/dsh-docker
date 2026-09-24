FROM node:24-bookworm-slim

ARG DSH_VERSION=latest

# 常用工具。ca-certificates / openssh-client 不是可选项：
# git、gh 走 HTTPS 要证书，git 走 SSH 要 ssh 客户端。
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl wget git openssh-client gh \
      python3 python3-pip python3-venv \
 && rm -rf /var/lib/apt/lists/*

# dsh plugin 命令会把参数转发给 pnpm，所以必须自备
RUN npm i -g --no-fund --no-audit pnpm@12.6.0

# 容器以 root 运行，挂载进来的目录属主可能不同，这行避免 git 报 dubious ownership
RUN git config --system --add safe.directory '*'

# npm 11 默认不执行依赖的安装脚本；显式放开，避免原生依赖（node-pty 等）静默降级
RUN npm i -g --allow-scripts=node-pty,koffi,@deepseek-ai/dsh-subprocess-local,protobufjs,@google/genai "@deepseek-ai/dsh@${DSH_VERSION}"

EXPOSE 3080
CMD ["dsh", "web", "--no-open", "--port", "3080"]
