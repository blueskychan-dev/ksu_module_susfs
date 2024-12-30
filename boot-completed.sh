#!/system/bin/sh
MODDIR=/data/adb/modules/susfs4ksu
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
source ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/susfs4ksu
tmpfolder=/debug_ramdisk/susfs4ksu
logfile="$tmpfolder/logs/susfs.log"
logfile1="$tmpfolder/logs/susfs1.log"

hide_cusrom=0
hide_gapps=0
hide_revanced=0
[ -f $PERSISTENT_DIR/config.sh ] && source $PERSISTENT_DIR/config.sh

# update description
if [ -f $tmpfolder/logs/susfs_active ] || dmesg | grep -q "susfs:"; then
	description="description=status: ✅ SuS ඞ "
else
	description="description=status: failed 💢 - Make sure you're on a SuSFS patched kernel! 😭"
	rm -rf ${MODDIR}/webroot
	touch ${MODDIR}/disable
fi
sed -i "s/^description=.*/$description/g" $MODDIR/module.prop

# routines

# echo "hide_cusrom=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_cusrom = 1 ] && {
    echo "susfs4ksu/boot-completed: [hide_cusrom]" >> $logfile1
    
    # Find lineage and crdroid paths
    find /system /vendor /system_ext /product -type f -o -type d | grep -iE "lineage|crdroid" | while read -r path; do
        ${SUSFS_BIN} add_sus_path "$path"
        echo "[sus_path]: susfs4ksu/boot-completed $path" >> "$logfile1"
    done
}

# echo "hide_gapps=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_gapps = 1 ] && {
	echo "susfs4ksu/boot-completed: [hide_gapps]" >> $logfile1
	for i in $(find /system /vendor /system_ext /product -iname *gapps*xml -o -type d -iname *gapps*) ; do 
		${SUSFS_BIN} add_sus_path $i 
		echo "[sus_path]: susfs4ksu/boot-completed $i" >> $logfile1
	done
}

# echo "spoof_cmdline=1" >> /data/adb/susfs4ksu/config.sh
[ $spoof_cmdline = 1 ] && {
	echo "susfs4ksu/boot-completed: [spoof_cmdline]" >> $logfile1
	sed 's|androidboot.verifiedbootstate=orange|androidboot.verifiedbootstate=green|g' /proc/cmdline > /debug_ramdisk/susfs4ksu/cmdline
	${SUSFS_BIN} set_proc_cmdline /debug_ramdisk/susfs4ksu/cmdline
}

# echo "hide_revanced=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_revanced = 1 ] && {
	echo "susfs4ksu/boot-completed: [hide_revanced]" >> $logfile1
	count=0 
	max_attempts=15 
	until grep "youtube" /proc/self/mounts || [ $count -ge $max_attempts ]; do 
	    sleep 1 
	    ((count++)) 
	done
	packages="com.google.android.youtube com.google.android.apps.youtube.music"
	hide_app () {
		for path in $(pm path $1 | cut -d: -f2) ; do 
		${SUSFS_BIN} add_sus_mount $path && echo "[sus_mount] susfs4ksu/boot-completed: [add_sus_mount] $i" >> $logfile1
		${SUSFS_BIN} add_try_umount $path 1 && echo "[try_umount] susfs4ksu/boot-completed: [add_try_umount] $i" >> $logfile1
		done
	}
	for i in $packages ; do hide_app $i ; done 
} & # run in background
