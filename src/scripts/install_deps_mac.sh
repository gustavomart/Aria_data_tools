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

# Install system deps with Homebrew
# Toolchains
brew install cmake doxygen
# VRS and Pybind11 dependencies
brew install boost sophus cereal googletest glog glew lz4 zstd xxhash libpng jpeg-turbo
# Installing pybind11
pip3 install pybind11[global] numpy

# Install and compile libraries
sh ./install_compile_3rd_party.sh
