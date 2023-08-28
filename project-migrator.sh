#!/bin/bash

if [ -z "$workDir" ]; then
  workDir=$(mktemp -d -t projectConvertXXX)
fi
if [ -z "$engineUrl" ]; then
  engineUrl="https://developer.axonivy.com/permalink/10.0.7/axonivy-engine.zip"
fi

downloadEngine(){
  if ! [ -d "${workDir}/engine" ]; then
    mkdir -p "${workDir}/engine"  
  fi
}

raiseProject() {
  gitDir=$(pwd)
  gitName=$(basename ${gitDir})
  echo "Searching 4 products in ${gitDir}"
  projects=()
  for ivyPref in $(find ${gitDir} -name "product.json"); do
    sed -i 's/"installers"/"$schema": "https:\/\/json-schema.axonivy.com\/market\/10.0.0\/product.json",\n    "installers"/g' $ivyPref 
    projects+=("juhu")
  done

  if [ ${#projects[@]} -gt 0 ]; then
    git add . #include new+moved files!
    git commit -m "introduce product.schema"
  else
    echo "No projects found in ${gitDir}"
  fi
}
