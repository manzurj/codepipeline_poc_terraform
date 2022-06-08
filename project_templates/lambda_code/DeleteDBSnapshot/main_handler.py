from botocore.exceptions import ClientError
from datetime import datetime
import logging, time, json
import boto3

# Instantiate logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instantiate boto3 client
client = boto3.client('rds')

def lambda_handler(event, context):
    try:
        get_snapshots = client.describe_db_snapshots()
        DBSnapshots = get_snapshots["DBSnapshots"]
        for DBSnapshot in DBSnapshots:
            DBSnapshotIdentifier = DBSnapshot["DBSnapshotIdentifier"]
            if DBSnapshotIdentifier.startswith("autostop") == True:
                
                # Transform timestamp to unix time (epoch)
                # Ref.: https://en.wikipedia.org/wiki/Unix_time
                create_time = DBSnapshot["SnapshotCreateTime"]
                create_time_in_epoch = int(time.mktime(create_time.timetuple()))
                now = datetime.now()
                now_in_epoch = int(time.mktime(now.timetuple()))
                
                # Calculate the number of days between the snapshot creation day and the current day.
                delta_raw = ((create_time_in_epoch - now_in_epoch) / 86400)
                delta = int(delta_raw)
                logger.info("The time different is {}".format(delta))
                
                # Delete snapshot older that 5 days:
                if delta >= 5:
                    DBSnapshotIdentifier = DBSnapshot["DBSnapshotIdentifier"]
                    logger.info("The DB Snapshot {} will be deleted".format(DBSnapshotIdentifier))
                    delete_snapshot = client.delete_db_snapshot(
                        DBSnapshotIdentifier='{}'.format(DBSnapshotIdentifier)
                        )
                    delete_snapshot_response = json.dumps(delete_snapshot, sort_keys=True, default=str)
                    logger.info(delete_snapshot_response)
                    return delete_snapshot_response
                else:
                    logger.info("No DB Snapshot is older than 5 days")

    except ClientError as error:
        logger.error(error)
        return {
            'statusCode': 500,
            'response_from': 'Lambda',
            'body': error,
			'moreInfo': {
                'Lambda Request ID': '{}'.format(context.aws_request_id),
                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                'CloudWatch log group name': '{}'.format(context.log_group_name)
			}
        }