#!/bin/bash

# Script to download files from RCSB http file download services.
# Use the -h switch to get help on usage.

# https://models.rcsb.org/v1/4hhb/ligand?label_comp_id=HEM&encoding=sdf&copy_all_categories=false&download=false

if ! command -v curl &> /dev/null
then
    echo "'curl' could not be found. You need to install 'curl' for this script to work."
    exit 1
fi

PROGNAME=$0
BASE_URL="https://models.rcsb.org/v1"

usage() {
  cat << EOF >&2
Usage: $PROGNAME -f <file> [-o <dir>] [-l <ligand>]

 -f <file>:   the input file containing a comma-separated list of PDB ids
 -o  <dir>:   the output dir, default: current dir
 -l <ligand>: the ligand name present in the protein
 -s       :   download an sdf file for each PDB id

EOF
  exit 1
}

download() {
  url="$BASE_URL/"$1"/ligand?label_comp_id="$3"&encoding=sdf&copy_all_categories=false&download=false"
  out=$2/$1_$3.sdf
  echo "Downloading $url to $out"
  curl -s -f "$url" -o $out || echo "Failed to download $url"
}

listfile=""
outdir="."
ligand=""
sdf=false
while getopts f:o:l: o
do
  case $o in
    (f) listfile=$OPTARG;;
    (o) outdir=$OPTARG;;
    (l) ligand=$OPTARG;;
    (*) usage
  esac
done
shift "$((OPTIND - 1))"

if [ "$listfile" == "" ]
then
  echo "Parameter -f must be provided"
  exit 1
fi
contents=$(cat $listfile)

# see https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash#tab-top
IFS=',' read -ra tokens <<< "$contents"

for token in "${tokens[@]}"
do

  download $token $outdir $ligand

done
