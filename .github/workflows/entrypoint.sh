#!/bin/bash

if [[ -z "$GITHUB_WORKSPACE" || -z "$GITHUB_REPOSITORY" ]]; then
    echo "Script is not running in GitHub Actions CI"
    exit 1
fi

detect_manifest() {
    repo=${1}
    
    # check if repo opted out
    if [[ -f $repo/flathub.json ]]; then
        if ! jq -e '."disable-external-data-checker" | not' < $repo/flathub.json > /dev/null; then
            return 1
        fi
        if ! jq -e '."end-of-life" or ."end-of-life-rebase" | not' < $repo/flathub.json > /dev/null; then
            return 1
        fi
    fi

    if [[ -f $repo/${repo}.yml ]]; then
        manifest=${repo}.yml
    elif [[ -f $repo/${repo}.yaml ]]; then
        manifest=${repo}.yaml
    elif [[ -f $repo/${repo}.json ]]; then
        manifest=${repo}.json
    else
        return 1
    fi

    echo $manifest
}

git config --global user.name "flathubbot" && \
git config --global user.email "sysadmin@flathub.org"

echo "==> checking ${repo}"
/app/flatpak-external-data-checker --verbose --update $MANIFEST

echo $GITHUB_TOKEN
echo $checker_apps
echo "end of action"