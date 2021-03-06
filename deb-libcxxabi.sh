#!/bin/bash
export NAME=libc++abi
export ARCHITECTURE=amd64
#Clone the directory
export URL=http://llvm.org/svn/llvm-project/libcxxabi/trunk
svn export $URL $NAME
export SVNVERSION=$(svn info $URL | grep Revision | cut -d' ' -f2)
export VERSION=1.0-svn$SVNVERSION
export DEBVERSION=${VERSION}-1
cd $NAME
#Package the source
tar cJvf ${NAME}_${VERSION}.orig.tar.xz $NAME
mv ${NAME}_${VERSION}.orig.tar.xz ..
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp $NAME/LICENSE.TXT debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), cmake, clang, libunwind8-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://libcxxabi.llvm.org/" >> debian/control
echo "Description: libc++abi C++ Standard library ABI" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tcd lib && ./buildit' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/lib" >> debian/rules
echo -e "\tcp lib/libc++abi.so.1.0 debian/$NAME/usr/lib" >> debian/rules
echo -e "\tcd debian/$NAME/usr/lib && ln -s libc++abi.so.1.0 libc++abi.so" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b
