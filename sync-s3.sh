#!/bin/bash

cd build/
aws s3 sync . s3://hexhexhex/ --acl public-read
