#!/bin/bash

echo "Listing Kernel files..."

echo "Creating cscope DB..."
/usr/bin/cscope -b -q -k

echo "Moving in right place..."
rm -f cscope.files
rm -rf ../cscope
mkdir ../cscope
mv cscope.* ../cscope

echo "Done"

exit 0
