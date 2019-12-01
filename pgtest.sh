
MYNAME="$0"
MYDIR=`dirname $0`

. $MYDIR/sql.env

usage()
{
cat <<EOF
usage : $0 command

  command:
	all | create ...... create test environment.
	clean | drop ...... delete test environment.

	pushdata .......... insert test data into table with infinity loop.
	push1 ............. insert 1 test data into table.
	insertdata <stime> <db> <table> 
		... insert test data into table of db with sleep_time.

	getlastdata ....... get last record.
	checkdata ......... check test data count.
EOF
}

main()
{
case "$1" in
all | create ) create_all ;;
clean | drop ) drop_all ;;

pushdata )
	insert_data_loop 0 $DB1 $TBL1
	;;
insertdata )
	insert_data_loop $2 $3 $4
	;;
push1 )
	insert_data $DB1 $TBL1
	;;
checkdata )
	check_data 3 $DB1 $TBL1
	;;
getlastdata )
	get_lastdata $DB1 $TBL1 5
	;;
* )
	usage;
	exit 1;
	;;
esac
}

check_data() # sleep_sec db_name table_name
{
sleep_sec="$1";
db_name="$2";
table_name="$3";

while true;
do
	count_data $db_name $table_name;
	sleep $sleep_sec;
done |grep -v -e 'count' -e '^---' -e 'row' -e '^$'
}

count_data() # db_name table_name
{
	db_name="$1";
	table_name="$2";

	psql -d $db_name <<EOF
select count(*) from $table_name;
EOF
}


insert_data_loop() # sleep_sec db_name table_name
{
sleep_sec="$1";
db_name="$2";
table_name="$3";

while true;
do
	echo "$table_name <==( $d, 'nano sec data');"

	insert_data $db_name $table_name;

	sleep $sleep_sec;
done |grep -v -e 'count' -e '^---' -e 'row' -e '^$' -e 'INSERT'
}

insert_data() # db_name table_name
{
	db_name="$1";
	table_name="$2";

	nsec=`date +%N`
	d=$nsec;

	psql -d $db_name <<EOF
	insert into $table_name values( $d, 'nano sec data');
	select count(*) from $table_name;
EOF
}

get_lastdata() # db_name table_name n
{
	db_name="$1";
	table_name="$2";
	n="$3";
	
	psql -d $db_name <<EOF
	select * from $table_name order by ins_time desc limit $n;
EOF
}

create_all()
{
psql <<EOF
create role "$USER1" with login inherit password '$PASS1';
create role "$USER2" with login inherit password '$PASS2';
create database $DB1 owner $USER1;
create database $DB2 owner $USER2;
EOF

psql -d $DB1 -U $USER1 <<EOF
create table $TBL1 (id serial primary key, comment text, ins_time timestamp default current_timestamp );
EOF

psql -d $DB2 -U $USER2 <<EOF
create table $TBL2 (id serial primary key, comment text, ins_time timestamp default current_timestamp );
EOF
}

drop_all()
{
psql <<EOF
drop database $DB1;
drop database $DB2;
drop role "$USER1";
drop role "$USER2";
EOF
}

main $*;

