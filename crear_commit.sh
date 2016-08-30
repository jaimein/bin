#!/bin/bash

git add .
read -p "Comentario del commit" com
git commit -m "$com"
