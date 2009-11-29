set -e

cd $(dirname $0)/bin

for cmd in $(ls); do
	install -v -c $cmd /usr/local/bin/$cmd
done

echo "Installed successfully"
echo "Run \`tear init\` - NOTE: See \`tear help init\` for overriding default options"
