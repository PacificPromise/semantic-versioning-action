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
  git fetch --all --tags
  git push origin --delete $(git tag -l)
  git tag -d $(git tag -l)
}
health_check() {
  echo "Semantic Version Action (SVA) is Ok"
}

config_github_token() {
  REMOTE_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  git remote add publisher $REMOTE_REPO
  git config user.name "GitHub Actions"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
}
split_version() {
  TAG_NAME=$1
  VERSION_TYPE=$2 # full, all, major, minor, patche, increment_patche, build, increment_build

  VERSION_NAME_PATH=($(grep -oE '[a-z,0-9,-.+]*' <<<"$TAG_NAME"))
  ARRAY_SIZE=${#VERSION_NAME_PATH[@]}
  VERSION=${VERSION_NAME_PATH[$((ARRAY_SIZE - 1))]}
  VERSION_ARRAY=($(grep -oE '[0-9]*' <<<"$VERSION"))

  case $VERSION_TYPE in
  all)
    echo ${VERSION}
    ;;
  full)
    echo "${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${VERSION_ARRAY[2]}"
    ;;
  increment_patche)
    PATCHE_WILL_BUILD=$((VERSION_ARRAY[2] + 1))
    echo "${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCHE_WILL_BUILD}"
    ;;
  major)
    echo ${VERSION_ARRAY[0]}
    ;;
  minor)
    echo ${VERSION_ARRAY[1]}
    ;;
  patche)
    echo ${VERSION_ARRAY[2]}
    ;;
  build)
    echo ${VERSION_ARRAY[3]}
    ;;
  increment_build)
    echo ${VERSION_ARRAY[3]} + 1 | bc
    ;;
  esac
}

increment() {
  git fetch --all --tags
  STAGE=$1
  if ! [ "$STAGE" ]; then
    PREIOUS_TAG=$(git tag --sort=-version:refname -l | grep 'v\d\+\.\d\+\.\d\+$' | head -n 1 || echo "")
    if ! [ "$PREIOUS_TAG" ]; then
      create_tag v0.0.1 # v0.0.1 is init tag
      exit 0
    fi

    NEW_TAG="v$(split_version $PREIOUS_TAG increment_patche)"
    create_tag $NEW_TAG
    exit 0
  else
    MAIN_TAG=$(git tag --sort=-version:refname -l | grep 'v\d\+\.\d\+\.\d\+$' | head -n 1 || echo "")
    if ! [ "$MAIN_TAG" ]; then
      MAIN_TAG=v0.0.1 # v0.0.1 is init tag
      create_tag $MAIN_TAG
    fi
    echo $MAIN_TAG
    MAIN_TAG_INCREMENT_PATCHE=$(split_version $MAIN_TAG increment_patche)

    STAGE_TAG_LATEST=$(git tag --sort=-version:refname -l "v${MAIN_TAG_INCREMENT_PATCHE}-${STAGE}+*" | head -n 1)
    STAGE_BUILD_NUMBER=1
    if [ "$STAGE_TAG_LATEST" ]; then
      STAGE_BUILD_NUMBER=$(split_version $STAGE_TAG_LATEST increment_build)
    fi
    NEW_TAG="v${MAIN_TAG_INCREMENT_PATCHE}-${STAGE}+${STAGE_BUILD_NUMBER}"
    create_tag $NEW_TAG
    exit 0
  fi
}
