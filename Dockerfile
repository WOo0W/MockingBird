FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime
WORKDIR /MockingBird

EXPOSE 8080

COPY . .

RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list \
    && sed -i s@/security.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list

RUN apt clean && apt update && apt install ffmpeg gcc -y 

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip install -r requirements.txt && pip install webrtcvad

CMD ["python", "web.py"]
