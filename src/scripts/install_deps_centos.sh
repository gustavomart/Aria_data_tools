#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install system deps
# Toolchains
sudo dnf install cmake ninja-build npm doxygen pip
# VRS, Sophus and Pybind11 dependencies
sudo dnf install cereal-devel gtest-devel gmock-devel glog-devel \
                 fmt-devel lz4-devel libzstd-devel xxhash-devel \
                 boost-devel eigen3-devel python3-devel glew-devel \
                 libpng-devel turbojpeg-devel
# Installing pybind11
pip install pybind11[global] numpy

# Install and compile libraries
sh ./install_compile_3rd_party.sh
