#!/bin/bash

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

set -e

cd packages

middlewares=(
  graphql-playground-middleware-express
  graphql-playground-middleware-hapi
  graphql-playground-middleware-koa
  graphql-playground-middleware-lambda
)

cd graphql-playground-react
yarn install
echo "Releasing @apollographql/graphql-playground-react..."
yarn version --no-git-tag-version --new-version patch
yarn publish --non-interactive --access public
export version=$(cat package.json | jq -r '.version')
cd ..

echo "Updating JSDeliver cache..."
curl -X POST \
  http://purge.jsdelivr.net/ \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{
	"path": [
		"/npm/@apollographql/graphql-playground-react/build/static/css/middleware.css",
		"/npm/@apollographql/graphql-playground-react/build/static/js/middleware.js"
	]
}'

# for middleware in "${middlewares[@]}"
# do
#   cd $middleware
#   yarn install
#   echo "Releasing ${middleware}..."
#   cat package.json | jq ".playgroundVersion = \"$version\"" > package.tmp.json
#   mv package.tmp.json package.json
#   npm version patch --no-git-tag-version
#   npm publish
#   cd ..
# done

cd graphql-playground-electron
echo "Updating dependency & version in @apollographql/graphql-playground-electron..."
yarn add @apollographql/graphql-playground-react@$version
yarn version --no-git-tag-version --new-version patch
cd ..
