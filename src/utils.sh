health_check() {
  echo "Semantic Version Action (SVA) is Ok"
}

config_github_token() {
  if [[ $(git config user.email) == '41898282+github-actions[bot]@users.noreply.github.com'* ]]; then
    echo "Already config github token"
  else
    REMOTE_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
    git remote add publisher $REMOTE_REPO || true
    git config user.name "GitHub Actions"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  fi
}
