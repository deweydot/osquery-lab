## osquery Lab
### Overview
osquery is an open-source that allows you to fetch a variety of useful system details such as running processes, local users, and performance metrics. It works across various OSes, and when used in conjuction with FleetDM is a powerful tool for security and IT related tasks.

osquery exposes OS information as SQLite tables. For example, to get the OS running on a host, you would use the query
```
SELECT name, major, minor FROM os_version;
```

The full schema for osquery can be accessed [here](https://osquery.io/schema).

### Setup
In this lab, you will be deploying a "mini" osquery setup with FleetDM and then interacting with it using SQL commands and then natural language with an LLM agent.

To get started, navigate to the course repo on **Cloud Shell** on GCP. First, modify the `terraform.tfvars` file and change `project_id` to match your GCP project. Then, run the `deploy.sh` script. This will use Terraform to create and setup the osquery and FleetDM VMs for you. It should take ~5 minutes to run. When it finishes, take note of the URL and admin credentials provided to you.

Next, in your web browser visit the URL (e.g. `https://<YOUR_SERVER_IP>:8080`). You should see a warning because we are using a self-signed certificate (`NET::ERR_CERT_AUTHORITY_INVALID` on Chrome or `MOZILLA_PKIX_ERROR_SELF_SIGNED_CERT` on Firefox). To get past this, click "Advanced" and then "Proceed". Finally, login with the provided credentials and verify you have access.

* **Go to Hosts and take a screenshot of the node VM**

### Run queries manually
Before using LLMs to interact with osquery, start by running some queries manually to familiarize yourself. Navigate to Reports and click "Add report". From here, you can craft your osquery statement and then execute it with "Live report" > "All hosts" > "Run".

Run the following commands and take a screenshot of each result.
* **Return processes that are deleted from disk**
    ```
    SELECT pid, name, path FROM processes WHERE on_disk = 0;
    ```
* **Return ports that are in the listening state**
    ```
    SELECT p.name, p.path, p.cmdline, l.port FROM listening_ports l JOIN processes p ON l.pid = p.pid WHERE l.port != 0;
    ```
* **Return users with a password that has not been changed in over 1 year**
    ```
    SELECT s.username, u.uid, s.last_change, u.directory FROM shadow s JOIN users u ON s.username = u.username WHERE s.last_change < strftime('%s','now')/86400 - 365  
    ```

## osquery Lab (cont.)
### Using an LLM agent
Now, you will use the provided agent to perform the same queries using natural language. The agent uses an MCP server (`app.py`) to communicate with FleetDM's REST API to run queries for you. The agent requires the server URL and an API key. The API key can be retrived from `https://<YOUR_SERVER_IP>:8080/account` > "Get API token".

To set up the agent run the following commands. You can run the agent from any machine.
```
cd agent
uv init --bare
uv add -r requirements.txt
export FLEET_URL='<YOUR_SERVER_IP>:8080'
export FLEET_API_KEY='...'
export OPENAI_API_KEY='...'
```
Do not include `https://` in FLEET_URL.

Then, run the agent with `uv run client.py`. Using the LLM agent, perform the same queries and take a screenshot of each result including the prompt used.
* **Return processes that are deleted from disk**
* **Return ports that are in the listening state**
* **Return users with a password that has not been changed in over 1 year**

When you are done, run the `destroy.sh` script to clean up the VMs so you don't waste credits.