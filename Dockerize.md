# 容器化 MockingBird 项目 (Windows)

[项目地址](https://github.com/babysor/MockingBird/blob/main/README-CN.md)

## 部署过程

### 阅读文档

首先打开上述链接阅读一遍文档，并使用 git 把项目仓库下载到本地

按照文档，我们需要执行以下步骤：

### 依赖安装

1. 安装 `pytorch`，这里直接使用docker中现成的镜像，示例选用 `pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime`
2. 在docker容器构建过程中，安装 `ffmpeg`，这里使用 `apt` 安装
3. 在docker容器构建过程中，安装 python 相关依赖

### 更改项目配置

由于项目默认的监听 ip 地址为 `localhost`，而 docker 容器 EXPOSE 时需要绑定到 `0.0.0.0` 才能生效，所以更改 `web/config/default.py`，将 `HOST` 改成 `0.0.0.0`：

```diff
- HOST = 'localhost'
+ HOST = '0.0.0.0'
```

### 准备模型

示例将使用网上下载的模型（文档中第一个），此处提供速度更快的下载链接:

> <https://musetransfer.com/s/yqs8aiqso>（有效期至4月14日）｜【Muse】你有一份文件待查收，请点击链接获取文件

下载文件后，在项目目录下新建文件夹 `synthesizer/saved_models/`，并将下载的文件放入。

## Dockerfile 示例

```dockerfile
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime
WORKDIR /MockingBird

EXPOSE 8080

COPY . .

# 替换为国内源，加速下载
# apt为清华源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list \
    && sed -i s@/security.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list

RUN apt clean && apt update && apt install ffmpeg gcc -y 

# pip为阿里源
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip install -r requirements.txt && pip install webrtcvad

CMD ["python", "web.py"]
```

写好Dockerfile后即可构建容器，耗时较长 (10min左右，看网络环境)，请耐心等待：

```sh
$ docker build . -t mockingbird
```

## 运行容器

> Windows 11 and Windows 10, version 21H2 support running existing ML tools, libraries, and popular frameworks that use NVIDIA CUDA for GPU hardware acceleration inside a WSL instance. <https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl>

使用最新版本的Windows 10/11, 在 WSL 2 上运行，如果有 NVIDIA GPU，可以添加 `--gpus all` 参数，加快数据处理。如果没有独显或者不满足系统要求，无需添加，PyTorch 会使用 CPU 进行计算。

```sh
# 使用 GPU 加速
$ docker run --gpus all -p 8080:8080 -d mockingbird:latest
```

```sh
# 无 GPU 加速
$ docker run -p 8080:8080 -d mockingbird:latest
```

打开浏览器访问 `http://localhost:8080`，可以看到项目的首页。

## Tips

1. 录音并非越长越好，3-8秒即可，尽量保证声音清晰，无噪音。
2. 由于模型为网上下载，模拟的效果可能并不好，图一乐即可。
3. 想要改善效果，可以按文档自己训练模型
