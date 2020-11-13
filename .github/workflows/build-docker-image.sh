#!/bin/bash
set -eu

function usage {
    printf "\n"
    printf "Usage: build-docker-image.sh --imagename <imagename> --dockerdir <dockerdir>\n\n"
    printf "  --help  Print usage\n"
    printf "\n"
    printf "  --imagename    Name of the image beeing build\n"
    printf "  --dockerdir    Path to the docker context dir\n"
    printf "  --dockerfile   Name of Dockerfile, relative to --dockerdir\n"
}

DOCKER_FILE="Dockerfile"
BUILDARGS_ARR=()

if [[ "$#" -gt 0 ]]; then
    
    while [[ "$#" -gt 0 ]]; do
        case $1 in

        --help) usage; exit 0;;

        --imagename) IMAGE_NAME="$2"; shift;;
        --imagename=*) IMAGE_NAME="${1#*=}";;

        --dockerdir) DOCKER_DIR="$2"; shift;;
        --dockerdir=*) DOCKER_DIR="${1#*=}";;

        --dockerfile) DOCKER_FILE="$2"; shift;;
        --dockerfile=*) DOCKER_FILE="${1#*=}";;

        --build-arg)
            BUILDARGS_ARR+=("${2}")
            shift;;

        *) echo "Unknown parameter passed: $1"; usage; exit 1;;
    esac; shift; done

    BUILDARGS=""
    if [ ${#BUILDARGS_ARR[@]} -ne 0 ]; then
        for ba in "${BUILDARGS_ARR[@]}"
        do
	        BUILDARGS="$BUILDARGS --build-arg $ba"
        done
    fi

    COMMIT_AUTHOR=$(git --no-pager show -s --format='%an (%ae)' $GITHUB_SHA)
    COMMIT_MESSAGE=$(git log -1 --pretty=%B $GITHUB_SHA)
    COMMIT_TIME=$(git show -s --format=%ci $GITHUB_SHA)
    BUILD_TIME=$(date -u "+%Y-%m-%d %H:%M:%S %z")

    cd $DOCKER_DIR
    docker build --file $DOCKER_FILE $BUILDARGS \
    --label "ods.build.job.url=https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" \
    --label "ods.build.source.repo.ref=$GITHUB_REF" \
    --label "ods.build.source.repo.commit.author=$COMMIT_AUTHOR" \
    --label "ods.build.source.repo.commit.msg=$COMMIT_MESSAGE" \
    --label "ods.build.source.repo.commit.sha=$GITHUB_SHA" \
    --label "ods.build.source.repo.commit.timestamp=$COMMIT_TIME" \
    --label "ods.build.source.repo.url=https://github.com/$GITHUB_REPOSITORY.git" \
    --label "ods.build.timestamp=$BUILD_TIME" \
    -t $IMAGE_NAME:local .

    docker inspect $IMAGE_NAME:local --format='{{.Config.Labels}}'

else
  usage
fi
