___

In this step, you will use a CloudFormation (CFN) template to deploy the infrastructure for this database migration. [AWS CloudFormation](https://aws.amazon.com/cloudformation/)  simplifies provisioning the infrastructure, so we can concentrate on tasks related to data migration.

5.  Open the AWS CloudFormation [console](https://console.aws.amazon.com/cloudformation/) , and click on **Create Stack** in the left-hand corner.

![[create-stack]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/EnvConfig04.png)

6.  Select Template is ready, and choose Upload a template file as the source template. Then, click on **Choose file** and upload the [DMSWorkshop.yaml](https://static.us-east-1.prod.workshops.aws/public/0a1fe388-e85b-4514-a911-559741a452a0/static/DMSWorkshop.yaml) . Click **Next**.

![[add-template]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/EnvConfig05.png)

7.  Populate the form as with the values specified below, and then click **Next**.

| **Input Parameter** | **Values** |
| --- | --- |
| **Stack Name** | A unique identifier without spaces. |
| **MigrationType / Lab Type** | Database that you want to migrate (Oracle or SQL Server). |
| **EC2ServerInstanceType** | An Amazon EC2 Instance type from the drop-down menu. Recommend using the default value. |
| **KeyName** | The KeyPair (DMSKeypair) that you created in the previous step. |
| **RDSInstanceType** | An Amazon RDS Instance type from the drop-down menu. Recommend using the default value. |
| **VpcCIDR** | The VPC CIDR range in the form x.x.x.x/16. Defaults to 10.20.0.0/16 |
| **IAMRoleDmsVpcExist** | Does your AWS account already have dms-vpc-role(goto IAM>roles & search for "dms-vpc" to check) if this role is not there template will fail-rollback unless you change default Y to N? |

The resources that are created here will be prefixed with whatever value you specify in the Stack Name. Please specify a value that is **unique** to your account.

![[input-parameters]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/CloudFormation-Stack-parameters.png)

8.  On the **Stack Options** page, accept all of the defaults and click **Next**.
    
9.  On the **Review** page, click **Create stack**.
    

![[review-stack]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/CloudFormation-Stack-create.png)

10.At this point, you will be directed back to the CloudFormation console and will see a status of **CREATE\_IN\_PROGRESS**. Please wait here until the status changes to **COMPLETE**.

![[stack-progress]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/CloudFormation-Stack-MyDMSTest-build.png)

11.Once CloudFormation status changes to **CREATE\_COMPLETE**, go to the **Outputs** section.

12.Make a note of the **Output** values from the CloudFormation environment that you launched as you will need them for the remainder of the tutorial:

![[dms-cft-output]](AWS%20DMS%20workshop%20for%20immersion%20days(AWS%20database%20migration%20workshop)/CloudFormation-Stack-MyDMSTest-output.png)

___