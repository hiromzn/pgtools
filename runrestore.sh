
MYNAME="$0"
MYDIR=`dirname $0`

. $MYDIR/postgre.env

backupdir="$1"

blabelf=$backupdir/backup_label
if [ ! -s "$blabelf" ]; then
	echo "ERROR: there is NOT $blabelf file"
	exit 1;
fi

DATE_STR="`date +%Y-%m%d-%H%M-%S`"

RESTORE_DIR=$BACKUP_BASE_DIR/${DATE_STR}-restore

echo "execute restore in $RESTORE_DIR"

echo "create $RESTORE_DIR"
mkdir -p $RESTORE_DIR

echo "copy newer WAL"
cp -pr $DATA_DIR/pg_xlog $RESTORE_DIR/

echo "backup current DB data"
mkdir $RESTORE_DIR/currentDB/
mv $DATA_DIR/* $RESTORE_DIR/currentDB/

echo "restore data"
cp -rp $backupdir/* $DATA_DIR

echo "remove old WAL"
rm -rf $DATA_DIR/pg_xlog/*

echo "setup newer WAL"
cp -pfr $RESTORE_DIR/pg_xlog/* $DATA_DIR/pg_xlog/

RCONF="recovery.conf"

echo "create $RCONF file"
cat <<EOF |tee $RESTORE_DIR/$RCONF >$DATA_DIR/$RCONF
restore_command = 'cp /data/archive/%f "%p"'
EOF

