#!/bin/bash

# Tools Installation
cd $HOME
sudo apt-get update
sudo apt install -y iperf3
sudo apt install -y ffmpeg
sudo apt install -y unzip
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq

# Miniconda Installation
if [[ ! -d  "./miniconda3" ]]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
    bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p $HOME/miniconda3
fi

eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
# Build DDS and environment
git clone https://github.com/zharfanf/dds-zharfanf.git

cd dds-zharfanf/

git checkout edge

yq -i '.dependencies[1] = tensorflow=1.14' conda_environment_configuration.yml

conda env create -f conda_environment_configuration.yml

conda activate dds

# Install libraries for DDS

pip install gdown
pip install pandas
pip install matplotlib
pip install grpcio grpcio-tools
pip install jupyter

# Download dataset
gdown --id 1khK3tPfdqonzpgT_cF8gaQs_rPdBkdKZ
tar xvgf data-set-dds.tar.gz
rm -f data-set-dds.tar.gz
# rm -rf data-set
# mv data-set-cpy data-set

cd workspace
#wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
gdown --id 12kMeCtTEO0RF56BTjeWogT4WsEVEN3CE
cp ./frozen_inference_graph.pb ..


## Build Concierge and environment
cd $HOME
git clone https://github.com/zharfanf/VAP-Concierge.git
cd VAP-Concierge/

git checkout vap-zharfanf
cd src/app/dds-adaptive/
# Download model for dds
#wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
gdown --id 12kMeCtTEO0RF56BTjeWogT4WsEVEN3CE

# Awstream Setup
cd ../awstream-adaptive/
# Download model for awstream
wget http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz
tar xvzf ssd_mobilenet_v2_coco_2018_03_29.tar.gz
cp ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb .


# Migrate Concierge to tmp filesystem with ramdisk installed
# Location: /tmp/ramdisk/VAP-Concierge/
cd $HOME
sudo mkdir /tmp/ramdisk
sudo chmod 777 /tmp/ramdisk
sudo mount -t tmpfs -o size=100g myramdisk /tmp/ramdisk
mv VAP-Concierge/ /tmp/ramdisk/.

echo 'export PATH=$PATH:/home/cc/miniconda3/bin' >> ~/.bashrc
source ~/.bashrc
