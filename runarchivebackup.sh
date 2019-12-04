
MYNAME="$0"
MYDIR=`dirname $0`

. $MYDIR/postgre.env

DATE_STR="`date +%Y-%m%d-%H%M-%S`"

BACKUP_MARKFILE_BASE="BACKUP_MARK_FILE";
BACKUP_MARKFILE=$ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}-$DATE_STR

echo "execute archive backup : mark_file is $BACKUP_MARKFILE"

touch $BACKUP_MARKFILE
if [ "$?" -ne 0 ]; then
	echo "ERROR: can't touch mark_file : $BACKUP_MARKFILE"
	echo "       check this file or directory permission"
	exit 1;
fi

MARKFILE_NUM="`ls -1 $ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}* |wc -l`"
if [ "$MARKFILE_NUM" -le 1 ]; then
	echo "FIRST run : touch -t 190001010101 $ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}-OLDEST"
	touch -t 190001010101 $ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}-OLDEST
fi

LAST_MARKFILE="`ls -t $ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}* |head -1`"
PREV_MARKFILE="`ls -t $ARCHIVE_DIR/${BACKUP_MARKFILE_BASE}* |head -2 |tail -1`"

echo "last:$LAST_MARKFILE"
echo "prev:$PREV_MARKFILE"

exit 0;

