# terraform-example
Using terraform, a application load balancer is connected to a rds via ec2 instances within a autoscaling group

I have tried my best to comeplete the task within the time specifed but I have encountred multiple problems from my end. I could not get the code to full run and would still need to work on it in order to produce a fully working verison. I would appreciate if you could take this into account.

you can use the terraform output command to retrieve the load balancers DNS name.

you would need to make sure aspects that change from on a daily basis such as instance id are not hard coded into the tf files.
the code will need to cater towards scalability. monitoring is also an importsant factor making sure the any issues with from aws side can be seen from the pipeline logs.
security should also be of concern so the pipeline should be configured with appropriate security measures to protect the application and data.
