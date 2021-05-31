#!/bin/sh

#   Author: JerryShih
#   Mail: JerryShih@supermicro.com
#   Usage:
#       . Symbolic to forAutoBuild_{codebase}
#       . mkdir /home/jerry/ssd/codebase


codebase=$1
key=$2
BRANCH=$3

build_date="$(date +%Y%m%d)"
build_month="$(date +%m)"
build_day="$(date +%d)"
codebase_root=/home/jerry/ssd/codebase
folder_name="AB_$build_date"
copy_codebase_cmd="cpyCodebase.sh $codebase"
build_script_file=/home/jerry/codebase/Pure/forAutoBuild
build_script="aa_$codebase.sh"
build_patch=$codebase"_build.patch"

usage () {
    echo ""
    echo -e "ABuildCode.sh usage:"
    echo -e "   ABuildCode.sh [x11|x12] [d|p] [Branch]"
}

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Input parameters ERROR!"
    usage
    exit
fi

#Default branch is MASTER if user doesn't assigned
if [ -z $BRANCH ]; then
    BRANCH="master"
fi

if [ $(uname -i) == "x86_64" ]; then
    echo "AST2600 build code server"
    if [ $codebase != "x12" ]; then
        echo "This build code server(x64) only support x12 codebase"
        usage
        exit
    fi
    build_machine=2600
    codebase_name=$codebase"_"$build_date"_"$key"_"$BRANCH
elif [ $(uname -i) == "i686" ]; then
    echo "AST2500 build code server"
    if [ $codebase != "x12" ] && [ $codebase != "x11" ]; then
        echo "This build code server(x32) only support x11 or x12 codebase"
        usage
        exit
    fi
    build_machine=2500
    codebase_name=$codebase"_"$build_date"_"$BRANCH
else
    echo "Get build code server env ERROR!!"
    exit
fi

if [ -d $codebase_root/$folder_name/$codebase_name ]; then
    echo "$codebase_name already exists!!"
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
if [ $? -ne 0 ]; then
    echo "Rename to $codebase_name ERROR!!"
    exit
fi


cd $codebase_root/$folder_name/$codebase_name

#Check out to branch
git co $BRANCH
if [ $? -ne 0 ]; then
    echo "Checkout $BRANCH ERROR!!"
    exit
fi

# Pull latest src code
git clean -xdf
GitPullToLatest.sh

# Copy build script and start build
cp $build_script_file/$build_script $codebase_root/$folder_name/$codebase_name/

cp $build_script_file/$build_patch $codebase_root/$folder_name/$codebase_name/
git apply $build_patch
if [ $? -ne 0 ]; then
    echo "Git apply $build_patch ERROR!!"
    exit
fi

# Change build version to 1.[Month].[Day]
sed -i "s/ver=1.0.0/ver=1.$build_month.$build_day/g" $build_script
if [ $? -ne 0 ]; then
    echo "Change build version ERROR!!"
    exit
fi

# Change build argument according debug or production key
if [ $build_machine -eq 2600 ]; then
    if [ $key == "d" ]; then
        sed -i 's/\(PRODUC_KEY=\).*/\10/' $build_script
    elif [ $key == "p" ]; then
        sed -i 's/\(PRODUC_KEY=\).*/\11/' $build_script
    else
        echo "Key type ERROR!!"
        exit
    fi
fi


sh $build_script
if [ $? -ne 0 ]; then
    echo ""
    echo "Build ERROR!!"
    echo ""
else
    echo ""
    echo "Build success!!"
    echo ""
fi

<<'###BLOCK-COMMENT'
###BLOCK-COMMENT
