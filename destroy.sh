#!/bin/bash

trap "cd ../" EXIT

cd terraform && terraform destroy

