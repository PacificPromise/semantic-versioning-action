get_stage_prompt() {
  title="Action:"
  prompt="Choose:"
  options=("Increment development environment" "Increment staging environment" "Increment UAT environment" "Increment product environment" "Increment patch version (1.0.xx)" "Increment minor version (1.xx.0)" "Increment major version (xx.0.0)")

  echo "$title"
  PS3="$prompt "
  STAGE=""
  select opt in "${options[@]}" "Quit"; do
    case "$REPLY" in
    1) echo "Chose option: $opt" && increment_tag dev && break ;;
    2) echo "Chose option: $opt" && increment_tag stg && break ;;
    3) echo "Chose option: $opt" && increment_tag uat && break ;;
    4) echo "Chose option: $opt" && increment_tag prd && break ;;
    5) echo "Chose option: $opt" && increment_core_tag patch && break ;;
    6) echo "Chose option: $opt" && increment_core_tag minor && break ;;
    6) echo "Chose option: $opt" && increment_core_tag major && break ;;
    $((${#options[@]} + 1)))
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Choose again !"
      continue
      ;;
    esac
  done
}
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
  VERSION_TYPE=$2 # full, all, major, minor, patch, increment_patch, build, increment_build

  VERSION_NAME_PATH=($(grep -oE '[a-z,0-9,-.+]*' <<<"$TAG_NAME"))
  ARRAY_SIZE=${#VERSION_NAME_PATH[@]}
  VERSION=${VERSION_NAME_PATH[$((ARRAY_SIZE - 1))]}
  VERSION_ARRAY=($(grep -oE '[0-9]*' <<<"$VERSION"))

  case $VERSION_TYPE in
  all)
    echo ${VERSION}
    ;;
  major)
    echo ${VERSION_ARRAY[0]}
    ;;
  minor)
    echo ${VERSION_ARRAY[1]}
    ;;
  patch)
    echo ${VERSION_ARRAY[2]}
    ;;
  build)
    echo ${VERSION_ARRAY[3]}
    ;;
  next_build)
    if [[ $OSTYPE == 'msys'* ]]; then
      echo ${VERSION_ARRAY[3]} + 1
    else
      echo ${VERSION_ARRAY[3]} + 1 | bc
    fi
    ;;
  esac
}

increment_version() {
  TAG_NAME=$1
  VERSION_TYPE=$2 # full, all, major, minor, patch

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
  major)
    MAJOR_WILL_BUILD=$((VERSION_ARRAY[0] + 1))
    echo "${MAJOR_WILL_BUILD}.0.0"
    ;;
  minor)
    MINOR_WILL_BUILD=$((VERSION_ARRAY[1] + 1))
    echo "${VERSION_ARRAY[0]}.${MINOR_WILL_BUILD}.0"
    ;;
  patch)
    PATCH_WILL_BUILD=$((VERSION_ARRAY[2] + 1))
    echo "${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCH_WILL_BUILD}"
    ;;
  esac
}

get_previous_tag() {
  PREVIOUS_TAG=''
  if [[ $OSTYPE == 'darwin'* ]]; then
    PREVIOUS_TAG=$(git tag --sort=-version:refname -l | grep 'v\d\+\.\d\+\.\d\+$' | head -n 1 || echo "")
  fi

  if [[ $OSTYPE == 'linux'* ]]; then
    PREVIOUS_TAG=$(git tag --sort=-version:refname -l | grep -P "v\d+\.\d+\.\d+$" | head -n 1 || echo "")
  fi

  if [[ $OSTYPE == 'msys'* ]]; then
    PREVIOUS_TAG=$(git tag --sort=-version:refname -l | findstr 'v\d\+\.\d\+\.\d\+$' | head -n 1 || echo "")
  fi

  echo $PREVIOUS_TAG
}

get_increment_core_tag() {
  VERSION_TYPE=$1
  git fetch --all --tags
  PREVIOUS_TAG=$(get_previous_tag)
  echo 123
  echo ${PREVIOUS_TAG}
  echo 321
  if ! [ "$PREVIOUS_TAG" ]; then
    echo v0.0.1 # v0.0.1 is init tag
    exit 0
  fi
  NEW_TAG="v$(increment_version $PREVIOUS_TAG $VERSION_TYPE)"
  echo $NEW_TAG
}

increment_core_tag() {
  VERSION_TYPE=$1
  git fetch --all --tags
  PREVIOUS_TAG=$(get_previous_tag)
  if ! [ "$PREVIOUS_TAG" ]; then
    create_tag v0.0.1 # v0.0.1 is init tag
    exit 0
  fi
  NEW_TAG="v$(increment_version $PREVIOUS_TAG $VERSION_TYPE)"
  create_tag $NEW_TAG
}

increment_tag() {
  git fetch --all --tags
  STAGE=$1
  if ! [ "$STAGE" ]; then
    PREVIOUS_TAG=$(get_previous_tag)
    if ! [ "$PREVIOUS_TAG" ]; then
      create_tag v0.0.1 # v0.0.1 is init tag
      exit 0
    fi

    NEW_TAG="v$(increment_version $PREVIOUS_TAG patch)"
    create_tag $NEW_TAG
    exit 0
  else
    MAIN_TAG=$(get_previous_tag)
    if ! [ "$MAIN_TAG" ]; then
      MAIN_TAG=v0.0.1 # v0.0.1 is init tag
      create_tag $MAIN_TAG
    fi
    MAIN_TAG_INCREMENT_PATCH=$(increment_version $MAIN_TAG patch)

    STAGE_TAG_LATEST=$(git tag --sort=-version:refname -l "v${MAIN_TAG_INCREMENT_PATCH}-${STAGE}+*" | head -n 1)
    STAGE_BUILD_NUMBER=1
    if [ "$STAGE_TAG_LATEST" ]; then
      STAGE_BUILD_NUMBER=$(split_version $STAGE_TAG_LATEST next_build)
    fi
    NEW_TAG="v${MAIN_TAG_INCREMENT_PATCH}-${STAGE}+${STAGE_BUILD_NUMBER}"
    create_tag $NEW_TAG
    exit 0
  fi
}
