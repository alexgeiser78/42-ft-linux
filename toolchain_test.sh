#!/bin/bash
# =========================================
# Script: toolchain_test.sh
# Goal: Test GCC toolchain and libraries
# =========================================

set -e

# Test C file
cat > hello.c << "EOF"
#include <stdio.h>
int main(void) {
    printf("Toolchain is working!\n");
    return 0;
}
EOF

# Compile
gcc hello.c -o hello

# Run
./hello

# Cleanup
rm -f hello.c hello
echo "==> Toolchain test passed successfully!"
