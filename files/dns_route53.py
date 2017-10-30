#!/usr/bin/env python

import boto3, sys
from os.path import basename

client = boto3.client('route53')

name = sys.argv[0]
fqdn = sys.argv[1]
challenge = sys.argv[2]

bname = basename(name)
if bname == 'dns_add_route53':
    action = 'UPSERT'
elif bname == 'dns_del_route53':
    action = 'DELETE'
else:
    print("No such action: {a}".format(a=bname))
    sys.exit(1)

try:
    response = client.list_hosted_zones()
except Exception as e:
    print("Oops: {e!r}".format(e=e))
    sys.exit(1)

zone_id = ""
zone_list = dict()
for zone in response['HostedZones']:
    if not zone['Config']['PrivateZone']:
        zone_list[zone['Name']] = zone['Id']

for key in sorted(zone_list.iterkeys(), key=len, reverse=True):
    if key in "{z}.".format(z=fqdn):
       zone_id = zone_list[key]

if zone_id == "":
    print("We didn't find the zone")
    sys.exit(1)

try:
    response = client.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Comment': 'getssl/Letsencrypt verification',
            'Changes': [
                {
                    'Action': action,
                    'ResourceRecordSet': {
                        'Name': fqdn,
                        'Type': 'TXT',
                        'TTL': 300,
                        'ResourceRecords': [{'Value': "\"{c}\"".format(c=challenge)}]
                    }
                },
            ]
        }
    )
except Exception as e:
    print("Oops: {e!r}".format(e=e))
    sys.exit(1)
