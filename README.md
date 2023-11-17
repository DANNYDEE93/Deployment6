## <ins>Deployment 6: Automating Retail Banking App Infrastructure in Two Regions using Terraform & Jenkins</ins>
_________________________________________________
##### Danielle Davis
##### November 16, 2023
________________________________________________
### <ins>PURPOSE:</ins>
__________________________________________________
&emsp;&emsp;&emsp;&emsp;	To utilize Terraform to automate the creation of my infrastructure to automate the deployment of a retail banking application in 2 different regions and 4 different availability zones, increasing my fault tolerance compared to my previous deployments. I created this infrastructure through a Jenkins agent infrastructure with a manager and agent server freeing up the resources from our main server and using SSH to connect my repo with the necessary files with Flask, Gunicorn, and my sqlite database file to my agent node with Terraform installed on it. In effect, this agent can be used to automate my deployment when building my Jenkins pipeline because it was able to use terraform and apply my code to automatically build upon a successful competion of my terraform stages. 

_________________________________________________________
### <ins>Description:</ins>
__________________________________________________________

&emsp;&emsp;&emsp;&emsp; In the Jenkins infrastructure, I used the Jenkins software, the latest version of python through Deadsnakes PPA, and Java environment so that the agent servers could recognize ane be compatible with the Jenkins main server. The agent node is operated by the Jenkins main server to use terraform and import Flask for development and install Gunicorn on the agent servers. Instead of using commands to establish an SSH connection in the Jenkinsfile, I accessed the SSH connection through the Jenkins agent nodes. Once installed on my Ubuntu server, the agent nodes become Linux-based using Flask (python framework) to develop and Gunicorn to deploy my Python web application. 
&emsp;&emsp;&emsp;&emsp; With the use of an RDS Database, I created a 2 tier by separating my database server from my application server with 3 logical layers -- the application servers dually acted as the web server with Gunicron running as a daemon process on the application server. Building my infrastructure across 2 servers in 2 different VPC's across two regions of "us-east-1" and "us-west-2" and having a server in 4 different AZ's decreased the risk of having a single point of failure and building infrastructure as code makes it easily replicable to scale as needed. 

 _________________________________
### <ins>ISSUES:</ins>
__________________________________
* Terraform: I kept running into an issue of not being able to push my repo changes back to GitHub because my files were too large no matter what I tried. In the end, the only thing that worked for me was to git clone the repo into a new directory and copy the files individually. I also had to use an alias for each resource block pertaining to each region before my code worked. 

* Deployment: I didn't realize that Jenkins was using terraform for my agent server and I was creating the app infrastructure manually without my code but it ended up helping me confirm my terraform files were correct. 
________________________________________________________________________________

### <ins> **STEPS FOR WEB APPLICATION DEPLOYMENT** </ins>

_________________________________________________________________________________
### Step 1: Diagram the infrastructure for Web Application Deployment
_________________________________________________________________________________


_____________________________________________________________________________
### Step 2: Create a terraform file:
__________________________________________________________________________

* Utilized Terraform on VS code and Git to push my changes to my remote GitHub repo. added my GitHub URL in my .git config file to give the code editor permission to push changes to my remote repo on GitHub. I created my Jenkins infrastructure through my [main.tf](Jenkins Infrastructure/main.tf) file, and included my scripts to download the applications of [Jenkins](Setup_files/jenkins-deadsnakes.sh) on the Jenkins manager server and [Terraform](Setup_files/terraform-java.sh) on my agent server within my default VPC making my staging environment outside of the application infrastructure's VPC, further reducing resource contention and increasing reliability.

<ins>intTerraform Directory:</ins>

* <ins>Created a second [main.tf](initTerraform/main.tf) file for the application infrastructure to fully deploy my application after running myJenkins pipeline. The user data necessary for clients to access my application across all 4 servers was automatically installed upon creation through Terraform with my software script:</ins>

 	</ins>My main.tf file created an infrastructure with 1 VPC in "us-east-1" and 1 VPC in "us-west-2" creating high redundancy and included:</ins>
  *2 AZ's
  
  *2 Public Subnets
  
  *2 EC2's
  
  *1 Route Table*
  
  *Security Group Ports: 22 (for SSH connection between the Jenkins manager and agent nodes/servers) and 8000 (for our app to use Gunicorn as a production web server)*

  *1 Application Load Balancer (distributes traffic load across all four of my servers):* Indirectly lowering latency and increased throughput by improving the performance of my infrastructure and increasing availability to users so that my servers don't get	overwhelmed with requests.
  
* </ins>Running my [software.sh](Setup_files/software.sh) across all my servers allowed me to save time from separately downloading my app's dependencies on each server:</ins>

  	<ins>Along with installing the latest version of Python and the virtual environment, it downloaded my GitHub repo and installs the necessary dependencies in my repo's directory:</ins>
  		* pip install -r requirements.txt *(ensures that the necessary Python packages and dependencies specified in the file are installed for my virtual environment)*
  		* pip install -y gunicorn *(automatically confirms and installs Gunicron web server)*
  		* pip install -y mysqlclient *(automatically installs client library necessary for my sqlite database)*
  		* python -m gunicorn app:app -b 0.0.0.0 -D *(runs the Gunicorn server and binds it to all available network interfaces attached to my VPC, specify entrypoint and endpoint for the application, and runs Gunicorn as a daemon process)*

<ins>**Configure RDS Database**</ins>
__________________________________________________________________________
* Using the AWS RDS Database allowed me to separate my data logical layer from my application servers to reduce resource contention for processing power (CPU, RAM, MEM). 
* This **AWS-managed service** allowed me not to focus on mt data configurations without worrying about the operation of the data layer.
  
