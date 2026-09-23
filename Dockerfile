FROM node:24-bookworm-slim

# npm 11 默认不执行依赖的安装脚本，而这两个包的原生部件要靠安装脚本生成：
#   @deepseek-ai/dsh-subprocess-local -> 生成 spawn helper
#   node-pty / koffi                  -> 原生 PTY / FFI 预编译件
RUN npm i -g --allow-scripts=node-pty,koffi,@deepseek-ai/dsh-subprocess-local,protobufjs,@google/genai @deepseek-ai/dsh

EXPOSE 3080
CMD ["dsh", "web", "--no-open", "--port", "3080"]
