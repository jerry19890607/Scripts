#!/bin/sh

codebase=$1
build_date="$(date +%Y%m%d)"
codebase_root=/home/jerry/ssd/codebase
folder_name="autobuild_$build_date"
codebase_name=$codebase"_autobuild_"$build_date
copy_codebase_cmd="cpyCodebase.sh $codebase"
build_script_file=/home/jerry/codebase/Pure/forAutoBuild
build_script="aa_$codebase.sh"
build_patch=$codebase"_build.patch"

if [ "$#" -ne 1 ]; then
    echo "Input parameters ERROR!"
    exit
fi

if [ $(uname -i) == "x86_64" ]; then
    echo "AST2600 build code server"
    if [ $codebase != "x12" ]; then
        echo "This build code server(x64) only support x12 codebase"
        exit
    fi
    build_machine=2600
elif [ $(uname -i) == "i686" ]; then
    echo "AST2500 build code server"
    if [ $codebase != "x12" ] && [ $codebase != "x11" ]; then
        echo "This build code server(x32) only support x11 or x12 codebase"
        exit
    fi
    build_machine=2500
else
    echo "Get build code server env ERROR!!"
    exit
fi

# Mkdir the folder
if [ ! -d $codebase_root/$folder_name ]; then
    echo "Create floder $codebase_root/$folder_name"
    mkdir -p $codebase_root/$folder_name
    if [ $? -ne 0 ]; then
        echo "Create codebase folder ERROR!"
        exit
    fi
fi

# Copy codebase
cd $codebase_root/$folder_name
$copy_codebase_cmd
if [ $? -ne 0 ]; then
    echo "Copy pure codebase to $codebase_root/$folder_name ERROR!!"
    exit
fi
mv $codebase $codebase_name


# Pull latest src code
cd $codebase_root/$folder_name/$codebase_name
git clean -xdf
GitPullToLatest.sh

# Copy build script and start build
cp $build_script_file/$build_script $codebase_root/$folder_name/$codebase_name/

if [ $build_machine -eq 2500 ]; then
    cp $build_script_file/$build_patch $codebase_root/$folder_name/$codebase_name/
    git apply $build_patch
    if [ $? -ne 0 ]; then
        echo "Git apply $build_patch ERROR!!"
        exit
    fi
fi
sh $build_script

<<'###BLOCK-COMMENT'
###BLOCK-COMMENT





