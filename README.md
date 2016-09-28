## Microtrader ECS Base Image

This image is a derivative of the Amazon ECS-optimised AMI (currently version 2016.03.i). 

It adds the following modifications at build time:

1. Set server timezone to Pacific/Auckland
1. Perform a general package update then install additional useful packages (e.g. lsof, tcpdump, traceroute)
1. Set the Docker bridge interface subnet to a standard CIDR range (192.168.213.0/24)
1. Upload the [cfn-ecs.sh](files/cfn-ecs.sh) script to `/home/ec2-user` (see below for details)
1. Stop and disable the docker service, and clean up any docker logs or containers created during the build

### CloudFormation ECS Agent Check

The `/home/ec2-user/cfn-ecs.sh` script polls the [ECS agent metadata service](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-introspection.html) to determine if the ECS agent has successfully registered with an ECS cluster.

This is useful for ensuring EC2 instances are ready for ECS operation before signalling successful instance creation to CloudFormation.  The script expects the `CLUSTER_NAME` environment variable to be set to the ECS cluster that the ECS agent will register to.  You can also specify an optional `PAUSE_TIME` environment variable, which simply sleeps for the value of PAUSE_TIME in seconds before exiting and returning control to the CFN init process.  This is useful for EC2 autoscaling rolling update scenarios, where you want to provide enough time for an existing ECS service to be deployed to the agent before signalling success and continuing the rolling updates.

The following sample cfn-init metadata demonstrates how to correctly invoke the ECS agent check script::

```
# cfn_init must be specified to generate the correct userdata cfn boilerplate
Metadata:
  AWS::CloudFormation::Init:
    configSets:
      default:
        - 01_config
        - 02_config
    01_config:
      files:
        /etc/ecs/ecs.config:
          content: { "Fn::Join" : ["", ["ECS_CLUSTER=", { "Ref": "ApplicationCluster" }, "\n"] ] }
      services:
        sysvinit:
          awslogs:
            enabled: "true"
            ensureRunning: "true"
          docker:
            enabled: "true"
            ensureRunning: "true"
    02_config:
      commands:
        01_ecs_agent:
          command: "sh cfn-ecs.sh"
          env: 
            CLUSTER_NAME: { "Ref": "ApplicationCluster" }
            PAUSE_TIME: 60
          cwd: "/home/ec2-user/"
```

