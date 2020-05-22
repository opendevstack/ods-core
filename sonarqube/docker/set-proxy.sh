#!/usr/bin/env bash
set -ue

targetFile=$1

if [ -z "${targetFile}" ]; then
    echo "No target config file given"
    exit 1
fi

# Checks for env variable HTTP_PROXY and adds it to the SQ configuration.
# See https://docs.sonarqube.org/latest/instance-administration/marketplace/.
# See https://docs.openshift.com/container-platform/3.11/install_config/http_proxies.html.
if [ -z "${HTTP_PROXY:-}" ]; then
    echo "Proxy not configured as no HTTP_PROXY is set."
else
    proxy=$(echo "${HTTP_PROXY}" | sed -e "s|https://||g" | sed -e "s|http://||g")
    proxyHostPart=$(echo "${proxy}" | cut -d "@" -f 2-)

    proxyHost=$(echo "${proxyHostPart}"| cut -d ":" -f 1)
    proxyPort=$(echo "${proxyHostPart}"| cut -d ":" -f 2-)
    {
        echo "http.proxyHost=${proxyHost}"
        echo "http.proxyPort=${proxyPort}"
    } >> "${targetFile}"

    proxyUserPart=$(echo "${proxy}" | cut -d "@" -f 1)
    if [ "${proxyUserPart}" != "${proxyHostPart}" ]; then
        proxyUser=$(echo "${proxyUserPart}" | cut -d ":" -f 1)
        proxyPassword=$(echo "${proxyUserPart}" | cut -d ":" -f 2-)
        {
            echo "http.proxyUser=${proxyUser}"
            echo "http.proxyPassword=${proxyPassword}"
        } >> "${targetFile}"
    fi

    echo "Configured proxy settings:"
    grep "^http\.proxy" "${targetFile}"
fi

