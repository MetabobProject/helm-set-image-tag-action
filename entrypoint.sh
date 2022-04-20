#!/bin/bash

set -eu

INPUT_TAG_VALUE=${INPUT_TAG_VALUE//refs\/tags\//}
INPUT_TAG_VALUE=${INPUT_TAG_VALUE//refs\/heads\//}

git config --global --add safe.directory /github/workspace;

if [ "${INPUT_FORCE}" == "true" ]; then
  FORCE_OPT="--force"
else
  FORCE_OPT=""
fi

_update_values() {
  # Take the CSV-submitted list of Values "tag" keys and turn it into an
  # array. For each of these values, we'll go and update the yaml.
  local KEYS_ARR
  IFS=', ' read -r -a KEYS_ARR <<< "$INPUT_TAG_KEYS"

  # Create a single YQ eval string that has all of our keys...
  local EXPR
  EXPR=$(printf "( %s = \"${INPUT_TAG_VALUE}\" )|" "${KEYS_ARR[@]}" | sed 's/.$//') || return 1

  # Use `yq` to create the initial change by inline-modifying the files...
  echo "Setting ${EXPR} in ${INPUT_VALUES_FILES}"...
  yq eval-all "${EXPR}" -i ${INPUT_VALUES_FILES}
}

_update_chart_version() {
  [ -n "${INPUT_BUMP_LEVEL}" ] || return 0
  echo "Bumping chart version... (bump_level: ${INPUT_BUMP_LEVEL})"
  pybump bump --file $(dirname ${INPUT_VALUES_FILES})/Chart.yaml  --level ${INPUT_BUMP_LEVEL}
}

# Be really loud and verbose if we're running in VERBOSE mode
if [ "${INPUT_VERBOSE}" == "true" ]; then
  set -x
fi

_update_values
_update_chart_version