* </ins>In order for my RDS Database to manage and store my data, I manually edited my database files:</ins>

"DATABASE_URL = 'mysql+mysqldb://**admin:abcd1234**@**mydatabase.c8zeygvvghbp.us-east-1.rds.amazonaws.com**/**banking**?charset=utf8mb4"

**username and password** I made when i gave my RDS Database some configuration for additional security on the database which helps to block users from accessing sensitive information 
**endpoint** to locate the database system where my sqlite database file will not be stored and rused to return data being requested by a client
**RDS Database name** to connect and store my database files in the managed service
  
**Database files**: *[load_data.py](load_data.py)*: utilized SQL to grab data from the database along with Flask and Bcrpyt for flexibility of rest API's and microservices, as well as, password encryption, and loads data to return it back to the client, *[database.py](database.py)*: utilizes SQL to organize and structure the data into tables; stores proprietary information such as account numbers and transactions of account holders, *[app.py](app.py)*: utilizes Flask for generating the web page, uses SQL Alchemy to connect with SQLite database, and uses rest APIs to render necessary information for customers, accounts, transactions, etc. of a banking web application.

________________________________________________
### Step 3: Jenkins Staging Environment
__________________________________________________________

* The Jenkins server, accessible through port 8080, was particularly important in the optimization and error handling of the deployment.
* Create Jenkins **Multibranch Pipeline** to build staging environment: Find instructions to access Jenkins in the web browser, create a multibranch pipeline, and create a token to link the GitHub repository with the application code to Jenkins. "Pipeline keep running plugin" is used to run the Jenkins build for as long as the applicaiton is up and running on the servers. I also provided my AWS credentials to give Jenkins permission to access my AWS servers and run on my Jenkins pipeline.

<ins> **[Jenkinsfile](https://github.com/DANNYDEE93/Deployment6/blob/main/Jenkinsfile):** </ins>

<ins> ***Build & Test(Validation) Stage:** </ins> 

*Prepares python(-venv) virtual environment by installing a python-pip package and python requirements, and uses load_data.py file to load the sampe data*
*Activates python -venv, installs and runs pytest for testing and archiving log reports in a JUnit results file* 
*Installs mySQLclient to use the data from the database.py file*

<ins>>**Terraform stages:** </ins> 

* Automated the execution of my infrastructure through *Init, Plan, Apply*:

*Terraform init: to initialize terraform and the backend configurations*
*Terraform validate: to validate that the terraform file is configured properly*
*Terraform plan: to show exactly what will be created when applied*
*Terraform apply: to execute infrastructure script*

___________________________________________________________________________
### Step 4: Gunicorn Production Environment
__________________________________________________________________________

* Gunicorn acts as my application's production web server running on port 8000 through the software script installed on the 4 application servers. The flask application, installed through the app.py and load_data.py database files, uses Python with Gunicorn to create a framework or translation of the Python function calls into HTTP responses so that Gunicorn can access the endpoint which, in this case, is my web application HTTPS URL provisioned through my load balancer. Eith Gunicorn running as a background process allows me to easily manage and enhance the reliability of my app because even if the terminal is closed, the web application can still run allowing for zero downtime for clients and users. The daemon process helps isolate connections within my app so different components can be modified without being affected all at once. It also add a level of security because it is harder for people with proper permissions to accidentally make unwanted modifications to the servers processes.
* The Jenkins agent node separates the responsibility on my Terraform agent server so the main server can focus on configurations and the **Pipeline Keep Running Steps** plugin, while the agent servers do the actual building of the application to handle configuration drift. 
* The Jenkins manager server delegates work to the agent node making it easier to scale my builds across multiple machines when necessary to handle resource contention and increase performance. Agent nodes also continuously run builds so if my main server goes down, the application can still initialize for deployment. Utilizing agent nodes is essentially installing a virtual machine on my EC2 instances which increases allotted CPU, RAM, and MEM resources to increase the speed of my running processes when deploying my application.
* My load balancer is essential in this deployment because it can properly distribute traffic evenly across my 4 application servers, aids in lowering latency and downtime. Having more servers for users, allows my servers more capacity to ensure proper configuration of the necessary applications and dependencies to deploy the application and in return creates a positive user experience.
* My RDS Database ensures less performance issues from running out of disk space as new data is stored from uaers accessing my application.
  
_________________________________________________
### <ins>OPTIMIZATION:</ins>
_____________________________________________

* AWS Route 53 is a scalable domain name system (DNS) managed web service that operates at the app layer and provides health checks, traffic routing policies, and SSL certificate management. The system used along with my load balancer could help increase my productivity around traffic management. 
* Including private subnet for the application/ Jenkins server to increase security and availability by protecting my Jenkins application server from unauthorized access.
* Implementing Terraform modules(reusable infrastructure definitions to reduce error and increase efficiency). 
* Including "aws_autoscaling_policy" resource in Terraform or utilize Kubernetes' autoscaler component to scale up or down as needed (ex. when resources like CPU reach a certain utilization), detect unhealthy instances and replace them, and automate recovery by redeploying failed instances. 
* Create webhook throguh GitHub or Kubernetes to automatically trigger Jenkins build when there are changes to my GitHub repository to detect if any changes disrupt or optimize my deployment, reduce the risk of latency, and fix bugs for faster deployments. Additonally, I could use Lambda to potentially record any changes to my repo as an event that can trigger the function to run a new build in my Jenkins pipeline. 
