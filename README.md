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

Next, in your web browser visit the URL (e.g. `https://10.20.30.40:8080`). You should see a warning because we are using a self-signed certificate (`NET::ERR_CERT_AUTHORITY_INVALID` on Chrome or `MOZILLA_PKIX_ERROR_SELF_SIGNED_CERT` on Firefox). To get past this, click "Advanced" and then "Proceed". Finally, login with the provided credentials and verify you have access.

* **Go to Hosts and take a screenshot of the node VM**

## osquery Lab (cont.)

## osquery Lab (cont.)
### Run queries manually
Before using LLMs to interact with osquery, start by running some queries manually to familiarize yourself. Navigate to Reports and click "Add report". From here, you can craft your osquery statement and then execute it with "Live report" > "All hosts" > "Run".

Run the following commands and take a screenshot of each result.

* **Return processes that are deleted from disk**
    ```
    SELECT pid, name, path FROM processes WHERE on_disk = 0;
    ```
* **Return ports that are in the listening state**
    ```
    SELECT p.name, p.path, p.cmdline, lp.port FROM listening_ports lp JOIN processes p ON lp.pid = p.pid WHERE lp.port != 0;
    ```
* **Return users with a password that has not been changed in over 1 year**
    ```
    SELECT u.username, u.directory, u.shell, s.last_change FROM shadow s JOIN users u ON s.username = u.username WHERE s.last_change < ((strftime('%s', 'now') / 86400) - 365);

---

## Part 3: Agentic osquery via MCP

Now, you will use the provided Python agent to perform the same IT operations using natural language. The agent will communicate with an MCP server (`app.py`), which abstracts the FleetDM REST API into tools the AI can use.

### 1. Agent Environment Setup
Open a new terminal window or tab and navigate to the `agent` directory. Install the required Python dependencies:
```
pip install -r requirements.txt
```
*(This will install necessary packages like `fast-agent-mcp` and `fastmcp`.)*

### 2. Download the osquery Schema
The MCP server requires the osquery schema to understand the database structure. Download it directly using `wget`:
```
wget -O osquery.json https://raw.githubusercontent.com/osquery/osquery-site/main/src/data/osquery_schema_versions/5.21.0.json
```
**

### 3. Generate a Fleet API Key
1. Go back to your FleetDM web interface.
2. Click on your profile icon in the top right and select **My account**.
3. Under **API tokens**, generate a new API key. Copy this key to your clipboard.

### 4. Configure Environment Variables
The MCP server relies on environment variables to authenticate with your Fleet server. Export them in your terminal (replace the placeholders with your actual Server URL and API Key):
```
export FLEET_URL="<YOUR_SERVER_IP>:8080"
export FLEET_API_KEY="<YOUR_COPIED_API_KEY>"
```

### 5. Run the Agent
Start the interactive CLI agent:
```bash
python client.py
```
**

Once the agent is running, ask it to perform the same four tasks using natural language prompts:
1. *"Find any processes that are deleted from disk."*
2. *"List all ports that are currently in a listening state."*
3. *"Check if there are any users whose passwords haven't been changed in over a year."*
4. *"Identify any users that have root privileges but are not the 'root' user."*

**Take screenshots** of the conversational output and the agent's successful retrievals to include in your lab notebook.

---

## Part 4: Cleanup & Teardown

When you have finished the lab and collected all your screenshots, you must destroy the infrastructure to prevent unwanted GCP charges.

1. Navigate back to the root `osquery-lab` directory.
2. Run the destroy script:
   ```bash
   ./destroy.sh
   ```
   **
3. Wait for the script to output `Level destroyed.`.

---
**Submission Reminder:** Ensure your lab notebook contains 8 screenshots total (4 from the FleetDM manual SQL panel, and 4 from the interactive MCP agent terminal) along with any required analysis requested by your instructor.