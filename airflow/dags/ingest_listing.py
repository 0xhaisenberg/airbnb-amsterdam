import os
import logging

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from datetime import datetime
from datetime import timedelta

from google.cloud import storage
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateExternalTableOperator
import pandas as pd
import pyarrow


PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET = os.environ.get("GCP_GCS_BUCKET")
BIGQUERY_DATASET = os.environ.get("BIGQUERY_DATASET", 'airbnb_amsterdam_june')

batch_date = '2023-06-05'
base_url = 'http://data.insideairbnb.com/the-netherlands/north-holland/amsterdam'

# path_to_dir = os.getcwd()

path_to_file = '/home/haisenberg/airbnb-amsterdam/airflow/data'
dataset_url = f"{base_url}/{batch_date}/data/listings.csv.gz"
dataset_file = 'listings.csv.gz'
parquet_file = dataset_file.replace('csv.gz', 'parquet')




def format_to_parquet(src_file):
    df = pd.read_csv(src_file)
    df.to_parquet(f'{parquet_file}', compression='gzip')

    return f"{parquet_file}"




def upload_to_gcs(bucket, object_name, ti):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    :param bucket: GCS bucket name
    :param object_name: target path & file-name
    :param local_file: source path & file-name
    :return:
    """
    local_file = ti.xcom_pull(task_ids="format_to_parquet_task")

    client = storage.Client()
    bucket = client.bucket(bucket)

    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)



default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 1,
}

# NOTE: DAG declaration - using a Context Manager (an implicit way)
with DAG(
    dag_id="ingest_listing_data",
    schedule_interval=timedelta(days=90),
    start_date=days_ago(1),
    default_args=default_args,
    catchup=True,
    max_active_runs=3,
    tags=['airbnb-amsterdam-june'],
) as dag:

    download_dataset_task = BashOperator(
        task_id="download_dataset_task",
        bash_command=f"wget -P {path_to_file}/ {base_url}/{batch_date}/data/{dataset_file}"
    )

    format_to_parquet_task = PythonOperator(
    task_id="format_to_parquet_task",
    python_callable=format_to_parquet,
    op_kwargs={
        "src_file": f"{path_to_file}/{dataset_file}",
        },
    )

    local_to_gcs_task = PythonOperator(
        task_id="local_to_gcs_task",
        python_callable=upload_to_gcs,
        op_kwargs={
            "bucket": BUCKET,
            "object_name": f"airbnb_amsterdam/{parquet_file}",
           # "local_file": f"{path_to_file}/{parquet_file}",
        },
    )

    bigquery_table_task = BigQueryCreateExternalTableOperator(
        task_id="bigquery_table_task",
        table_resource={
            "tableReference": {
                "projectId": PROJECT_ID,
                "datasetId": BIGQUERY_DATASET,
                "tableId": "listings",
            },
            "externalDataConfiguration": {
                "sourceFormat": "PARQUET",
                "sourceUris": [f"gs://{BUCKET}/airbnb_amsterdam/{parquet_file}"],
            },
        },
    )

    download_dataset_task >> format_to_parquet_task >> local_to_gcs_task >> bigquery_table_task