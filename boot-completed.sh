#!/system/bin/sh
MODDIR=/data/adb/modules/susfs4ksu
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
source ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/susfs4ksu
tmpfolder=/debug_ramdisk/susfs4ksu
logfile="$tmpfolder/logs/susfs.log"

hide_cusrom=0
hide_gapps=0
hide_revanced=0
[ -f $PERSISTENT_DIR/config.sh ] && source $PERSISTENT_DIR/config.sh

# echo "hide_cusrom=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_cusrom = 1 ] && {
	echo "susfs4ksu/boot-completed: hide_cusrom" >> $logfile
	for i in $(find /system /vendor /system_ext /product -iname *lineage* -o -name *crdroid* ) ; do 
		${SUSFS_BIN} add_sus_path $i 
		echo "susfs4ksu/boot-completed: adding sus_path $i" >> $logfile
	done
}

# echo "hide_gapps=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_gapps = 1 ] && {
	echo "susfs4ksu/boot-completed: hide_gapps" >> $logfile
	for i in $(find /system /vendor /system_ext /product -iname *gapps*xml -o -type d -iname *gapps*) ; do 
		${SUSFS_BIN} add_sus_path $i 
		echo "susfs4ksu/boot-completed: adding sus_path $i" >> $logfile
	done
}

# echo "hide_revanced=1" >> /data/adb/susfs4ksu/config.sh
[ $hide_revanced = 1 ] && {
	echo "susfs4ksu/boot-completed: hide_revanced" >> $logfile
	count=0 
	max_attempts=15 
	until grep "youtube" /proc/self/mounts || [ $count -ge $max_attempts ]; do 
	    sleep 1 
	    ((count++)) 
	done
	packages="com.google.android.youtube com.google.android.apps.youtube.music"
	hide_app () {
		for path in $(pm path $1 | cut -d: -f2) ; do 
		${SUSFS_BIN} add_sus_mount $path && echo "susfs4ksu/boot-completed: adding sus_mount $i" >> $logfile
		${SUSFS_BIN} add_try_umount $path 1 && echo "susfs4ksu/boot-completed: adding add_try_umount $i" >> $logfile
		done
	}
	for i in $packages ; do hide_app $i ; done 
}


if [ -f $tmpfolder/logs/susfs_active ] ; then
	description="description=status: ✅ SuS ඞ "
else
	description="description=status: failed 💢 - Make sure you're on a SuSFS patched kernel! 😭"
	touch ${MODDIR}/disable
fi
sed -i "s/^description=.*/$description/g" $MODDIR/module.prop


