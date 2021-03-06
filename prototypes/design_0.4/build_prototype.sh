#! /bin/bash

version="0.4"
testroot="$HOME/appltest/design_$version"
sourceroot="$HOME/LUMI-easybuild-prototype/prototypes/design_$version"

repo='SystemRepo'

workdir=$HOME/Work

#PATH=$sourceroot/..:$sourceroot:$PATH

if [[ "$(hostname)" =~ ^o[0-9]{3}i[0-9]{3}$ ]]
then
	system="Grenoble"
	echo "Identified the Grenoble test system."
elif [[ "$(hostname)" =~ ^uan0[0-9]$ ]]
then
	system="CSCS"
	echo "Identified the CSCS cluster."
else
	system="Unknown"
	echo "Could not identify the system, quitting."
	exit
fi

declare -A EB_version
case $system in
    Grenoble)
        demo_stacks=( '21.D.02.dev' '21.D.03.dev' '21.D.04' )
        EB_stacks=( '21.G.02.dev' '21.G.04' )
        EB_version['21.G.02.dev']='4.3.4'
        EB_version['21.G.04']='4.4.1'
        default_stack='21.G.04'
    ;;
	CSCS)
        #demo_stacks=( '21.D.02.dev' '21.D.03.dev' )
        demo_stacks=()
        #EB_stacks=( '21.04''21.05' '21.06' )
        EB_stacks=( '21.05.dev' '21.06' )
        EB_version['21.04']='4.4.1'
        EB_version['21.05.dev']='4.4.1'
        EB_version['21.06']='4.4.1'
        default_stack='21.06'
	;;
esac
partitions=( 'C' 'G' 'D' 'L' )

create_link () {

#  echo "Linking from: $1"
#  echo "Linking to: $2"
#  test -s "$2" && echo "File $2 found."
#  test -s "$2" || echo "File $2 not found."
  test -s "$2" || ln -s "$1" "$2"

}

#
# Make the support directories
#
mkdir -p $testroot

################################################################################
################################################################################
##
## FIRST PART: Shadow ${repo} directory
## For now, in the prototype we avoid to work directly in the repo as we
## do not want to set up a new repo for each prototype.
##
## However, in the release version this step is replaced by simply cloning the
## release repository.
##
################################################################################
################################################################################

mkdir -p "$testroot/$repo"

"$sourceroot/scripts/create_shadow.sh" "$testroot" "$repo"

PATH="$testroot/$repo/scripts:$PATH"

################################################################################
################################################################################
##
## SECOND PART: Toolchain-independent initializations
##
################################################################################
################################################################################

$testroot/${repo}/scripts/prepare_LUMI.sh

#
# Create and populate the directory with EasyBuild sources simply to avoid
# excess downloading while we can still erase the whole directory structure.
#
mkdir -p $testroot/sources/easybuild/e
mkdir -p $testroot/sources/easybuild/e/EasyBuild
cp $testroot/../sources/easybuild* $testroot/sources/easybuild/e/EasyBuild/


################################################################################
################################################################################
##
## THIRD PART: Install the EasyBuild toolchain(s)
##
##
################################################################################
################################################################################

for stack in "${EB_stacks[@]}"
do
    echo "Preparing software stack $stack..."
    $testroot/${repo}/scripts/prepare_LUMI_stack.sh "$stack" "${EB_version[$stack]}" "$workdir"
done


################################################################################
################################################################################
##
## FOURTH PART: Demo modules
## This is for the prototype only to be able to test certain aspects of the
## module tree without
##
##
################################################################################
################################################################################

if [ ${#demo_stacks[@]} -ge 2 ]
then
	$sourceroot/build_demo_modules.sh "$testroot" "$repo" ${demo_stacks[@]}
fi

################################################################################
################################################################################
##
## FIFTH PART: Finishing the whole construction of the prototype
##
##
################################################################################
################################################################################

#
# Create a modulerc file in the SoftwareStack subdirectory to mark the default software stack.
#
cat >$testroot/modules/SoftwareStack/LUMI/.modulerc.lua <<EOF
module_version( "LUMI/$default_stack", "default" )
EOF

#
# Instructions for the MODULEPATH etc
#
cat <<EOF


To enable LUMI prototype version $version, make sure LMOD is the
active module system and then run
eval \$(\$HOME/LUMI-easybuild-prototype/prototypes/design_$version/enable_prototype.sh)

Dummy demo modules are installed in ${demo_stacks[@]}

EasyBuild works in ${EB_stacks[@]}

EOF
