#!/bin/bash

echo "Listing Kernel files..."

find $PWD                                 \
-path "$PWD/arch/*" -prune -o             \
-path "$PWD/tmp*" -prune -o               \
-path "$PWD/Documentation*" -prune -o     \
-path "$PWD/scripts*" -prune -o           \
-name "*.[chxsS]" -print > cscope.files

find "$PWD/arch/arm/include/"             \
"$PWD/arch/arm/kernel/"                   \
"$PWD/arch/arm/common/"                   \
"$PWD/arch/arm/boot/"                     \
"$PWD/arch/arm/lib/"                      \
"$PWD/arch/arm/mm/"                       \
"$PWD/arch/arm/mach-omap2/"               \
"$PWD/arch/arm/plat-omap/"                \
-name "*.[chxsS]" -print >> cscope.files

echo "Creating cscope DB..."
/usr/bin/cscope -b -q -k

echo "Moving in right place..."
rm -f cscope.files
rm -Rf ../cscope
mkdir ../cscope
mv cscope.* ../cscope

echo "Done"

exit 0
