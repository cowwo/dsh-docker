# dsh-docker

DeepSeek Harness（`dsh`）Web GUI 的**非官方**容器镜像：一个 Dockerfile，5 行。

## 构建

```bash
docker build -t dsh .
```

## 运行

```bash
docker run --rm -it --network host -e DEEPSEEK_API_KEY=你的key dsh
```

容器启动后日志会打印一行：

```
dsh web: http://127.0.0.1:3080/?token=xxxx
```

浏览器打开这个链接即可。

想保留会话、设置与技能（重启不丢），加一个卷：

```bash
docker run --rm -it --network host \
  -e DEEPSEEK_API_KEY=你的key \
  -v ~/dsh-home:/root/.dsh \
  dsh
```

要在容器里干活的代码目录，也挂进去：

```bash
  -v ~/my-project:/workspace -w /workspace
```

## 三条必须知道的事

| 事项 | 说明 |
|---|---|
| 必须 `--network host` | dsh 为安全只监听容器内 `127.0.0.1`，`-p 3080:3080` 端口映射连不通 |
| 数据默认不持久 | 加 `-v ~/dsh-home:/root/.dsh` 才会保留会话与设置 |
| 容器内是 root | 挂载目录会变成 root 属主；介意的话自行在镜像里加非 root 用户 |

## 说明

- 本项目为非官方镜像，与 DeepSeek 官方无关。
- 上游项目：<https://github.com/deepseek-ai/deepseek-harness>（MIT）
- npm 包：`@deepseek-ai/dsh`
