# Prerequisites

## Install `fleetctl`

`curl -sSL https://fleetdm.com/resources/install-fleetctl.sh | bash`

## Enable APIs

```
gcloud services enable \
    compute.googleapis.com \
    run.googleapis.com \
    cloudresourcemanager.googleapis.com \
    sqladmin.googleapis.com
```