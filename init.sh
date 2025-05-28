#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y git redis

wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt-get install -y xfonts-75dpi
sudo apt install -y ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb
wkhtmltoimage --version


