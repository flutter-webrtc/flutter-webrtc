#!/bin/sh

find . -type f -name "*.cc" -o -type f -name "*.h" -o -type f -name "*.m" -o -type f -name "*.mm" | xargs clang-format -style=file -i
