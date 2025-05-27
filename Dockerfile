FROM ubuntu:22.04

## 저장소 업데이트
RUN sed -i 's/kr.archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list

# Set environment variables for configuration
ENV PYTHON_VERSION=3.10

# Update the package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y python${PYTHON_VERSION} && \
        apt-get install -y python3-pip && \
    apt-get clean

RUN mkdir -p /rebel/
COPY offline_install/ /rebel/offline_install/


RUN pip install /rebel/offline_install/rebel-compiler/rebel_compiler-0.7.3-cp310-cp310-manylinux_2_28_x86_64.whl -f /rebel/offline_install/rebel-compiler --no-index
RUN pip install /rebel/offline_install/optimum-rbln/optimum_rbln-0.7.3.post2-py3-none-any.whl -f /rebel/offline_install/optimum-rbln  --no-index
RUN pip install /rebel/offline_install/vllm/vllm-0.8.3-cp38-abi3-manylinux1_x86_64.whl -f /rebel/offline_install/vllm --no-index
RUN pip install /rebel/offline_install/vllm-rbln/vllm_rbln-0.7.3-py3-none-any.whl -f /rebel/offline_install/vllm-rbln --no-index

COPY rbln-model-zoo /rbln-model-zoo/

RUN rm -rf /rebel
