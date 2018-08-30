import boto3
import time
import pycurl
from io import BytesIO
import numpy
from threading import Thread, Lock

import os
#os.chdir(os.path.dirname(__file__))
path_directory = os.getcwd()
print('Current working directory is -', path_directory)

AWS_SHARED_CREDENTIAL_FILE = "../../credentials"
my_session = boto3.session.Session()
my_region = my_session.region_name
print('Region is {}'.format(my_region))
my_creds = my_session.get_credentials
print('Creds are {}'.format(my_creds))
print('Profile name is', my_session.profile_name)


lock = Lock()
headers_list = ['Accept: text/html,application/xhtml+xml,application/xml;q=0.9,;q=0.8',
                'Accept-Language: en-US,en;q=0.5',
                'Connection: keep-alive']

# a simple curl to GET or POST to server
# returns a 'failed' if the server is not available
# calculates the time from request to reply 
def get_http(ip_address='', set=1, request_time=0.0, file_path=None):
    buffer = BytesIO()
    http_curl = pycurl.Curl()
    http_curl.setopt(pycurl.URL, ip_address)
    http_curl.setopt(pycurl.HTTPHEADER, headers_list)
    http_curl.setopt(http_curl.WRITEDATA, buffer)
    http_curl.setopt(http_curl.FOLLOWLOCATION, True)
    http_curl.setopt(http_curl.TIMEOUT_MS, 50000)
    if file_path is not None:
        #print('\nTrying to POST', file_path, os.path.isfile(file_path))
        http_curl.setopt(http_curl.POST, 1)
        http_curl.setopt(http_curl.HTTPPOST, [("image", (http_curl.FORM_FILE, file_path))])
        
    try:
        http_curl.perform()
        http_curl.close()
        response = buffer.getvalue()
        elapsed_time = time.time() - request_time
    except:
        response = 'failed' + ip_address
        elapsed_time = 50.102

    if isinstance(response, str) and 'bad gateway' in response.lower():
        response = 'failed' + ip_address
        elapsed_time = 50.104
    elif not isinstance(response, str) and 'navailable' in response.decode('utf-8'):
        response = 'failed' + ip_address
        elapsed_time = 50.103
    
    with lock:
        if file_path is not None:
            results_POST[set].append((response, elapsed_time))
        else:
            results_GET[set].append((response, elapsed_time))
    print((response, elapsed_time))
    return

######################################################
# retrieve all running EC2 instances.
######################################################
IPs = set()
def get_targets():
    IPs_temp = set()
    IPs_temp.add(('sfaki.com', 'www.sfaki.com'))
    elb = boto3.client('elbv2')
    elbs = elb.describe_load_balancers()

    route53 = boto3.client('route53')

    do_route = False
    if do_route:
        hosted_zones = route53.list_hosted_zones()
        hosted_zones_list = hosted_zones['HostedZones']
        hosted_zone = hosted_zones_list[0]
        zone_id = hosted_zone['Id']    
        record_sets = route53.list_resource_record_sets(HostedZoneId=zone_id)
        zone_ips_dictionary = record_sets['ResourceRecordSets'][2]['ResourceRecords']
        for index, zone_ip in enumerate(zone_ips_dictionary):
            IPs_temp.add((index, zone_ip['Value']))


    if not len(IPs_temp) > 0 and len(elbs['LoadBalancers']) > 0:
        ip_address = elbs['LoadBalancers'][0]['DNSName']
        elb_name = elbs['LoadBalancers'][0]['LoadBalancerName']
        IPs_temp.add((elb_name, ip_address + ':5000'))


    # check to see if the IPs_temp is empty, as this will indicate whether or not an elb is present
    if not len(IPs_temp) > 0 or destruction_constant > 0: 
        ec2 = boto3.resource('ec2')
        instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        for instance in instances:
            if instance.state['Name']=='running':
                IPs_temp.add((instance.id, instance.public_ip_address + ':5000'))
    return IPs_temp
        



