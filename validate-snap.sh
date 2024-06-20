#!/usr/bin/env bash

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $(basename $0) <package name> <audited git commit or tag>                          for the latest NPM version"
    echo "       $(basename $0) <package name> <audited git commit or tag> <package version>        for a specific NPM version"
    exit 1
fi

packageName=$1
auditedGitRef=${2}
packageVersion=${3:-latest}

echo "   Fetching snap manifest for package $packageName@$packageVersion"
npm install --silent --no-fund --no-save ${packageName}@${packageVersion}
cd node_modules/${packageName}

# Create a dummy snap.config.js file which is not part of the shasum calculation but required by mm-snap
touch snap.config.js

echo "   Validating published snap manifest"
expectedShasum=$(jq -r .source.shasum <snap.manifest.json)
npx --prefer-offline @metamask/snaps-cli manifest &>/dev/null
actualShasum=$(jq -r .source.shasum <snap.manifest.json)

if [ "$expectedShasum" != "$actualShasum" ]; then
    echo "❌ Published shasum mismatch: $expectedShasum != $actualShasum"
    exit 1
else
    echo "✅ Published shasum matches: $expectedShasum"
fi

echo "   Validating Git URL"
expectedRepositoryUrl=$(jq -r .repository.url <snap.manifest.json)
actualRepositoryUrl=$(npm info ${packageName}@${packageVersion} --json | jq -r .repository.url)

if [ -z "$expectedRepositoryUrl" ] || [ "$expectedRepositoryUrl" = "null" ]; then
    echo "💣 Repository URL absent from snap.manifest.json"
else
    if [ "${expectedRepositoryUrl#*://}" != "${actualRepositoryUrl#*://}" ]; then
        echo "❌ Repository URL mismatch: $expectedRepositoryUrl (snap.manifest.json) != $actualRepositoryUrl (npm info)"
        exit 1
    else
        echo "✅ Repository URL matches: $expectedRepositoryUrl"
    fi
fi

echo "   Validating audited snap manifest"
repo=${actualRepositoryUrl%.git}
repo=${repo#*github.com/}
auditedShasum=$(curl -sS https://raw.githubusercontent.com/$repo/$auditedGitRef/snap.manifest.json | jq -r .source.shasum 2>/dev/null)

# Try with an alternative path if the manifest is not found at the root
if [ -z "$auditedShasum" ] || [ "$auditedShasum" = "null" ]; then
    auditedShasum=$(curl -sS https://raw.githubusercontent.com/$repo/$auditedGitRef/packages/snap/snap.manifest.json | jq -r .source.shasum)
fi

if [ "$auditedShasum" != "$expectedShasum" ]; then
    echo "❌ Audited shasum mismatch: $auditedShasum != $expectedShasum"
    exit 1
else
    echo "✅ Audited shasum matches: $expectedShasum"
fi

echo "   Cleaning up"
cd - >/dev/null
npm uninstall --silent --no-save ${packageName}@${packageVersion}
