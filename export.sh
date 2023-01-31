#!/bin/bash

cd `dirname $0`

marp --pdf --allow-local-files --theme common.css slide.md
