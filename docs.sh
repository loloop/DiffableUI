#!/bin/bash

# Build and open DiffableUI documentation

echo "Building documentation..."
xcodebuild docbuild -scheme DiffableUI -derivedDataPath .build

if [ $? -eq 0 ]; then
    echo "Documentation built successfully!"
    echo "Opening documentation..."
    open .build/Build/Products/Debug/DiffableUI.doccarchive
else
    echo "Documentation build failed!"
    exit 1
fi