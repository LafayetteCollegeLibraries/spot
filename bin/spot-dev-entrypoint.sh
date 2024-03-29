#!/bin/bash
set -e

app_root="/spot"
uv_root="$app_root/public/uv"

if [[ -d "$uv_root" && -f "$uv_root/uv.js" && -f "$uv_root/uv.html" ]];
then
  echo "not installing UniversalViewer as it already exists"
else
  echo "installing UniversalViewer via Yarn"
  cd "$app_root" && yarn install
fi

# copy the dev UV configuration _after_ running yarn install.
# previously, i was adding this file with a volume link in the
# docker-compose#app config, but it was causing the `yarn install`
# command to fail because the file was unable to be deleted.
cp "$app_root/config/uv/uv-config-development.json" "$uv_root/uv-config.json"

exec "$app_root/bin/spot-entrypoint.sh" "$@"
