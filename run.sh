#!/bin/bash

MONGO_BACKUP_HOST='rs0/db1:27017,db2:27017,db3:27017'
USER_NAME='admin'
USER_PASSWORD='AdminPassword2017'
MAX_BACKUPS=5

BACKUP_CMD="mongodump --out /var/backup_one_hour/"'${BACKUP_NAME}'" --host "${MONGO_BACKUP_HOST}" --username ${USER_NAME} --password ${USER_PASSWORD}"

echo "=> Creating backup script"
rm -f /backup.sh
cat <<EOF >> /root/backup.sh
#!/bin/bash
MAX_BACKUPS=${MAX_BACKUPS}
BACKUP_NAME=\$(date +\%Y.\%m.\%d.\%H\%M\%S)
echo "=> Backup started"
if ${BACKUP_CMD} ;then
    echo "   Backup succeeded"
else
    echo "   Backup failed"
    rm -rf /var/backup_one_hour/\${BACKUP_NAME}
fi
if [ -n "\${MAX_BACKUPS}" ]; then
    while [ \$(ls /var/backup_one_hour/ -N1 | wc -l) -gt \${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=\$(ls /var/backup_one_hour/ -N1 | sort | head -n 1)
        echo "   Deleting backup \${BACKUP_TO_BE_DELETED}"
        rm -rf /var/backup_one_hour/\${BACKUP_TO_BE_DELETED}
    done
fi
echo "=> Backup done"
EOF
chmod +x /root/backup.sh

touch /var/log/mongo_backup.log
tail -F /var/log/mongo_backup.log &

if [ -z "$1" ]; then
   
    echo "${CRON_TIME_ONE_HOUR}  /bin/bash /root/backup.sh >> /var/log/mongo_backup.log 2>&1" >> /root/crontab.conf
    echo "${CRON_TIME_TWO_HOUR}  rsync -avz --delete /var/backup_one_hour/ /var/backup_two_hour/ >> /var/log/mongo_backup_rsync.log 2>&1" >> /root/crontab.conf
    
    crontab  /root/crontab.conf
    echo "=> Running cron job"
    exec cron -f
else
    exec /$1.sh
fi
