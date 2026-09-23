FROM node:24-bookworm-slim

# npm 11 默认不执行依赖的安装脚本；显式放开，避免原生依赖（node-pty 等）静默降级
RUN npm i -g --allow-scripts=node-pty,koffi,@deepseek-ai/dsh-subprocess-local,protobufjs,@google/genai @deepseek-ai/dsh

EXPOSE 3080
CMD ["dsh", "web", "--no-open", "--port", "3080"]
