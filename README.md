
# Data Transformations with dbt-core

## Task
Use dbt-core to create a staging table from the `transactions` raw table in the `bigquery-public-data.crypto_bitcoin_cash` dataset, filtering data from the last three months. Then, materialize a data mart table that calculates the current balance for all addresses, excluding those with any transactions through coinbase.


## Repository Structure (Relevant files)

```
├── README.md
├── staging
│   ├── dbt_project.yml
│   └── models
│        └── stg_bitcoin.sql
├── data_marts
│   ├── dbt_project.yml
│   └── models
│       └── dm_bitcoin.sql
├── profiles.yml
├── requirements.txt
```

## Files Purpose

- **profiles.yml**: This file has all the necessary configurations for the dbt profiles needed to connect to BigQuery, specifically to the project created with Terraform. It needs to be moved into the `~/.dbt/` directory for dbt to recognize it. The oly modification required is the `keyfile` fields which must be updated with the full path to your service account's credentials JSON file (the service account created by Terraform). This ensures dbt can authenticate and connect to the GCP Project created with Terraform.

- **requirements.txt**: This file contains the required dependencies for the dbt project. In this case, it includes `dbt-core` (the core dbt package) and `dbt-bigquery` (which allows dbt to interact with BigQuery). These are the only dependencies needed to run the dbt models in this repository.

- **dbt_project.yml** (in both `staging` and `data_marts` directories): Each project (staging and data marts) contains a `dbt_project.yml` file. The contents of these files are mostly the default ones generated by the `dbt init` command, with one key difference: the addition of the following configuration:
  ```yaml
  models:
    data_marts:
      +materialized: table
  ```
  and 
  ```yaml
  models:
    staging:
      +materialized: table
  ```
  This configuration ensures that dbt will create **tables** in BigQuery (instead of views, which is the default behavior). Additionally, any example models generated by dbt have been removed to keep the repository clean and focused on the actual project tasks.

- **SQL Files in the `models` folder**: Inside both the `staging` and `data_marts` folders, you'll find a corresponding SQL file (e.g., `stg_bitcoin.sql` in the `staging` folder, and `dm_bitcoin.sql` in the `data_marts` folder). These SQL files contain the dbt queries that define the logic for creating the tables in BigQuery. The queries in these files are what dbt uses to materialize the data into BigQuery tables when using command `dbt run`.


## Create Staging and Data Mart tables from Bitcoin data
[Setup Video Tutorial](https://www.loom.com/share/546aa2513b8e4424aed167215110af63?sid=70b097e7-92bf-4966-8e3b-6fefa019ed24)
### Prerequisites
- [Install dbt Core](https://docs.getdbt.com/docs/core/installation-overview) to be able to use on terminal. Easiest way is to create a python virtual environment and run:
```sh
pip install -r requirements.txt
```
- [Create credentials JSON](https://developers.google.com/workspace/guides/create-credentials#create_credentials_for_a_service_account)  for the service account created through terraform.

- If running locally create a copy of the `profiles.yml` file in this repository to your `~/.dbt/` directory. Move the credentials JSON into this directory as well.
In the `keyfile` field for both profiles `data_marts` and `staging` replace with the full path to the credentials JSON. 



### Creating Tables

#### Staging table
1. Change working directory to `staging` project:
```sh
cd staging
```
2. Run dbt to create `stg_bitcoin` table:
```sh
dbt run
```
3. Return to repository root:
```sh
cd ..
```

#### Data mart table
1. Change working directory to `data_marts` project:
```sh
cd data_marts
```
2. Run dbt to create `dm_bitcoin` table:
```sh
dbt run
```


# Github Actions
The `dbt-run.yml` found in `.github/workflows/`is a GitHub Actions workflow that triggers dbt core to run whenever a
new commit is pushed to a pull request or when a pull request is created.

This workflow should:
- Authenticates with Google Cloud using the service account
provisioned by Terraform.
- Install dbt and its dependencies.
- Runs the following command to execute the dbt models:
```sh
dbt run --profiles-dir ../
```
We specify in this case the directory where `profiles.yml` can be found. This file will read the google credentials JSON location as an environment variable which is set automatically by Github Actions once google is authenticated.

For the worflow to work it is important to set the google credentials JSON as a [repository secret](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) named `GCP_SERVICE_ACCOUNT_KEY` which is the name used in the workflow yml `dbt-run.yml`.