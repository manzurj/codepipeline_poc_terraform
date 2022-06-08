from botocore.exceptions import ClientError
from datetime import datetime
import boto3
import logging, json

# Instantiate logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instantiate boto3 client
client = boto3.client('rds')

def lambda_handler(event, context):
    action = event.get('action')

    try:
        if action is None:
            action = ''

        # Check action
        if action.lower() not in ['start', 'stop']:
            logger.error("ERROR: Unknown action, only 'start' and 'stop' are valid.")
            
        if action.lower() ==  'stop':
            get_instances = client.describe_db_instances()
            for instance in get_instances["DBInstances"]:
                if instance["DBInstanceStatus"] == 'available':
                    DBInstanceArn = instance["DBInstanceArn"]
                    logger.info("The instance {} is available".format(DBInstanceArn))
                    get_tags = client.list_tags_for_resource(ResourceName=instance["DBInstanceArn"])
                    for tag in get_tags['TagList']:
                        if 'Auto-StartStop-Enabled' in tag['Key'] and tag['Value'] == 'true':
                            DBInstanceIdentifier =  instance["DBInstanceIdentifier"]
                            SnapshotPrefix = "autostop"
                            time_stamp = datetime.today().strftime('%d-%m-%Y-%H-%M')
                            logger.info("The Instance {} will be stopped".format(DBInstanceIdentifier))
                            stop_instance = client.stop_db_instance(
                                DBInstanceIdentifier='{}'.format(DBInstanceIdentifier),
                                DBSnapshotIdentifier='{}-{}'.format(SnapshotPrefix, time_stamp)
                                )
                            response = json.dumps(stop_instance, sort_keys=True, default=str)
                            logger.info(response)
                            return response

        if action.lower() ==  'start':
            get_instances = client.describe_db_instances()
            for instance in get_instances["DBInstances"]:
                if instance["DBInstanceStatus"] == 'stopped':
                    DBInstanceArn = instance["DBInstanceArn"]
                    logger.info("The Instance {} is stopped".format(DBInstanceArn))
                    get_tags = client.list_tags_for_resource(ResourceName=instance["DBInstanceArn"])
                    for tag in get_tags['TagList']:
                        if 'Auto-StartStop-Enabled' in tag['Key'] and tag['Value'] == 'true':
                            DBInstanceIdentifier =  instance["DBInstanceIdentifier"]
                            logger.info("The Instance {} will be started".format(DBInstanceIdentifier))
                            start_instance = client.start_db_instance(
                                DBInstanceIdentifier='{}'.format(DBInstanceIdentifier)
                                )
                            response = json.dumps(start_instance, sort_keys=True, default=str)
                            logger.info(response)
                            return response

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