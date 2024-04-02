#!/bin/bash

service_name="Apache"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

if systemctl is-active httpd; then
    echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: o serviço está online" >> "/mnt/nfs/gustavo/httpd-online.txt"
else
   echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: o serviço está offline " >> "/mnt/nfs/gustavo/httpd-offline.txt"
fi
