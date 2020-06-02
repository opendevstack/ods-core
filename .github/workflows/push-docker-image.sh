#!/bin/bash
set -eu

# This script will push a previously build '<imagename>:local' docker image with the corresponding tag to dockerhub.
# The tag will be identified based on the GITHUB_REF environment variable.
# We only create docker images for master (latest) and releases i.e. refs/heads/1.x, refs/heads/1.1.x, refs/tags/v1.0, refs/tags/v1.1.0
# NOTE: The script expects to be run in the github workflow context and makes use of default github environment variables!

shopt -s extglob

function usage {
    printf "\n"
    printf "Usage: push-docker-image.sh --user <user> --password <password> --imagename <imagename>\n\n"
    printf "  --help  Print usage\n"
    printf "\n"
    printf "  --user         Docker ID username\n"
    printf "  --password     Docker ID password\n"
    printf "  --imagename    Name of the image to push\n"
}

if [[ "$#" -gt 0 ]]; then

    while [[ "$#" -gt 0 ]]; do
        case $1 in

        --help) usage; exit 0;;

        --user) USER="$2"; shift;;
        --user=*) USER="${1#*=}";;

        --password) PASSWORD="$2"; shift;;
        --password=*) PASSWORD="${1#*=}";;

        --imagename) IMAGE_NAME="$2"; shift;;
        --imagename=*) IMAGE_NAME="${1#*=}";;

        *) echo "Unknown parameter passed: $1"; usage; exit 1;;
    esac; shift; done

    echo "$GITHUB_REF=$GITHUB_REF"

    DOCKERTAG='none'

    # Examples for GIT_REF to DOCKERTAG mappings
    # master             -> latest
    # tag    'v.1.0'     -> 1.0
    # tag    'v.1.1.0'   -> 1.1.0
    # branch '1.x'       -> 1.x
    # branch '1.1.x'     -> 1.1.x
    # branch 'feature/x' -> none
    case $GITHUB_REF in
        refs/heads/master )
            DOCKERTAG='latest' ;;
        refs/heads/?(+([0-9]).)+([0-9]).x )
            DOCKERTAG="${GITHUB_REF/refs\/heads\//}" ;;
        refs/tags/v?(+([0-9]).)+([0-9]).*([0-9]) )
            DOCKERTAG="${GITHUB_REF/refs\/tags\/v/}" ;;
        * )
            DOCKERTAG='none' ;;
    esac
    echo "DOCKERTAG=$DOCKERTAG"

    if [[ $DOCKERTAG != 'none' ]]; then
        echo "Pushing docker image opendevstackorg/$IMAGE_NAME:$DOCKERTAG"

        echo "$PASSWORD" | docker login -u "$USER" --password-stdin
        docker tag $IMAGE_NAME:local opendevstackorg/$IMAGE_NAME:$DOCKERTAG
        docker push opendevstackorg/$IMAGE_NAME:$DOCKERTAG
        docker logout
        rm -f /home/runner/.docker/config.json
    else
        echo "NOT pushing a docker image for GITHUB_REF=$GITHUB_REF"
    fi 

else
  usage
fi
