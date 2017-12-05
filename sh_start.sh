#!/bin/bash

pm2 delete aifirst-api
rm ./upload/*
pm2 start pm2.json

