#!/bin/bash
set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -z ${ENKI_DIR+x} ] || [ ! -d "$ENKI_DIR" ]; then
	if [ -d "$DIR/../../enki" ]; then
		ENKI_DIR="$DIR/../../enki"
	else
		echo "ENKI_DIR is not defined"
		exit 1
	fi
fi
if [ ! -z ${DASHEL_DIR+x} ] || [ ! -d "$DASHEL_DIR" ]; then
	if [ -d "$DIR/../../dashel" ]; then
		DASHEL_DIR="$DIR/../../dashel"
	else
		echo "DASHEL_DIR is not defined"
		exit 1
	fi
fi

ASEBA_DIR="$DIR/../"

# pushd "$DASHEL_DIR"
# debuild -S -sa -i -us -uc
# popd
# pushd "$ENKI_DIR"
# debuild -S -sa -i -us -uc
# popd
pushd "$ASEBA_DIR"
debuild -S -sa -i -us -uc
popd

sudo apt-get install pbuilder local-apt-repository

source "$DIR/pbuilderconf.sh"
for distrib in trusty
do
	mkdir -p `pwd`/$distrib/hooks
	touch `pwd`/$distrib/Packages
	cat > `pwd`/$distrib/hooks/D00deps << EOL
#!/bin/bash
set -xe
apt-get update
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io
EOL
	chmod +x `pwd`/$distrib/hooks/D00deps
	LOCAL_MIRRROR_OPTS=(--distribution $distrib --othermirror "deb [trusted=yes] file://`pwd`/$distrib ./|deb [trusted=yes] http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu trusty main" --bindmounts "`pwd`/$distrib"  --hookdir "`pwd`/$distrib/hooks")
	sudo pbuilder update --distribution $distrib "${LOCAL_MIRRROR_OPTS[@]}" --override-config || sudo pbuilder create "${LOCAL_MIRRROR_OPTS[@]}"
	#sudo pbuilder build  --buildresult `pwd`/$distrib  "$DASHEL_DIR"/../libdashel*.dsc
	#sudo pbuilder build  --buildresult `pwd`/$distrib  "$ENKI_DIR"/../libenki*.dsc
	(cd `pwd`/${distrib}/ && apt-ftparchive packages . > Packages)
	sudo pbuilder build  --buildresult `pwd`/$distrib  "${LOCAL_MIRRROR_OPTS[@]}"  --hookdir "`pwd`/$distrib/hooks" --bindmounts "`pwd`/$distrib" "$ASEBA_DIR"/../aseba*.dsc
done

