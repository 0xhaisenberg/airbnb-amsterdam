### Prerequisites

The following requirements are needed to reproduce the project:
1. A [Google Cloud Platform](https://cloud.google.com/) account.
2. (Optional) The [Google Cloud SDK](https://cloud.google.com/sdk). Instructions for installing it are below.
	. Most instructions below will assume that you are using the SDK for simplicity.
3. (Optional) A SSH client.
	. All the instructions listed below assume that you are using a Terminal and SSH.
4. (Optional) VSCode with the Remote-SSH extension.
	. Any other IDE should work, but VSCode makes it very convenient to forward ports in remote VM's.

Development and testing were carried out using a Google Cloud Compute VM instance. I strongly recommend that a VM instance is used for reproducing the project as well. All the instructions below will assume that a VM is used.


## Create a Google Cloud Project

Access the [Google Cloud dashboard](https://console.cloud.google.com/) and create a new project from the dropdown menu on the top left of the screen, to the right of the Google Cloud Platform text.

After you create the project, you will need to create a Service Account with the following roles:

* `BigQuery Admin `
* ` Storage Admin `
* ` Storage Object Admin `
* ` Viewer `

Download the Service Account credentials file, rename it to ` google_credentials.json ` and store it in your home folder, in ` $HOME/.google/credentials/ ` .

IMPORTANT: if you're using a VM as recommended, you will have to upload this credentials file to the VM.

You will also need to activate the following APIs:

* [https://console.cloud.google.com/apis/library/iam.googleapis.com](https://console.cloud.google.com/apis/library/iam.googleapis.com)
* [https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com)


## Creating an environment variable for the credentials

Create an environment variable called `GOOGLE_APPLICATION_CREDENTIALS` and assign it to the path of your json credentials file, which should be `$HOME/.google/credentials/` . Assuming you're running bash:

1. Open `.bash.rc`:
	```
	nano ~/.bashrc
	```
2. At the end of the file, add the following line:
	```
	export GOOGLE_APPLICATION_CREDENTIALS="<path/to/authkeys>.json"
	```
3. Exit nano with `Ctrl+X`. Follow the on-screen instructions to save the file and exit.

4. Log out of your current terminal session and log back in, or run `source ~/.bashrc` to activate the environment variable.

5. Refresh the token and verify the authentication with the GCP SDK:
	```
	gcloud auth application-default login
	```
### Install and setup Google Cloud SDK

1. Download Gcloud SDK [from this link](https://cloud.google.com/sdk/docs/install) and install it according to the instructions for your OS.
2. Initialize the SDK [following these instructions](https://cloud.google.com/sdk/docs/install).
	i. Run `gcloud init` from a terminal and follow the instructions.
	ii. Make sure that your project is selected with the command `gcloud config list`

## Create a VM instance

### Using the GCP dashboard

1. From your project's dashboard, go to Cloud Compute > VM instance
2. Create a new instance:
	. Any name of your choosing
	. Pick your favourite region. You can check out the regions in [this link](https://cloud.google.com/about/locations).
   
	| IMPORTANT: make sure that you use the same region for all of your Google Cloud components.

	. Pick a E2 series instance. A e2-standard-4 instance is recommended (4 vCPUs, 16GB RAM)
	. Change the boot disk to Ubuntu. The Ubuntu 20.04 LTS version is recommended. Also pick at 	  least 30GB of storage.
	. Leave all other settings on their default value and click on Create.

### Using the SDK

The following command will create a VM using the recommended settings from above. Make sure that the region matches your choice:
	```
 	gcloud compute instances create <name-of-the-vm> --zone=<google-cloud-zone> --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud --machine-type=e2-standard-4 --boot-disk-size=30GB
	```

### Set up SSH access to the VM

1. Start your instance from the VM instances dashboard in Google Cloud.
2. In your local terminal, make sure that the gcloud SDK is configured for your project. Use gcloud config list to list your current config's details.
	i. If you have multiple google accounts but the current config does not match the account 		    you want:
		a. Use `gcloud config configurations list` to see all of the available configs and 				their associated accounts.
		b. Change to the config you want with `gcloud config configurations activate my-project`
	ii. If the config matches your account but points to a different project:
		a. Use `gcloud projects list` to list the projects available to your account (it can take a while to load).
		b. use `gcloud config set project my-project` to change your current config to your project.
3. Set up the SSH connection to your VM instances with `gcloud compute config-ssh`
	. Inside `~/ssh/` a new `config` file should appear with the necessary info to connect.
	. If you did not have a SSH key, a pair of public and private SSH keys will be generated for you.
	. The output of this command will give you the host name of your instance in this format: `instance.zone.project` ; write it down.
4. You should now be able to open a terminal and SSH to your VM instance like this:
	. `ssh instance.zone.project`
5. In VSCode, with the Remote SSH extension, if you run the [command palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette) and look for Remote-SSH: Connect to Host (or alternatively you click on the Remote SSH icon on the bottom left corner and click on Connect to Host), your instance should now be listed. Select it to connect to it and work remotely.

### Starting and stopping your instance with gcloud sdk after you shut it down

1. List your available instances.
	```
	gcloud compute instances list
	```
2. Start your instance
	```
	gcloud compute instances start <instance_name>
	```
3. Set up ssh so that you don't have to manually change the IP in your config files.
	```
	gcloud compute config-ssh
	```
4. Once you're done working with the VM, you may shut it down to avoid consuming credit.
	```
	gcloud compute instances stop <instance_name>
	```

### Installing the required software in the VM

1. Run this first in your SSH session: `sudo apt update && sudo apt -y upgrade`
	. It's a good idea to run this command often, once per day or every few days, to keep your VM up to date.

### Docker:
1. Run `sudo apt install docker.io` to install it.
2. Change your settings so that you can run Docker without sudo:
	i. Run `sudo groupadd docker`
	ii. Run `sudo gpasswd -a $USER docker`
	iii. Log out of your SSH session and log back in.
	iv. Run `sudo service docker restart`
	v. Test that Docker can run successfully with `docker run hello-world`
	
### Docker compose:

1. Go to [https://github.com/docker/compose/releases](https://github.com/docker/compose/releases) and copy the URL for the docker-compose-linux-x86_64 binary for its latest version.
	. At the time of writing, the last available version is v2.2.3 and the URL for it is [https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64](https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64)
2. Create a folder for binary files for your Linux user:
	i. Create a subfolder `bin` in your home account with `mkdir ~/bin`
	ii. Go to the folder with `cd ~/bin`
3. Download the binary file with `wget <compose_url> -O docker-compose`
	. If you forget to add the `-O` option, you can rename the file with `mv <long_filename> docker-compose`
	. Make sure that the `docker-compose` file is in the folder with `ls`
4. Make the binary executable with `chmod +x docker-compose`
	. Check the file with `ls` again; it should now be colored green. You should now be able to run it with `./docker-compose version`
5. Go back to the home folder with `cd ~`
6. Run `nano .bashrc` to modify your path environment variable:
	i. Scroll to the end of the file
	ii. Add this line at the end:
	```
 	export PATH="${HOME}/bin:${PATH}"
 	```
	iii. Press `CTRL` + `o` in your keyboard and press Enter afterwards to save the file.
	iv. Press `CTRL` + `x` in your keyboard to exit the Nano editor.
7. Reload the path environment variable with `source .bashrc`
8. You should now be able to run Docker compose from anywhere; test it with `docker-compose version`

### Terraform:

1. Run `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`
2. Run `sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`
3. Run `sudo apt-get update && sudo apt-get install terraform`

### Google credentials

Make sure that you upload the `google_credentials.json` to `$HOME/.google/credentials/` and you create the `GOOGLE_APPLICATION_CREDENTIALS` as specified in the Creating an environment variable for the credentials section.


## Upload/download files to/from your instance

1. Download a file.
```
# From your local machine
scp <instance_name>:path/to/remote/file path/to/local/file
```

2. Upload a file.
```
# From your local machine
scp path/to/local/file <instance_name>:path/to/remote/file
```

3. You can also drag & drop stuff in VSCode with the remote extension.

4. If you use a client like Cyberduck, you can connect with SFTP to your instance using the `instance.zone.project` name as server, and adding the generated private ssh key.

## Clone the repo in the VM

Log in to your VM instance and run the following from your `$HOME` folder:

```
git clone https://github.com/0xxhaisenberg/airbnb-amsterdam.git
```

The contents of the project can be found in the `0xxhaisenberg/airbnb-amsterdam`

 | IMPORTANT: I strongly suggest that you fork my project and clone your copy so that you can easily perform changes on the code, because you will need to customize a few variables in order to make it run with your own infrastructure.

## Set up project infrastructure with Terraform

Make sure that the credentials are updated and the environment variable is set up.

1. Go to the `0xxhaisenberg/airbnb-amsterdam/terraform` folder.

2. Open `variables.tf` and edit line 11 under the `variable "region"` block so that it matches your preferred region.

3. Initialize Terraform:
```
terraform init
```

4. Plan the infrastructure and make sure that you're creating a bucket in Cloud Storage as well as a dataset in BigQuery
```
terraform plan
```

5. If the plan details are as expected, apply the changes.
```
terraform apply
```
You should now have a bucket called `data_lake` and a dataset called `airbnb-amsterdam-june` in BigQuery.

## Set up data ingestion with Airflow

1. Go to the `0xxhaisenberg/airbnb-amsterdam/airflow` folder.
2. Run the following command and write down the output:
```
echo -e "AIRFLOW_UID=$(id -u)"
```
3. Open the `.env` file and change the value of `AIRFLOW_UID` for the value of the previous command.
4. Change the value of `GCP_PROJECT_ID` for the name of your project id in Google Cloud and also change the value of `GCP_GCS_BUCKET` for the name of your bucket.
5. Build the custom Airflow Docker image:
```
docker-compose build
```
6. Initialize the Airflow configs:
```
docker-compose up airflow-init
```
7. Run Airflow
```
docker-compose up
```

You may now access the Airflow GUI by browsing to localhost:8080. Username and password are both `airflow` .

	| IMPORTANT: this is NOT a production-ready setup! The username and password for Airflow have not been modified in any way; you can find them by searching for `_AIRFLOW_WWW_USER_USERNAME` and `_AIRFLOW_WWW_USER_PASSWORD` inside the `docker-compose.yaml` file.

## Perform the data ingestion

If you performed all the steps of the previous section, you should now have a web browser with the Airflow dashboard.

To trigger the DAG, simply click on the switch icon next to the DAG name. The DAG will retrieve all data from the starting date to the latest available hour and then perform hourly checks on every 30 minute mark.

After the data ingestion, you may shut down Airflow by pressing `Ctrl+C` on the terminal running Airflow and then running `docker-compose down`, or you may keep Airflow running if you want to update the dataset every hour. If you shut down Airflow, you may also shut down the VM instance because it won't be needed for the following steps.

## Setting up dbt Cloud

1. Create a dbt CLoud account.
2. Create a new project.
	i. Give it a name (`airbnb-amsterdam` is recommended), and under Advanced settings, input `dbt/` as the Project subdirectory.
	ii. Choose BigQuery as a database connection.
	iii. Choose the following settings:
		. You may leave the default connection name.
		. Upload a Service Account JSON file > choose the `google_credentials.json` we created previously.
		. Under BigQuery Optional Settings, make sure that you put your Google Cloud location under Location.
		. Under Development credentials, choose any name for the dataset. This name will be added as a prefix to the schemas. In this project the name `dbt` was used.
		. Test the connection and click on Continue once the connection is tested successfully.
	iv. In the Add repository from form, click on Github and choose your fork from your user account. Alternatively, you may provide a URL and clone the repo.
3. Once the project has been created, you should now be able to click on the hamburger menu on the top left and click on Develop to load the dbt Cloud IDE.

You may now run the `dbt run` command in the bottom prompt to run all models; this will generate 3 different datasets in BigQuery:

. `<prefix>_staging` hosts the staging views for generating the final end-user tables.
. `<prefix>_core` hosts the end-user tables.


## Deploying models in dbt Cloud with a Production environment

1. Click on the hamburger menu on the top left and click on Environments.
2. Click on the New Environment button on the top right.
3. Give the environment a name (`Production` is recommended), make sure that the environment is of type Deployment and in the Credentials section, you may input a name in the Dataset field; this will add a prefix to the schemas, similarly to what we did in when setting up the development environment (`production` is the recommended prefix but any prefix will do, or you may leave it blank).
4. Create a new job with the following settings:
	. Give it any name; `dbt run` is recommended.
	. Choose the environment you created in the previous step.
	. Optionally, you may click on the Generate docs? checkbox.
	. In the Commands section, add the command `dbt run`
	. In the Triggers section, inside the Schedule tab, make sure that the Run on schedule is checked. But for this purpose 'Run Now' is fine
5. Save the job.

You may now trigger the job manually or you may wait until the scheduled trigger to run it. The first time you run it, 3 new datasets will be added to BigQuery following the same pattern as in the development environment.




