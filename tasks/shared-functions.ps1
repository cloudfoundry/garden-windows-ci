# work around https://github.com/golang/go/issues/27515
function updateDirIfSymlink {
  $dir = $args[0]
  $linkType = (get-item $dir).LinkType
  if ($linkType -ne $null) {
    # if linkType is a symbolic link, update to the actual target
    $dir = (get-item $dir).Target
  }
  return $dir
}
