FROM ubuntu:22.04

#아래 쉘스크립트 에러 방지 - .bashrc 관련에서 에러
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set environment variables for configuration
ENV PYTHON_VERSION=3.10 \
    PYTHONUNBUFFERED=1

# 저장소를 mirror.kakao.com 로 변경
RUN sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# Update the package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 압축파일을 복사하고 해제하면 용량이 7GB정도 늘어남
#COPY pip_install.tar /rebel/pip_install.tar
#RUN tar -xf /rebel/pip_install.tar -C /rebel

RUN mkdir -p /rebel/
COPY offline_install/ /rebel/offline_install/

RUN pip install --no-cache-dir \
    /rebel/offline_install/rebel-compiler/rebel_compiler-0.7.3-cp310-cp310-manylinux_2_28_x86_64.whl -f /rebel/offline_install/rebel-compiler --no-index && \
    pip install --no-cache-dir \
    /rebel/offline_install/optimum-rbln/optimum_rbln-0.7.3.post2-py3-none-any.whl -f /rebel/offline_install/optimum-rbln --no-index && \
    pip install --no-cache-dir \
    /rebel/offline_install/vllm/vllm-0.8.3-cp38-abi3-manylinux1_x86_64.whl -f /rebel/offline_install/vllm --no-index && \
    pip install --no-cache-dir \
    /rebel/offline_install/vllm-rbln/vllm_rbln-0.7.3-py3-none-any.whl -f /rebel/offline_install/vllm-rbln --no-index

COPY rbln-model-zoo /rbln-model-zoo/huggingface/

RUN rm -rf /rebel