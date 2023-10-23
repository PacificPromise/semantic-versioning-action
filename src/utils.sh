health_check() {
  echo "Semantic Version Action (SVA) is Ok"
}

config_github_token() {
  REMOTE_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  git remote add publisher $REMOTE_REPO
  git config user.name bump_version
  git config user.email bump-version@version.com
}
