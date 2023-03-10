FROM continuumio/anaconda3

WORKDIR /app

RUN git clone https://github.com/Stability-AI/stablediffusion.git

WORKDIR /app/stablediffusion

RUN conda env create -f environment.yaml

RUN echo "conda activate ldm" >> ~/.bashrc

SHELL ["/bin/bash", "--login", "-c"]

RUN conda install pytorch==1.12.1 torchvision==0.13.1 -c pytorch

RUN pip install transformers==4.19.2 diffusers invisible-watermark

RUN pip install -e .

RUN mkdir -p models/ldm/stable-diffusion-2-v1/

RUN wget https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt -O models/ldm/stable-diffusion-2-v1/model.ckpt

RUN export CUDA_HOME=/usr/local/cuda-11.4

RUN conda install -c nvidia/label/cuda-11.4.0 cuda-nvcc

RUN conda install -c conda-forge gcc

RUN conda install -c conda-forge gxx_linux-64==9.5.0

WORKDIR /app

RUN git clone https://github.com/facebookresearch/xformers.git

WORKDIR /app/xformers

RUN git submodule update --init --recursive

RUN pip install -r requirements.txt

RUN pip install -e .

WORKDIR /app

COPY . .

RUN mkdir -p /app/outputs/txt2img

RUN mkdir -p /app/outputs/img2img

RUN pip install -r requirements.txt

ENTRYPOINT ["./entrypoint.sh"]