
MYNAME="$0"
MYDIR=`dirname $0`

. $MYDIR/postgre.env

DATE_STR="`date +%Y-%m%d-%H%M-%S`"

BACKUP_DIR=$BACKUP_BASE_DIR/$DATE_STR

echo "execute backup into $BACKUP_DIR"
pg_basebackup -x -D $BACKUP_DIR

