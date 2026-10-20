#!/usr/bin/env bash
# Builds the console for the local stack into .tmp/devstack/console.
#
# The console depends on sibling checkouts (../service-profile, ...) by path.
# service-authentication and service-profile moved their Dart SDKs to
# protobuf 6 while the rest of the platform is still on protobuf 4, so their
# current heads cannot be resolved together. Until every SDK has moved, the
# build runs in a scratch workspace where those two are pinned to the commit
# before the move and every other sibling is the checkout next to this repo.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
siblings=$(dirname "$repo")
ws="$repo/.tmp/devstack/workspace"
out="$repo/.tmp/devstack/console"

pin() { # pin <repo> <commit>: a detached worktree of <repo> at <commit>
	if [ ! -d "$ws/$1" ]; then
		git -C "$siblings/$1" worktree add --detach "$ws/$1" "$2" >/dev/null
	fi
}

mkdir -p "$ws"
for sibling in common service-manufacturing service-notification service-payment service-fintech service-files; do
	ln -sfn "$siblings/$sibling" "$ws/$sibling"
done
pin service-authentication 3cc5cf4^ # last commit on protobuf 4
pin service-profile 0462970^        # last commit on protobuf 4
rsync -a --delete --exclude .git --exclude .tmp --exclude build --exclude .dart_tool --exclude gen/go \
	"$repo/" "$ws/service-commerce/"

cd "$ws/service-commerce/ui/console"
flutter build web --release \
	--dart-define=API_BASE_URL=http://localhost:8090 \
	--dart-define=OAUTH2_ISSUER_URL=http://localhost:8090 \
	--dart-define=OAUTH2_CLIENT_ID=console-dev
rm -rf "$out"
cp -r build/web "$out"
echo "console built into $out"
