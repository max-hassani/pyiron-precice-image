#!/bin/bash
git clone https://github.com/matbinder/precice-example.git
cp -r "$HOME"/precice-example/*.ipynb "$HOME"/
rm -r "$HOME"/precice-example
rm "$HOME"/*.yml
rm "$HOME"/Dockerfile
rm "$HOME"/*.sh
