#!/bin/bash -eu

source "${HOME}/workspace/garden-windows-ci/bin/bash_helpers"

function main() {
  local stemcell_version
  stemcell_version="${1:?must provide stemcell version}"

  bosh_target dev-box

  local exists=$(bosh stemcells | grep -o $stemcell_version)
  if [ "$exists" == "$stemcell_version" ]; then
    echo "*** Stemcell already uploaded to dev-box bosh director - Done!"
    exit 0
  fi

  local stemcell_dir="/home/pivotal/workspace/vmfiles/stemcells"

  # TODO: need to make sure the pivnet cli is installed (can be installed from https://github.com/pivotal-cf/pivnet-cli/releases and moved to /usr/local/bin)
  local downloaded=$(ls $stemcell_dir | grep $stemcell_version)
  if [ "$downloaded" == $stemcell_version ]; then
    echo "*** Stemcell already available in $stemcell_dir"
  else
    echo "*** Downloading stemcell from pivnet"
    pivnet login --api-token=$(lpass show "Pivotal Network - Greenhouse" --notes | jq -r .pivnet_refresh_token)
    pivnet --verbose download-product-files -p stemcells-windows-server-internal -r $stemcell_version -g "*.tgz" -d $stemcell_dir
  fi

  local original_stemcell="$stemcell_dir/$(ls $stemcell_dir | grep $stemcell_version | grep -v "light")"
  local target_stemcell="$stemcell_dir/light-$(basename $original_stemcell)"

  if [ -f $target_stemcell ]; then
    echo "*** Light stemcell already available in $stemcell_dir"
  else
    echo "*** Repacking stemcell into light-stemcell"
    local stemcell_inspect=$(bosh inspect-local-stemcell --json $original_stemcell)
    local cloud_properties=$(echo $stemcell_inspect | jq -c '.Tables[0].Rows[0] | {name: .name, version: .version}')
    bosh repack-stemcell --empty-image --cloud-properties="$cloud_properties" $original_stemcell $target_stemcell
  fi

  echo "*** Uploading light-stemcell to dev-box bosh director"
  bosh upload-stemcell $target_stemcell
  echo "*** Done!"
}

main "$@"