######################################################
# retrieve all VPCs.
######################################################
#vpcs = list(ec2.vpcs.filter(Filters=[{}]))
#print('Found {} VPCs'.format(len(vpcs)))
#print(vpcs)



######################################################
# retrieve all S3 buckets.
######################################################    
def get_s3():
    s3 = boto3.resource('s3')    # for resource interface  
    for bucket in s3.buckets.all():
        print(bucket.name)


def repeated_goes(time_interval, set_index, path=None):
    global destruction, IPs
    tock = time.time()
    tick = time.time()
    tock_sub = time.time()

    if path is not None:
        # get contents of directory for randomized selection of images
        image_options = os.listdir(path)
        num_images = len(image_options)
    instance_index = 0
    while tick-tock < 300: # 300       
        
        # clear and refresh the targets for uploading
        IPs.clear()
        IPs = get_targets()
        #instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        #for instance in instances:
        #    if instance.state['Name']=='running':
                #print('Adding to instance list\t\t', instance.public_ip_address, instance.state)
        #        IPs.add((instance.id, instance.public_ip_address + ':5000'))
        
        IP_list = list(IPs)        
        tick = time.time()

        if destruction > 0 and len(IPs) > 0:
            ec2 = boto3.resource('ec2')
            IPs_temp = []
            instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
            for instance in instances:
                if instance.state['Name']=='running':
                    IPs_temp.append((instance.id, instance.public_ip_address))
            random_destruction_index = numpy.random.randint(0, len(IPs_temp))
            i = ec2.Instance(id=IPs_temp[random_destruction_index][0])
            i.terminate(i)
            destruction-=1
            print('Destroying Instance\t\t', instance.public_ip_address, instance.state)
            #print(ec2.Instance(id=IP_list[random_destruction_index][0]).state)

        random = True
        if tick-tock_sub > time_interval:
            tock_sub = time.time()

            if not random:
                if len(IPs) > 1:
                    instance_index+=1
                    if instance_index == len(IPs):
                        instance_index = 0
                else:
                    instance_index = 0
            else:
                instance_index = numpy.random.randint(0, len(IPs))
                

            def worker2():
                IP_list = list(IPs)
                if len(IP_list) == 0:
                    with lock:
                        if path is not None:
                            results_POST[set_index].append(('no server', 50.101))
                        else:
                            results_GET[set_index].append(('no server', 50.101))
                    print('Server not available')
                elif path is not None:
                    image_index = numpy.random.randint(0, num_images)
                    get_http(IP_list[instance_index][1], set_index, tock_sub, path + image_options[image_index])
                else:
                    get_http(IP_list[instance_index][1], set_index, tock_sub)

            Thread(target=worker2).start()
            
        else:
            time.sleep(time_interval-(tick-tock_sub))

    



destruction_constant = 0
time_intervals = [2.0, 1.0, 0.5]

#time_intervals = [2.0]
results_GET = [[],[],[]]
results_POST = [[],[],[]]
images_directory = 'mura_images/'

for x, value in enumerate(time_intervals):
    print('starting GET for', value)
    destruction = destruction_constant
    repeated_goes(value, x)

    print('starting POST for', value)
    destruction = destruction_constant
    if os.listdir(images_directory) == 0:
        break
    repeated_goes(value, x, path=images_directory)
    time.sleep(120)

print('entering wait before printout')

tock=time.time()
tick=time.time()
while len(results_POST[-1]) < len(results_GET[-1]) and tick-tock < 300:
    time.sleep(1)
    tick=time.time()

    
for x, value in enumerate(time_intervals):
    print('\n\n\n')
    print('results\n\tGET\t\t\tPOST')
    for i in range(len(results_POST[x])):
        try:
            print(results_GET[x][i][1], '\t', results_POST[x][i][1])
        except:
            pass




