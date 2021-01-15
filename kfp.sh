#!/usr/bin/env bash
set -euo pipefail

uploadpipeline()
  if [ -z "$PIPELINEDESCRIPTION" ]
  then
    kfp pipeline upload -p "$PIPELINENAME" /root/pipeline.tar.gz
  else
    kfp pipeline upload -p "$PIPELINENAME" -d "$PIPELINEDESCRIPTION" /root/pipeline.tar.gz
  fi
}

createexperiment() {
  if [ -z "$EXPERIMENTDESCRIPTION"]
  then
    kfp experiment create "$EXPERIMENTNAME"
  else
    kfp experiment create -d "$EXPERIMENTDESCRIPTION" "$EXPERIMENTNAME"
  fi
}

runpipeline() {
  export PIPELINEID=$(kfp pipeline list | grep "$PIPELINENAME" | cut -d'|' -f2)
  if [ -z "$EXPERIMENTNAME"]
  then
    export EXPERIMENTID=kfp experiment list | grep "$EXPERIMENTNAME" | cut -d'|' -f2
    kfp run submit -e "$EXPERIMENTID" -r "$RUNNAME" -p "$PIPELINEID" 
  else
    kfp run submit -r "$RUNNAME" -p "$PIPELINEID"
  fi
}

# Call the requested function and pass the arguments as-is
"$@"
