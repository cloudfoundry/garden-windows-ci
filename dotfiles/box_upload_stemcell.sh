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
	if [ -f $target_stemcell ]; then
		echo "It's already there"
		exit 0
	fi

	bosh_target dev-box
	cmd="bosh repack-stemcell --empty-image \
		--cloud-properties=\"{\"name\": \"bosh-vsphere-esxi-windows${os_version}-go_agent\", \
		\"version\": \"${stemcell_version}\"}\" $stemcell $target_stemcell"
	eval $cmd
	echo "hi"
}





box_upload_stemcell "/home/pivotal/workspace/vmfiles/stemcells/bosh-stemcell-1803.2-vsphere-esxi-windows1803-go_agent.tgz"
