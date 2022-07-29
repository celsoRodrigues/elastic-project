#!/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/install_lib/install_functions.sh

a_flag=''
i=''
u=""
verbose='false'

print_usage() {
  printf "Usage: ...\n"
}

while getopts 'auci:v' flag; do
  case "${flag}" in
    a) install_all 
       exit 0 ;;
    c) install_core 
       exit 0 ;;
    u) uninstall_all 
       exit 0 ;;   
    i) i="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [[ -z ${i} ]]; then
    echo "package name is empty"
    exit 1
fi

    case "${i}" in
    elastic | el)      install_elastic ;;
    airflow | air)     install_airflow ;;
    csi-s3  | csi)     install_csi_s3 ;;
    ingress | ing)     install_ingress ;;
    *) echo "Could not install the pkg. "
       exit 1 ;;
  esac


