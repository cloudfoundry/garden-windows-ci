#!/bin/bash

set -eu

search_string="" # required
pipeline_job=""
build_count=1000
concourse_url="https://garden-windows.ci.cf-app.com"
while getopts s:c:j:u:h o; do
  case $o in
    s)
      search_string="${OPTARG}"
      ;;
    c)
      build_count="${OPTARG}"
      ;;
    j)
      pipeline_job="${OPTARG}"
      ;;
    h)
      help "$(dirname ${0})" "$(basename $0 .sh)"
      exit 0
      ;;
    *)
      help "$(dirname ${0})" "$(basename $0 .sh)"
      exit 1
      ;;
  esac
done

if [ -z "${search_string}" ]; then
  help "$(dirname ${0})" "$(basename $0 .sh)"
  exit 1
fi

builds_output="$(fly -t garden-windows builds -c "${build_count}" -j "${pipeline_job}")"
first_build_time="$(tail -n1 <<< "${builds_output}" | awk '{ print $5 }')"
IFS=$'\n'
builds=(${builds_output})

total_matches=0
total_builds=0
for build in "${builds[@]}"; do
  build_id="$(awk '{ print $1 }' <<< "${build}")"
  pipeline_and_job="$(awk '{ print $2 }' <<< "${build}")"
  build_no="$(awk '{ print $3 }' <<< "${build}")"
  state="$(awk '{ print $4 }' <<< "${build}")"
  start_time="$(awk '{ print $5 }' <<< "${build}")"

  if [ "${state}" == "failed" ]; then
    echo "looking at build: '${build_no}'"

    total_builds="$(( total_builds + 1 ))"

    if fly -t garden-windows watch -b "${build_id}"| sed 's/\x1b\[[0-9;]*m//g' | grep -i "${search_string}"; then
      echo "Job '${pipeline_and_job}' build ${build_id} at ${start_time} matches (${concourse_url}/builds/${build_id})"
      total_matches="$(( total_matches + 1 ))"
    fi
  fi
done

echo "Found ${total_matches} matches out of ${total_builds} total failed builds"
