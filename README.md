# terraform-vpc-dns-filtering-nat-instance

## Resources exaplained

### VPC
- 1 VPC - 10.193.0.0/16
- 2 public subnets - 10.193.0.0/24, 10.193.1.0/24
- 2 private subnets - 10.193.2.0/24, 10.193.3.0/24
- 1 internet gateway
- 5 route tables - 1 for VPC default, 2 for each public subnets, 2 for each private subnets
- 1 dhcp options set
- 1 Gateway endpoint - To access S3 via PrivateLink

### S3
- 1 S3 Bucket
- 1 S3 Bucket Policy - Allow VPC Endpoint access
- 1 S3 Bucket acl block - Block public access

### EC2
- 2 Instances on each Public subnet : Working as a proxy for private subnet instnace to access Public internet(Also working as a SSH bastion to access private subnet instance. I added for testing purpose)
- - Configured [Squid](http://www.squid-cache.org/) for proxy feature.
- - Perform domain whitelisting. Only allow access to https://*.google.com from Private instance.
- - For example, http://google.com will denied by Squid. But https://google.com will work.
- - I wanted Squid to perform redirect http request to https but currently not working as I intended.
- - (Need more research for Squid)
- 2 Instances on each Private subnet : Each instance can only access https://google.com
- - Caution : google.com will not work.

### References
AWS Blog (Originally implemented with AWS CloudFormation) - [How to add DNS filtering to your NAT instance with Squid](https://aws.amazon.com/ko/blogs/security/how-to-add-dns-filtering-to-your-nat-instance-with-squid/)
