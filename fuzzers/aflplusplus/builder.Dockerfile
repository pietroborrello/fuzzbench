# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG parent_image=gcr.io/fuzzbench/base-builder
FROM $parent_image

# Download and compile afl++ (v2.60c).
# Build without Python support as we don't need it.
# Set AFL_NO_X86 to skip flaky tests.
RUN git clone https://github.com/vanhauser-thc/AFLplusplus.git /afl && \
    cd /afl && \
    git checkout 842cd9dec3c4c83d660d96dcdb3f5cf0c6e6f4fb && \
    AFL_NO_X86=1 make PYTHON_INCLUDE=/

# Use afl_driver.cpp from LLVM as our fuzzing library.
RUN apt-get update && \
    apt-get install wget -y && \
    wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /afl/afl_driver.cpp && \
    clang -Wno-pointer-sign -c /afl/llvm_mode/afl-llvm-rt.o.c -I/afl && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /afl/afl_driver.cpp && \
    ar r /libAFL.a *.o
