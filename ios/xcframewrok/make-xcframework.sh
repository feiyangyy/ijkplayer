#! /usr/bin/env bash
#
# Copyright (C) 2024 Matt Reach<qianlongxu@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

set -e

function get_inputs_with_path()
{
    fmwk="$1"
    inputs=""
    if [[ -d $fmwk ]]; then
        inputs="$inputs -framework $fmwk"
    fi
    fmwk_dsym="${fmwk}.dSYM"
    if [[ -d $fmwk_dsym ]]; then
        inputs="$inputs -debug-symbols $(cd $fmwk_dsym; DIRNAME=$(dirname pwd); cd "$DIRNAME"; pwd)"
    fi
    echo "$inputs"
}

function get_inputs()
{
    # add iOS
    ios_inputs=$(get_inputs_with_path '../IJKMediaPlayer/Release-iphoneos/IJKMediaFramework.framework')
    # add iOS Simulator
    ios_sim_inputs=$(get_inputs_with_path '../IJKMediaPlayer/Release-iphonesimulator/IJKMediaFramework.framework')
    
    echo "${ios_inputs} ${ios_sim_inputs}"
}

function do_make_xcframework() {
    inputs="$(get_inputs)"
    output=IJKMediaFramework.xcframework
    rm -rf "$output"
    echo "xcodebuild -create-xcframework $inputs -output $output"
    xcodebuild -create-xcframework $inputs -output $output
}

do_make_xcframework