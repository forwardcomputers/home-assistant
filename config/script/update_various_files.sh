#!/bin/bash

function get_file {
  DOWNLOAD_PATH=${2}?raw=true
  FILE_NAME=$1
  if [ "${FILE_NAME:0:1}" = "/" ]; then
  SAVE_PATH=$FILE_NAME
  else
  SAVE_PATH=$3$FILE_NAME
  fi
  TMP_NAME=${1}.tmp
  echo "Getting $1"
  # wget $DOWNLOAD_PATH -q -O $TMP_NAME
  curl -s -q -L -o $TMP_NAME $DOWNLOAD_PATH
  rv=$?
  if [ $rv != 0 ]; then
  rm $TMP_NAME
  echo "Download failed with error $rv"
  exit
  fi
  diff ${SAVE_PATH} $TMP_NAME &>/dev/null
  if [ $? == 0 ]; then
  echo "File up to date."
  rm $TMP_NAME
  return 0
  else
  mv $TMP_NAME ${SAVE_PATH}
  if [ $1 == $0 ]; then
    chmod u+x $0
    echo "Restarting"
    $0
    exit $?
  else
    return 1
  fi
  fi
}

function get_file_and_gz {
  get_file $1 $2 $3
  r1=$?
  get_file ${1}.gz ${2}.gz $3
  r2=$?
  if (( $r1 != 0 || $r2 != 0 )); then
  return 1
  fi
  return 0
}

function check_dir {
  if [ ! -d $1 ]; then
  read -p "$1 dir not found. Create? (y/n): [n] " r
  r=${r:-n}
  if [[ $r == 'y' || $r == 'Y' ]]; then
    mkdir -p $1
  else
    exit
  fi
  fi
}

if [ ! -f configuration.yaml ]; then
  echo "There is no configuration.yaml in current dir. 'update.sh' should run from Homeassistant config dir"
  read -p "Are you sure you want to continue? (y/n): [n] " r
  r=${r:-n}
  if [[ $r == 'n' || $r == 'N' ]]; then
  exit
  fi
fi

check_dir "custom_components"
get_file sun.py https://github.com/pnbruckner/homeassistant-config/blob/master/custom_components/sun.py custom_components/
get_file custom_updater.py https://github.com/custom-components/custom_updater/blob/master/custom_components/custom_updater.py custom_components/

check_dir "custom_components/media_player"
get_file firetv.py https://github.com/JeffLIrion/homeassistant_native_firetv/blob/master/media_player/firetv.py custom_components/media_player/
get_file alexa.py https://github.com/keatontaylor/custom_components/blob/master/media_player/alexa.py custom_components/media_player/

check_dir "www/lovelace"
get_file card-tools.js https://github.com/thomasloven/lovelace-card-tools/blob/master/card-tools.js www/lovelace/
get_file compact-custom-header.js https://github.com/maykar/compact-custom-header/blob/master/compact-custom-header.js www/lovelace/
get_file custom-weather-card-chart.js https://github.com/sgttrs/lovelace-weather-card-chart/blob/master/custom-weather-card-chart.js www/lovelace/
get_file fold-entity-row.js https://github.com/thomasloven/lovelace-fold-entity-row/blob/master/fold-entity-row.js www/lovelace/
get_file monster-card.js https://github.com/ciotlosm/custom-lovelace/blob/master/monster-card/monster-card.js www/lovelace/
get_file slider-entity-row.js https://github.com/thomasloven/lovelace-slider-entity-row/blob/master/slider-entity-row.js www/lovelace/
get_file secondaryinfo-entity-row.js https://github.com/MizterB/lovelace-secondaryinfo-entity-row/blob/master/secondaryinfo-entity-row.js www/lovelace/
get_file simple-thermostat.min.js https://github.com/nervetattoo/simple-thermostat/releases/download/0.14.0/simple-thermostat.min.js www/lovelace/
get_file tracker-card.js https://github.com/custom-cards/tracker-card/blob/master/tracker-card.js www/lovelace/
