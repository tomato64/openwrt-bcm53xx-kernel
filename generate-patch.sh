#!/bin/bash

KERNEL=6.12.74
BRANCH=v25.12.2

rm -rf linux*
rm -rf openwrt
rm -f 00001-openwrt-bcm53xx-kernel*

git clone https://github.com/openwrt/openwrt.git
cd openwrt
git checkout $BRANCH
cd ..

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL.tar.xz
tar xvJf linux-$KERNEL.tar.xz
cd linux-$KERNEL
git init
git add .
git commit -m "init"

# Copy generic files and bcm53xx-specific files
cp -fpR "../openwrt/target/linux/generic/files"/. \
	"../openwrt/target/linux/bcm53xx/files"/. \
	.

# Apply generic patches in order
for patch in ../openwrt/target/linux/generic/backport-6.12/*.patch; do
	patch -p1 < "$patch"
done

for patch in ../openwrt/target/linux/generic/pending-6.12/*.patch; do
	patch -p1 < "$patch"
done

for patch in ../openwrt/target/linux/generic/hack-6.12/*.patch; do
	patch -p1 < "$patch"
done

# Apply bcm53xx-specific patches
for patch in ../openwrt/target/linux/bcm53xx/patches-6.12/*.patch; do
	patch -p1 < "$patch"
done

git add .
git commit -m "openwrt bcm53xx kernel $KERNEL"
git format-patch HEAD~1
mv 0001-openwrt-bcm53xx-kernel-$KERNEL.patch \
   ../00001-openwrt-bcm53xx-kernel-$KERNEL.patch
