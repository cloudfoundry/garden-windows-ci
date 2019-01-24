set -e
source ~/.bash_profile

box_upload_stemcell () {
	# download the stemcell from one of the following:
	# - pivnet
	# - s3://bosh-windows-stemcells-private/ (lpass username: cloud-foundry-aws-billing+BOSH_Windows)

	local stemcell="$1"
	local os_version=$(echo $stemcell | grep -Po 'windows\K\d+')
	local stemcell_version=$(echo $stemcell | grep -Po 'bosh-stemcell-\K[^-]+')
	local stemcell_dir="/home/pivotal/workspace/vmfiles/stemcells"
	local target_stemcell="$stemcell_dir/light-$(basename $stemcell)"
	bosh_target dev-box

	local existing_stemcell=$(bosh stemcells | grep -o $stemcell_version)
	if [ "$existing_stemcell" == "$stemcell_version" ]; then
		echo "*** Stemcell already uploaded"
		exit 0
	fi

	# repack-stemcell
	if [ -f $target_stemcell ]; then
		echo "*** Light stemcell already available"
	else
		echo "*** Repacking stemcell into light-stemcell"
		stemcell_inspect=$(bosh inspect-local-stemcell --json $stemcell)
		cloud_properties=$(echo $stemcell_inspect | jq -c '.Tables[0].Rows[0] | {name: .name, version: .version}')
		bosh repack-stemcell --empty-image --cloud-properties="$cloud_properties" $stemcell $target_stemcell
	fi

	# upload-stemcell
	echo "*** Uploading light-stemcell..."
  bosh upload-stemcell $target_stemcell
	echo "*** Done!"
}




box_upload_stemcell "/home/pivotal/workspace/vmfiles/stemcells/bosh-stemcell-1803.2-vsphere-esxi-windows1803-go_agent.tgz"
