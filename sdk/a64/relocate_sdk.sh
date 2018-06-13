#!/bin/bash

# Configures
# ------------------------------------------------------------------
SUDO_EXEC=""
SDK_ANCHOR_NAME="$SDK_ROOT/current-sdk-location"

cur_sdk_dir=""

# Check if we need to relocate
function need_reloc()
{
    local cur_loc="" 
    local tgt_loc="$SDK_ROOT"

    if [ -e "$SDK_ANCHOR_NAME" ]; then
        cur_loc=$(cat $SDK_ANCHOR_NAME)
        #cecho "${cur_loc} -" "-${tgt_loc}"
        if [ "${cur_loc}" = "${tgt_loc}" ]; then
            return 0
        else
            cur_sdk_dir=${cur_loc}
            return 1
        fi
    else
        return 2
    fi
}

function save_loc()
{
    echo "$SDK_ROOT" > $SDK_ANCHOR_NAME
    return 0
}

# Check whether we need to do relocation
need_reloc
RELOC=$?
if [ $RELOC -eq 0 ]; then
    cecho "\tNo SDK relocation needed!"
    return 0
elif [ $RELOC -eq 2 ]; then
    cechoe "\tSDK location file: '$SDK_ANCHOR_NAME' is missing!! Aborting..."
    return 1
else
    cecho "\tNeed to do SDK relocation! Proceeding..."
fi

#return 0

# fix dynamic loader paths in all ELF SDK binaries
dl_path=$($SUDO_EXEC find -H $OECORE_NATIVE_SYSROOT/lib -name "ld-linux*")
if [ "$dl_path" = "" ]; then
    cechoe "\tRelocate script unable to find ld-linux.so. Abort!"
    return 1
fi

executable_files=$($SUDO_EXEC find -H $OECORE_NATIVE_SYSROOT -type f \
	\( -perm -0100 -o -perm -0010 -o -perm -0001 \) -printf "'%h/%f' ")

cecho "\tCalling relocate script to relocate the ELF binaries..."
cecho "\tThis needs to be done only once after you install or change the location of build folder."
cecho "\t\tOLD: ${cur_sdk_dir}"
cecho "\t\tNEW: $SDK_ROOT"
#-------------------------------------------------------------------
#$SDK_ROOT/relocate_sdk.py ${cur_sdk_dir} $SDK_ROOT $dl_path $executable_files
#if [ $? -ne 0 ]; then
#    cechoe "Relocate script failed. Abort!"
#    return 1
#fi
#-------------------------------------------------------------------
echo "#!/bin/bash" > $SDK_ROOT/_tmp_script_.sh
echo exec $SDK_ROOT/relocate_sdk.py ${cur_sdk_dir} $SDK_ROOT $dl_path $executable_files >> $SDK_ROOT/_tmp_script_.sh
$SUDO_EXEC chmod 755 $SDK_ROOT/_tmp_script_.sh
$SUDO_EXEC $SDK_ROOT/_tmp_script_.sh
if [ $? -ne 0 ]; then
    cechoe "\tRelocate script failed. Abort!"
    rm $SDK_ROOT/_tmp_script_.sh
    return 1
fi
rm $SDK_ROOT/_tmp_script_.sh
#-------------------------------------------------------------------

# replace original prefix with the new prefix in all text files: configs/scripts/etc
$SUDO_EXEC find -H "$OECORE_NATIVE_SYSROOT" -type f -exec file '{}' \; | \
    grep ":.*\(ASCII\|script\|source\).*text" | \
    awk -F':' '{printf "\"%s\"\n", $1}' | \
    grep -v "$SDK_ROOT/environment-setup-*" | \
    $SUDO_EXEC xargs -n32 sed -i -e "s:${cur_sdk_dir}:$SDK_ROOT:g"

# change all symlinks pointing to ${cur_sdk_dir}
for l in $($SUDO_EXEC find -H $OECORE_NATIVE_SYSROOT -type l); do
    $SUDO_EXEC ln -sfn $(readlink $l|$SUDO_EXEC sed -e "s:${cur_sdk_dir}:$SDK_ROOT:") $l
done

# find out all perl scripts in $OECORE_NATIVE_SYSROOT and modify them replacing the
# host perl with SDK perl.
for perl_script in $($SUDO_EXEC find -H $OECORE_NATIVE_SYSROOT -type f -exec grep -l "^#!.*perl" '{}' \;); do
    $SUDO_EXEC sed -i -e "s:^#! */usr/bin/perl.*:#! /usr/bin/env perl:g" -e \
        "s: /usr/bin/perl: /usr/bin/env perl:g" $perl_script
done

# Save current location into a anchor file
save_loc

cecho "\tReloction done!"

return 0


