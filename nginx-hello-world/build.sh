#!/bin/bash

kubectl create configmap hello-world --from-file index.html

kubectl apply -f helloworld.yml
