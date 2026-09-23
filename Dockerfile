FROM node:24-bookworm-slim
RUN npm i -g @deepseek-ai/dsh
EXPOSE 3080
CMD ["dsh", "web", "--no-open", "--port", "3080"]
