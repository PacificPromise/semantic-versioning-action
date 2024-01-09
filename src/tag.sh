create_tag() {
  TAG_NAME=$1
  {
    git tag -a $TAG_NAME -m "Release version $TAG_NAME" &&
      git push origin $TAG_NAME
  } || {
    git tag -d $TAG_NAME
  }
}

delete_tag() {
  git tag -d "$1"
  git push --delete origin "$1"
}

remove_all_tag() {
  git fetch --tags
  git push origin --delete $(git tag -l)
  git tag -d $(git tag -l)
}
