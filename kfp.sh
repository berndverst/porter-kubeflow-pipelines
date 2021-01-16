#!/usr/bin/env bash
set -euo pipefail

uploadpipeline() {
  if [ -z "$PIPELINEDESCRIPTION" ]
  then
    out=$(kfp pipeline upload -p "$PIPELINENAME" /root/pipeline.tar.gz 2>&1)
    exitcode=$?
  else
    out=$(kfp pipeline upload -p "$PIPELINENAME" -d "$PIPELINEDESCRIPTION" /root/pipeline.tar.gz 2>&1)
    exitcode=$?
  fi
  # Ignore specific error
  if [[ $out == *"Parser must be a string or character stream, not dict"* ]];
  then
    echo "Pipeline created successfully: $PIPELINENAME"
    return 0
  else
    if [[ $out == *"already exist. Please specify a new name"* ]];
    then
      echo "Pipeline name already in use: $PIPELINENAME"
      return 1
    fi
  fi
  echo "$out"
  return $exitcode
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
  PIPELINEID=$(kfp pipeline list | grep "$PIPELINENAME" | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print $2}')
  if [ -z "$EXPERIMENTNAME"]
  then
    EXPERIMENTID=$(kfp experiment list | grep "Default" | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print $2}')
  else
    EXPERIMENTID=$(kfp experiment list | grep "$EXPERIMENTNAME" | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print $2}')
  fi
  kfp run submit -e "$EXPERIMENTID" -r "$RUNNAME" -p "$PIPELINEID"
}

# Call the requested function and pass the arguments as-is
"$@"
