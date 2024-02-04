#!/bin/bash
#
# build vim
#

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

SRCDIR=$script_dir/../vim/src
FEATURES=huge
export CFLAGS="-Wno-deprecated-declarations"

typeset -a CFG_OPTS
CFG_OPTS+=( "--disable-perlinterp" )
CFG_OPTS+=( "--disable-pythoninterp" )
CFG_OPTS+=( "--without-python3-stable-abi" )
CFG_OPTS+=( "--disable-rubyinterp" )
CFG_OPTS+=( "--disable-luainterp" )
CFG_OPTS+=( "--disable-tclinterp" )
CFG_OPTS+=( "--disable-cscope" )
CFG_OPTS+=( "--disable-netbeans" )
CFG_OPTS+=( "--prefix=/usr" )

NPROC=$(getconf _NPROCESSORS_ONLN)

# Apply experimental patches
shopt -s nullglob
pushd "${SRCDIR}"/..
for i in ../patch/*.patch; do git apply -v "$i"; done
popd
shopt -u nullglob

cd "${SRCDIR}"

# Build Vim - no X11
rm -rf vim
SHADOWDIR=vim make -e shadow
pushd vim
ADDITIONAL_ARG="--with-x --enable-gui=no --enable-fail-if-missing"
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" $ADDITIONAL_ARG
make -j$NPROC
popd

# Build GVim
rm -rf gvim
SHADOWDIR=gvim make -e shadow
pushd gvim
ADDITIONAL_ARG="--enable-fail-if-missing"
CFG_OPTS+=( "--enable-gui=gtk3" )
./configure --with-features=$FEATURES "${CFG_OPTS[@]}" $ADDITIONAL_ARG
make -j$NPROC
popd
