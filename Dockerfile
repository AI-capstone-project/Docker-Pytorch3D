# Use the NVIDIA CUDA image as a base
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Install necessary dependencies
RUN apt-get update -qq && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    g++ \
    git \
    gcc \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and add them to the sudo group
RUN useradd -m -s /bin/bash myuser && echo "myuser:myuser" | chpasswd && adduser myuser sudo


# Download and install Miniconda
ENV CONDA_DIR /opt/miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/Miniconda3-latest-Linux-x86_64.sh
RUN chmod +x /tmp/Miniconda3-latest-Linux-x86_64.sh
RUN /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda
RUN rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Set environment variables for conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Initialize conda
RUN /opt/miniconda/bin/conda init bash
RUN conda update -n base -c defaults conda -y

# Switch to the non-root user
USER myuser

# Set the working directory
WORKDIR /home/myuser/SMPLitex

# Create a conda environment
RUN conda init && conda create -n myenv python=3.10 -y


# Copy the current directory contents into the container at /home/myuser/SMPLitex
COPY --chown=myuser:myuser . .

# start every shell with the conda environment activated
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]

RUN conda install -n myenv pytorch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 pytorch-cuda=12.4 -c pytorch -c nvidia -y

# Temp
RUN conda install -n myenv -c conda-forge yacs -y
RUN conda install -n myenv -c iopath iopath -y
RUN conda install -n myenv pytorch3d -c pytorch3d -y

RUN pip install smplx imageio scipy git+https://github.com/mattloper/chumpy
