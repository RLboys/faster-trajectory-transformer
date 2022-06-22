FROM  pytorch/pytorch

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget git libosmesa6-dev libgl1-mesa-glx libglfw3 gcc libglu1-mesa-dev mesa-common-dev && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version
COPY ./ /tt
RUN mv /tt/mujoco_for_root /root/.mujoco
ENV LD_LIBRARY_PATH_COPY=$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mujoco200/bin
ENV PYTHONPATH=/tt:$PYTHONPATH
RUN --mount=type=cache,target=/opt/conda/pkgs conda env create -f /tt/environment.yml
SHELL ["conda", "run", "-n", "fast_trajectory_test", "/bin/bash", "-c"]
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH_COPY:/root/.mujoco/mujoco210/bin
RUN pip uninstall mujoco-py -y
RUN pip install mujoco-py wandb omegaconf stable_baselines3 
RUN pip install -e git+https://github.com/aravindr93/mjrl@3871d93763d3b49c4741e6daeaebbc605fe140dc#egg=mjrl
RUN pip install torch==1.10.2
WORKDIR /tt
ENTRYPOINT  ["conda", "run", "--no-capture-output", "-n", "fast_trajectory_test", "bash"]
# PYTHONPATH=:./:$PYTHONPATH python scripts/eval.py --config="configs/eval_base.yaml" --device="cpu" --seed="42" checkpoints_path="pretrained/halfcheetah" beam_context=5 beam_steps=5  beam_width=32
# source /root/miniconda3/etc/profile.d/conda.sh
# 
