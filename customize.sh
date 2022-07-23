##########################################################################################
#
# Hi-Res Audio Patcher Config Script
#
##########################################################################################

ui_print " "
ui_print "    Initializing ..."
ui_print " "
# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print "*********************************************"
ui_print "  ID=$MODID"
ui_print "  Version=$MODVER"
ui_print "  VersionCode=$MODVERCODE"
ui_print "  MagiskVersion=$MAGISK_VER"
ui_print "  MagiskVersionCode=$MAGISK_VER_CODE"
ui_print "*********************************************"
ui_print " "

# sepolicy.rule

if [ "$BOOTMODE" != true ]; then
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi
FILE=$MODPATH/sepolicy.sh
DES=$MODPATH/sepolicy.rule
if [ -f $FILE ] && [ "`grep_prop sepolicy.sh $OPTIONALS`" != 1 ]; then
  mv -f $FILE $DES
  sed -i 's/magiskpolicy --live "//g' $DES
  sed -i 's/"//g' $DES
fi

# .aml.sh
ui_print "~   Patching files..."
mv -f $MODPATH/aml.sh $MODPATH/.aml.sh
ui_print "~   Done"
ui_print " "

# cleaning
ui_print "~   Cleaning up..."
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "

# permission
ui_print "~   Setting permissions..."
DIR=`find $MODPATH/system/vendor -type d`
for DIRS in $DIR; do
  chown 0.2000 $DIRS
done
ui_print " "
