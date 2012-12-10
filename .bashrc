source ~/.kde-bashrc
export PATH=$PATH:~/mybins

alias lsa='ls -a'
alias agi='sudo apt-get install'
alias bl30='xbacklight -set 30'

function cdb(){

    for i in `seq 1 $1`;
        do
            cd .. 
        done 
}

function bl(){

    xbacklight -set $1
}

function pushbnv(){

    current_dir=$PWD
    cd
    cp .bashrc ./bashrc-and-vimrc/.
    cp .vimrc ./bashrc-and-vimrc/.
    cd bashrc-and-vimrc
    git commit -am "$1"
    git push
    cd $current_dir
}

function setupKDEBE(){

# Replacing:
#   \ with \\
#   " with \"
#   $ with \$
#   ` with \`
#   \n with \\n\n or  \\n\n
#   \n with \\\n

    echo "Setting up KDE Build Environment.."
    echo "Creating directoried 'mybin' and 'kde'"
    mkdir mybins kde
    cd mybins
    echo "Generating findup"
    touch findup
    
echo \
"#!/bin/sh\n\
 \n\
arg=\"\$1\"\n\
if test -z \"\$arg\"; then exit 1; fi\n\
 \n\
while ! test -f \"\$arg\"; do\n\
 cd ..\n\
 if test \"\$PWD\" = \"/\"; then\n\
    exit 1\n\
 fi\n\
done\n\
 \n\
echo \$PWD/\$arg" > findup 

    chmod +x findup
    cd ..
    echo "Generating .kde-bashrc"
    
echo \
"### \n\
## A script to setup some needed variables and functions for KDE 4 development. \n\
## This should normally go in the ~/.bashrc file of your kde development user. \n\
### \n\
  \n\
CURRENT_SHELL=\$(echo \$0) \n\
  \n\
prepend() { [ -d \"\$2\" ] && eval \$1=\\\"\$2\\\$\\{\$1:+':'\\\$\$1\\}\\\" && export \$1 ; } \n\
  \n\
# This will make the debug output prettier \n\
export KDE_COLOR_DEBUG=1 \n\
export QTEST_COLORED=1 \n\
  \n\
# Make \n\
# Tell many scripts how to switch from source dir to build dir: \n\
export OBJ_REPLACEMENT=\"s#\$KDE_SRC#\$KDE_BUILD#\" \n\
  \n\
# Use makeobj instead of make, to automatically switch to the build dir. \n\
# If you don't have makeobj, install the package named kdesdk-scripts or \n\
# kdesdk, or check out kdesdk/scripts from svn, or just don't set the alias \n\
# yet. \n\
alias make=makeobj \n\
  \n\
## \n\
# A function to easily build the current directory of KDE. \n\
# \n\
# This builds only the sources in the current ~/{src,build}/KDE subdirectory. \n\
# Usage: cs KDE/kdebase && cmakekde \n\
#   will build/rebuild the sources in ~/src/KDE/kdebase \n\
## \n\
function cmakekde { \n\
    if test -n \"\$1\"; then \n\
        # srcFolder is defined via command line argument \n\
        srcFolder=\"\$1\" \n\
    else \n\
        # get srcFolder for current dir \n\
        srcFolder=\`pwd | sed -e s,\$KDE_BUILD,\$KDE_SRC,\` \n\
    fi \n\
    # we are in the src folder, change to build directory \n\
    # Alternatively, we could just use makeobj in the commands below... \n\
    current=\`pwd\` \n\
    if [ \"\$srcFolder\" = \"\$current\" ]; then \n\
        cb \n\
    fi \n\
    # To disable tests, remove -DKDE4_BUILD_TESTS=TRUE \n\
    # To save disk space change \"debugfull\" to \"debug\" \n\
    cmake \"\$srcFolder\" \\ \n\
          -DCMAKE_INSTALL_PREFIX=\$KDEDIR \\ \n\
          -DKDE4_AUTH_POLICY_FILES_INSTALL_DIR=\$KDEDIR/share/polkit-1/actions \\ \n\
          -DKDE4_BUILD_TESTS=TRUE \\ \n\
          -DCMAKE_BUILD_TYPE=debugfull \n\
  \n\
        # Comment out the following two lines to stop builds waiting after \n\
        # the configuration step, so that the user can check configure output \n\
        echo \"Press <ENTER> to continue...\" \n\
        read userinput \n\
  \n\
        # Note: To speed up compiling, change 'make -j2' to 'make -jx', \n\
        #   where x is your number of processors +1 \n\
        nice make -j2 && make install \n\
        #Use this line instead if using icecream \n\
        #nice make CC=icecc -j6 && make install \n\
        RETURN=\$? \n\
        cs \n\
        return \${RETURN} \n\
} \n\
  \n\
## \n\
# A function to easily build the current directory of KDE. \n\
# \n\
# This builds only the sources in the current ~/{src,build}/KDE subdirectory. \n\
# Usage: cs KDE/kdebase && kdebuild \n\
#   will build/rebuild the sources in ~/src/KDE/kdebase \n\
## \n\
function kdebuild { \n\
    if test -n \"\$1\"; then \n\
        # srcFolder is defined via command line argument \n\
        srcFolder=\"\$1\" \n\
    else \n\
        # get srcFolder for current dir \n\
        srcFolder=\`pwd | sed -e s,\$KDE_BUILD,\$KDE_SRC,\` \n\
    fi \n\
    # we are in the src folder, change to build directory \n\
    # Alternatively, we could just use makeobj in the commands below... \n\
    current=\`pwd\` \n\
    if [ \"\$srcFolder\" = \"\$current\" ]; then \n\
        cb \n\
    fi \n\
    # To disable tests, remove -DKDE4_BUILD_TESTS=TRUE \n\
    # To save disk space change \"debugfull\" to \"debug\" \n\
    cmake \"\$srcFolder\" \\ \n\
          -DCMAKE_INSTALL_PREFIX=\$KDEDIR \\ \n\
          -DKDE4_AUTH_POLICY_FILES_INSTALL_DIR=\$KDEDIR/share/polkit-1/actions \\ \n\
          -DKDE4_BUILD_TESTS=TRUE \\ \n\
          -DCMAKE_BUILD_TYPE=debugfull \n\
  \n\
    # Comment out the following two lines to stop builds waiting after \n\
    # the configuration step, so that the user can check configure output \n\
    echo \"Press <ENTER> to continue...\" \n\
    read userinput \n\
  \n\
    # Note: To speed up compiling, change 'make -j2' to 'make -jx', \n\
    #   where x is your number of processors +1 \n\
    nice make -j2 && make install \n\
    #Use this line instead if using icecream \n\
    #nice make CC=icecc -j6 && make install \n\
    RETURN=\$? \n\
    cs \n\
    return \${RETURN} \n\
} \n\
  \n\
## \n\
# A function to easily run cmake for KDE configuration \n\
## \n\
function kdecmake { \n\
    if test -n \"\$1\"; then \n\
        # srcFolder is defined via command line argument \n\
        srcFolder=\"\$1\" \n\
    else \n\
        # get srcFolder for current dir \n\
        srcFolder=\`pwd | sed -e s,\$KDE_BUILD,\$KDE_SRC,\` \n\
    fi \n\
    # we are in the src folder, change to build directory \n\
    # Alternatively, we could just use makeobj in the commands below... \n\
    current=\`pwd\` \n\
    if [ \"\$srcFolder\" = \"\$current\" ]; then \n\
        cb \n\
    fi \n\
    # To disable tests, remove -DKDE4_BUILD_TESTS=TRUE \n\
    # To save disk space change \"debugfull\" to \"debug\" \n\
    cmake \"\$srcFolder\" \\ \n\
          -DCMAKE_INSTALL_PREFIX=\$KDEDIR \\ \n\
          -DKDE4_AUTH_POLICY_FILES_INSTALL_DIR=\$KDEDIR/share/polkit-1/actions \\ \n\
          -DKDE4_BUILD_TESTS=TRUE \\ \n\
          -DCMAKE_BUILD_TYPE=debugfull \n\
    RETURN=\$? \n\
    cs \n\
    return \${RETURN} \n\
} \n\
  \n\
## \n\
# A function to easily make and install the current or selected directory of KDE. \n\
## \n\
function kdemake { \n\
    if test -n \"\$1\"; then \n\
        # srcFolder is defined via command line argument \n\
        srcFolder=\"\$1\" \n\
    else \n\
        # get srcFolder for current dir \n\
        srcFolder=\`pwd | sed -e s,\$KDE_BUILD,\$KDE_SRC,\` \n\
    fi \n\
    # we are in the src folder, change to build directory \n\
    # Alternatively, we could just use makeobj in the commands below... \n\
    current=\`pwd\` \n\
    if [ \"\$srcFolder\" = \"\$current\" ]; then \n\
        cb \n\
    fi \n\
  \n\
    # Note: To speed up compiling, change 'make -j2' to 'make -jx', \n\
    #   where x is your number of processors +1 \n\
    nice make -j2 && make install \n\
    #Use this line instead if using icecream \n\
    #nice make CC=icecc -j6 && make install \n\
    RETURN=\$? \n\
    cs \n\
    return \${RETURN} \n\
} \n\
  \n\
function cd() { \n\
  if test -z \"\$1\"; then \n\
    builtin cd \n\
  elif test -z \"\$2\"; then \n\
    builtin cd \"\$1\" \n\
  else \n\
    builtin cd \"\$1\" \"\$2\" \n\
  fi \n\
  _f=\`findup .build-config\` \n\
  if test -n \"\$_f\" -a \"\$_lastf\" != \"\$_f\"; then \n\
    echo \"Loading \$_f\" \n\
    _lastf=\"\$_f\" \n\
    source \"\$_f\" \n\
  fi \n\
} \n\
  \n\
## \n\
# A function to easily change to the build directory. \n\
# Usage: cb KDE/kdebase \n\
#   will change to \$KDE_BUILD/KDE/kdebase \n\
# Usage: cb \n\
#   will simply go to the build folder if you are currently in a src folder \n\
#   Example: \n\
#     \$ pwd \n\
#     /home/user/src/KDE/kdebase \n\
#     \$ cb && pwd \n\
#     /home/user/build/KDE/kdebase \n\
# \n\
function cb { \n\
        local dest \n\
  \n\
    # Make sure build directory exists. \n\
    mkdir -p \"\$KDE_BUILD\" \n\
  \n\
    # command line argument \n\
    if test -n \"\$1\"; then \n\
        cd \"\$KDE_BUILD/\$1\" \n\
        return \n\
    fi \n\
    # substitute src dir with build dir \n\
    dest=\`pwd | sed -e s,\$KDE_SRC,\$KDE_BUILD,\` \n\
    if test ! -d \"\$dest\"; then \n\
        # build directory does not exist, create \n\
        mkdir -p \"\$dest\" \n\
    fi \n\
    cd \"\$dest\" \n\
} \n\
  \n\
## \n\
# Change to the source directory.  Same as cb, except this \n\
# switches to \$KDE_SRC instead of \$KDE_BUILD. \n\
# Usage: cs KDE/kdebase \n\
#   will change to \$KDE_SRC/KDE/kdebase \n\
# Usage: cs \n\
#   will simply go to the source folder if you are currently in a build folder \n\
#   Example: \n\
#     \$ pwd \n\
#     /home/myuser/kde/build/master/KDE/kdebase \n\
#     \$ cs && pwd \n\
#     /home/myuser/kde/src/master/KDE/kdebase \n\
# \n\
function cs { \n\
        local dest current \n\
  \n\
    # Make sure source directory exists. \n\
    mkdir -p \"\$KDE_SRC\" \n\
  \n\
    # command line argument \n\
    if test -n \"\$1\"; then \n\
        cd \"\$KDE_SRC/\$1\" \n\
    else \n\
        # substitute build dir with src dir \n\
        dest=\`pwd | sed -e s,\$KDE_BUILD,\$KDE_SRC,\` \n\
        current=\`pwd\` \n\
        if [ \"\$dest\" = \"\$current\" ]; then \n\
            cd \"\$KDE_SRC\" \n\
        else \n\
            cd \"\$dest\" \n\
        fi \n\
    fi \n\
} \n\
  \n\
## \n\
# Add autocompletion to cs function \n\
# \n\
function _cs_scandir \n\
{ \n\
        local base ext \n\
  \n\
    base=\$1 \n\
    ext=\$2 \n\
    if [ -d \$base ]; then \n\
        for d in \`ls \$base\`; do \n\
            if [ -d \$base/\$d ]; then \n\
                dirs=\"\$dirs \$ext\$d/\" \n\
            fi \n\
        done \n\
    fi \n\
} \n\
  \n\
function _cs() \n\
{ \n\
    local cur dirs \n\
    _cs_scandir \"\$KDE_SRC\" \n\
    _cs_scandir \"\$KDE_SRC/KDE\" \"KDE/\" \n\
    COMPREPLY=() \n\
    cur=\"\${COMP_WORDS[COMP_CWORD]}\" \n\
    COMPREPLY=( \$(compgen -W \"\${dirs}\" -- \${cur}) ) \n\
} \n\
  \n\
svndiff () \n\
{ \n\
    svn diff \"\$*\" | colordiff | less; \n\
} \n\
  \n\
# Setup shell \n\
if [ \"\$CURRENT_SHELL\" = \"bash\" ]; then \n\
    complete -F _cs cs \n\
fi" > tmpStore

    cat tmpStore | sed 's/[ \t]*$//' > .kde-bashrc
    rm tmpStore

    cd kde
    echo "Generating .build-config in 'kde' directory"

echo \
"# KDE4 Build Environment configuration script\n\
#\n\
# To configure your build environment set LIB_SUFFIX, BASEDIR, BUILDNAME and\n\
# QTDIR as appropriate\n\
#\n\
# The default values provided are for a master/trunk/unstable build in your own\n\
# user directory using your system Qt\n\
 \n\
# Uncomment if building on a 64 bit system\n\
#export LIB_SUFFIX=64\n\
 \n\
# Set where your base KDE development folder is located, usually ~/kde\n\
export BASEDIR=~/kde\n\
 \n\
# Give the build a name, e.g. master, 4.6, debug, etc\n\
export BUILDNAME=master\n\
 \n\
# Set up which Qt to use\n\
# Use the system Qt, adjust path as required\n\
export QTDIR=/usr\n\
# Uncomment to use your own build of qt-kde\n\
#export QTDIR=\$BASEDIR/inst/master/qt-kde\n\
#export PATH=\$QTDIR/bin:\$PATH\n\
#export LD_LIBRARY_PATH=\$QTDIR/lib:\$LD_LIBRARY_PATH\n\
#export PKG_CONFIG_PATH=\$QTDIR/lib/pkgconfig:\$PKG_CONFIG_PATH\n\
 \n\
# Set up the KDE paths\n\
export KDE_SRC=\$BASEDIR/src\n\
export KDE_BUILD=\$BASEDIR/build\n\
export KDEDIR=\$BASEDIR/inst/\$BUILDNAME\n\
export KDEDIRS=\$KDEDIR\n\
export KDEHOME=\$BASEDIR/home/.\$BUILDNAME\n\
export KDETMP=/tmp/\$BUILDNAME-\$USER\n\
export KDEVARTMP=/var/tmp/\$BUILDNAME-\$USER\n\
mkdir -p \$KDETMP\n\
mkdir -p \$KDEVARTMP\n\
 \n\
# Add the KDE plugins to the Qt plugins path\n\
export QT_PLUGIN_PATH=\$KDEDIR/lib/kde4/plugins\n\
 \n\
# Do we really need these?\n\
export KDE4_DBUS_INTERFACES_DIR=\$KDEDIR/share/dbus-1/interfaces\n\
export PYTHON_SITE_PACKAGES_DIR=\$KDEDIR/lib/python2.6/site-packages/PyKDE4\n\
 \n\
# Export the standard paths to include KDE\n\
export PATH=\$KDEDIR/bin:\$PATH\n\
export LD_LIBRARY_PATH=\$KDEDIR/lib:\$LD_LIBRARY_PATH\n\
export PKG_CONFIG_PATH=\$KDEDIR/lib/pkgconfig:\$PKG_CONFIG_PATH\n\
 \n\
# Export the CMake paths so it searches for KDE in the right places\n\
export CMAKE_PREFIX_PATH=\$KDEDIR:\$CMAKE_PREFIX_PATH\n\
export CMAKE_LIBRARY_PATH=\$KDEDIR/lib:\$CMAKE_LIBRARY_PATH\n\
export CMAKE_INCLUDE_PATH=\$KDEDIR/include:\$CMAKE_INCLUDE_PATH\n\
 \n\
# Unset XDG to avoid seeing KDE files from /usr\n\
# If unset then you must install shared-mime-info\n\
unset XDG_DATA_DIRS\n\
unset XDG_CONFIG_DIRS\n\
 \n\
# Uncomment if you are using Icecream for distributed compiling\n\
#export PATH=/opt/icecream/bin:\$PATH\n\
 \n\
# Report what the environment is set to\n\
echo\n\
echo \"*** Configured KDE Build Environment \" \$BUILDNAME \" ***\"\n\
echo\n\
echo \"QTDIR=\" \$QTDIR\n\
echo \"KDEDIR=\" \$KDEDIR\n\
echo \"PATH=\" \$PATH\n\
echo" > .build-config


    chmod +x .build-config
    mkdir inst home build src
    echo "Done.."
}
