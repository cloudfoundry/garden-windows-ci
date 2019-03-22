This doc deals with how to update go version in a bosh release that sources it from [golang-release](https://github.com/bosh-packages/golang-release).

The following details how you would update winc-release from go-1.11 to go-1.12:

1. `git clone https://github.com/bosh-packages/golang-release ~/workspace/golang-release`

2. `cd ~/workspace/winc-release`

3. checkout develop

4. `bosh vendor-package golang-1.12-windows ~/workspace/golang-release`
This will upload the new golang blob to the blob store, create a new package named `golang-1.12-windows` in `packages`, and `.final_builds`

5. `rm -rf packages/golang-1.1-windows` && `rm -rf .final_builds/packages/golang-1.11-windows`

6. Replaces all references to the old golang package in packages with the new one (`grep -rl "golang-1.11-windows" ./packages | xargs sed -i "s/golang-1.11-windows/golang-1.12-windows/"`)

7. `bosh create-release --tarball /tmp/tmp.tgz --force` must work fine.

7. Stage the changes to `packages/` and `.final_builds/`, and `git push`.

**TODO**: Automate this
