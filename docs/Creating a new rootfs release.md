### Background
When you create a new windows rootfs release from the copy of an older release (e.g. when we created [windows2019fs-release](https://github.com/cloudfoundry/windows2019fs-release) from [windows1803fs-release](https://github.com/cloudfoundry/windows1803fs-release)), you must remember to make a few changes so the versioning doesn't get messed up.

### Things to note

1. Make sure the submodules are NOT copied over as source.

1. `config/blobs.yml` requires `size` and `sha` of the rootfs blob. To add this blob metadata (for offline releases only):

		* `touch fake-blob`
			
		* `bosh add-blob fake-blob <blobs path>`
			
		* `./scripts/create-release`
			
		* Look in the `blobs` dir to find the output tgz from the create-release script
			
		* Calculate sha1sum and size

1. There has to be a `windowsXXXXfs` S3 bucket that contains an `image-version` file, and a `windowsfs-release-version` file. The `image-version file` should contain the IMAGE_TAG from the [windows2016fs repository](https://github.com/cloudfoundry/windows2016fs), and the `windowsfs-release-version` file should contain the value `0.0.0`.

1. Concourse has a caching mechanism for resources of type `semver`. For the resource `windowsfs-release-version` of the rootfs-release pipeline, make sure that it starts from `0.0.0` by turning off any previously cached resources. e.g. `number 2.1.0` should be turned off. If you're shipping a release and you don't turn off cached resources (if any), it will create the new release with version number (`prev_cached_semver_version` + 1) instead of starting from `0.0.0`.
