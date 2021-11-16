#!/bin/bash
#
# A simple script that archives the full source of the current repository.
#

if [[ ! -d $PWD/.git ]]; then
    echo >&2 "The current directory is not a Git repository!"
    exit 1
fi

# A bunch of binary paths to some of the used utilies.
TAR_BIN=/bin/tar
GIT_BIN=/usr/bin/git
FIND_BIN=/usr/bin/find
SED_BIN=/bin/sed

# Some other standard system utilities.
CP_BIN=/bin/cp
MKDIR_BIN=/bin/mkdir
RM_BIN=/bin/rm

# The path to the temp directory.
TMP_DIR=/tmp

# Fetch the package name and version using Git.
TAR_PN=`basename \`${GIT_BIN} rev-parse --show-toplevel\``
TAR_PV=`${GIT_BIN} describe --tags --abbrev=0 | ${SED_BIN} 's/v//g'`

TAR_P="${TAR_PN}-${TAR_PV}"

# Force the Git submodule to be updated recursively.
echo "Updating Git submodules..."
${GIT_BIN} submodule update --init --recursive

echo "Creating temporary directory..."

# Create a temporary directory and copy the repository's
# contents there.
${MKDIR_BIN} -p ${TMP_DIR}/${TAR_P}
${CP_BIN} -r $PWD/* ${TMP_DIR}/${TAR_P}

echo "Cleaning up temporary directory..."

# Navigate to the new directory in the temporary directory.
# Let's clean up the .git folders and this itself.
pushd ${TMP_DIR}/$TAR_P >/dev/null
	${FIND_BIN} . -name .git -type d -exec "${RM_BIN}" -rf {} +
    ${RM_BIN} -rf $0
popd >/dev/null

echo "Archiving cleaned up directory..."

# Navigate to one level above the previously created
# directory and tar the cleaned up directory.
pushd ${TMP_DIR} >/dev/null
    ${TAR_BIN} -czf ${TAR_P}.tar.gz ${TAR_P}
popd >/dev/null

# Copy the created tar to the current working directory.
${CP_BIN} ${TMP_DIR}/${TAR_P}.tar.gz $PWD
echo "Done! The archive has been copied to '${PWD}/${TAR_P}.tar.gz'"

