set -e
source ~/.bash_profile

box_upload_stemcell () {
  local stemcell_version="$1"

  local stemcell_dir="/home/pivotal/workspace/vmfiles/stemcells"

  # TODO: need to make sure the pivnet cli is installed (can be installed from https://github.com/pivotal-cf/pivnet-cli/releases and moved to /usr/local/bin)
  # download stemcell
  local stemcell_already_downloaded=$(ls $stemcell_dir | grep $stemcell_version)
  if [ "$stemcell_already_downloaded" == $stemcell_version ]; then
    echo "*** Stemcell already downloaded"
  else
    echo "*** Downloading stemcell"
    pivnet login --api-token=$(lpass show "Pivotal Network - Greenhouse" --notes | jq -r .pivnet_refresh_token)
    pivnet --verbose download-product-files -p stemcells-windows-server-internal -r $stemcell_version -g "*.tgz" -d $stemcell_dir
  fi

  local original_stemcell="$stemcell_dir/$(ls $stemcell_dir | grep $stemcell_version | grep -v "light")"
  local target_stemcell="$stemcell_dir/light-$(basename $original_stemcell)"
  echo "!!!! $original_stemcell"
  echo "!!!! $target_stemcell"

  bosh_target dev-box

  local stemcell_already_exists=$(bosh stemcells | grep -o $stemcell_version)
  if [ "$stemcell_already_exists" == "$stemcell_version" ]; then
  	echo "*** Stemcell already uploaded"
  	exit 0
  fi

  # repack-stemcell
  if [ -f $target_stemcell ]; then
  	echo "*** Light stemcell already available"
  else
  	echo "*** Repacking stemcell into light-stemcell"
  	local stemcell_inspect=$(bosh inspect-local-stemcell --json $original_stemcell)
  	local cloud_properties=$(echo $stemcell_inspect | jq -c '.Tables[0].Rows[0] | {name: .name, version: .version}')
  	bosh repack-stemcell --empty-image --cloud-properties="$cloud_properties" $original_stemcell $target_stemcell
  fi

  # upload-stemcell
  echo "*** Uploading light-stemcell"
  bosh upload-stemcell $target_stemcell
  echo "*** Done!"
}

box_upload_stemcell "1803.4"
