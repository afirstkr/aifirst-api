#!/bin/bash

coffee -c .
pm2 delete aifirst-api
rm ./upload/*
pm2 start pm2.json
pm2 logs 

