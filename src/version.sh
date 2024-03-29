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
    echo $((VERSION_ARRAY[3] + 1))
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
    PREVIOUS_TAG=$(git tag --sort=-version:refname -l | grep -P "v\d+\.\d+\.\d+$" | head -n 1 || echo "")
  fi

  echo $PREVIOUS_TAG
}

get_increment_core_tag() {
  VERSION_TYPE=$1
  git fetch --all --tags --force
  PREVIOUS_TAG=$(get_previous_tag)
  if ! [ "$PREVIOUS_TAG" ]; then
    echo v0.0.1 # v0.0.1 is init tag
    exit 0
  fi
  NEW_TAG="v$(increment_version $PREVIOUS_TAG $VERSION_TYPE)"
  echo $NEW_TAG
}

increment_core_tag() {
  VERSION_TYPE=$1
  git fetch --all --tags --force
  PREVIOUS_TAG=$(get_previous_tag)
  if ! [ "$PREVIOUS_TAG" ]; then
    create_tag v0.0.1 # v0.0.1 is init tag
    exit 0
  fi
  NEW_TAG="v$(increment_version $PREVIOUS_TAG $VERSION_TYPE)"
  create_tag $NEW_TAG
}

increment_tag() {
  git fetch --all --tags --force
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

    if [[ $STAGE == 'prd'* ]]; then # Check previous production tag
      STAGE_TAG_LATEST=$(git tag --sort=-version:refname -l "v[0-9]*.[0-9]*.[0-9]*-${STAGE}+[0-9]*" | head -n 1)
    fi

    STAGE_BUILD_NUMBER=1
    if [ "$STAGE_TAG_LATEST" ]; then
      STAGE_BUILD_NUMBER=$(split_version $STAGE_TAG_LATEST next_build)
    fi
    NEW_TAG="v${MAIN_TAG_INCREMENT_PATCH}-${STAGE}+${STAGE_BUILD_NUMBER}"
    create_tag $NEW_TAG
    exit 0
  fi
}
