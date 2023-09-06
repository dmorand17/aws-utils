# create-drt

This script is used to create a datarepository task to release data.

This will not be needed once the EventBridge Scheduler is able to invoke the [CreateDataRepositoryTask](https://docs.aws.amazon.com/fsx/latest/APIReference/API_CreateDataRepositoryTask.html) API to release data.

## Usage

Add this script to a crontab (crontab -e)

Example to run at 3am

```
# m h dom mon dow command
0 3 * * * /home/ec2user/create-drt.sh <file_system_id> [days]
```

verify commands added

```
crontab -l
```
