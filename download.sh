if [ $# -ne 4 ]; then
    echo "Usage: $0 ARTIFACT_NAME GZ_NAME TARGET GITHUB_TOKEN" >&2
    exit 1
fi

ARTIFACT_NAME="$1"
GZ_NAME="$2"
TARGET="$3"
GITHUB_TOKEN="$4"

ARTIFACT_ID=$(curl -H "Authorization: token $GITHUB_TOKEN" -s "https://api.github.com/repos/holepunchto/bare/actions/artifacts" | \
    jq -r --arg name "$ARTIFACT_NAME" '.artifacts[] | select(.name == $name) | .id' | \
    head -n 1)

if [ -z "$ARTIFACT_ID" ]; then
    echo "Error: Failed to find any releases for $ARTIFACT_NAME on holepunchto/bare" >&2
    exit 1
fi

RUN_ID=$(curl -H "Authorization: token $GITHUB_TOKEN" -s "https://api.github.com/repos/holepunchto/bare/actions/runs?event=workflow_dispatch&status=success" | \
    jq -r '.workflow_runs[] | select(.name == "Prebuild") | .check_suite_id' | \
    sort -nr | \
    head -n 1)

if [ -z "$RUN_ID" ]; then
    echo "Error: Failed to find any recent bare-js build" >&2
    exit 1
fi

echo "RUN_ID: $RUN_ID"
echo "ARTIFACT_ID: $ARTIFACT_ID"
echo "ARTIFACT_NAME: $ARTIFACT_NAME"
echo "TARGET: $TARGET"

download_url="https://nightly.link/holepunchto/bare/suites/${RUN_ID}/artifacts/${ARTIFACT_ID}"

echo "Download URL: $download_url"
bare="bare-$TARGET"

curl -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/octet-stream" \
    -L -o "${bare}.zip" "$download_url"

echo "Done! Output zip file: ${bare}.zip"

ls -lh

file="${bare}.zip"

if [ "$(uname)" = "Darwin" ]; then
  size=$(stat -f%z "$file")
else
  size=$(stat -c%s "$file")
fi

if [ "$size" -lt 1048576 ]; then
  rm "$file"
fi