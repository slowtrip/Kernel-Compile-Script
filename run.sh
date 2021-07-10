#Kernel-Compiling-Script

#!/bin/bash
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST="R-A-D-E-O-N"
export KBUILD_BUILD_USER="K A R T H I K"
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Set Date
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")

TC_DIR="/home/edmmyrage/Kernel"
MPATH="$TC_DIR/clang/bin/:$PATH"
rm -f out/arch/arm64/boot/Image.gz-dtb
make O=out vendor/perf_defconfig
PATH="$MPATH" make -j16 O=out \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    LD=ld.lld \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CC=clang \
        AR=llvm-ar \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip
        2>&1 | tee error.log

git clone https://android.googlesource.com/platform/system/libufdt scripts/ufdt/libufdt
python2 scripts/ufdt/libufdt/utils/src/mkdtboimg.py create out/arch/arm64/boot/dtbo.img --page_size=4096 out/arch/arm64/boot/dts/qcom/sm6150-idp-overlay.dtbo

cp out/arch/arm64/boot/Image.gz-dtb /home/edmmyrage/Kernel/Anykernel
cp out/arch/arm64/boot/dtbo.img /home/edmmyrage/Kernel/Anykernel
cd /home/edmmyrage/Kernel/Anykernel
if [ -f "Image.gz-dtb" ]; then
    zip -r9 RyZeN+-violet-R-"$DATE".zip"* -x .git README.md *placeholder
cp /home/edmmyrage/Kernel/Anykernel/RyZeN+-violet-R-"$DATE".zip /home/edmmyrage/Kernel
rm /home/edmmyrage/Kernel/Anykernel/Image.gz-dtb
rm /home/edmmyrage/Kernel/Anykernel/RyZeN+-violet-R-"$DATE".zip

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

    echo "Build success!"
else
    echo "Build failed!"
fi
