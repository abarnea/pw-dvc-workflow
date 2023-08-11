# DVC Wrapper Workflow

The DVC Wrapper workflow allows you to run any DVC-configured Github repository to (re-)train and/or run machine learning models from cloud-stored data.

### Requirements

Please note the following requirements to use this workflow:

1. Your chosen Github repository must be accessible to you on this machine.
2. Your Github repository <i>must</i> have the following configurations in order to operate.
    1. A DVC repository with remote cloud storage already set-up
    2. A remote cloud storage access key (I prefer Google Cloud Storage)
    3. A DVC training pipeline created in the repository's `dvc.yaml` file.
3. You can find complete information on how to set up all of these requirements in the `DVC_SETUP.md` file of this repository.

### Instructions

To use this workflow effectively, please follow the instructions below:

1. Start up and select your resource of choice from the dropdown menu.
2. Input your chosen Github repository name and the Github username of the <i>owner of your chosen repository</i> in the respective fields.
3. Input the name of your <u>DVC remote storage name</u>, ex: "mystorage" or "origin".
4. Select whether you would like to `Train` your ML model or `Run a Script` in the main directory of your repository. For both options, this workflow will set up `miniconda3` and your provided package requirements in your cluster of choosing, clone and access your chosen repository, and connect to your chosen remote storage container.
    1. When you select the `Train Model` option, this workflow will then pull your tracked DVC data, run your pre-set training pipeline for your ML model(s), and push your models back to remote storage.
    2. When you select the `Run Script` option, this workflow will pull your tracked DVC data and run a script of your choosing, provided as an input box on the main page.
5. It is recommended that you set up the Python installation on your cluster ahead of time, as this process can as long as 10-15 minutes to complete upon workflow execution.


### Known Issues

1. Running the `Run Script` setting without retraining your ML model gives a `WARNING: file hash info not found` error and doesn't pull data from cloud storage.
    - <b>Temporary Fix:</b> Running `dvc repro --pull` instead of `dvc pull`, so DVC runs the data pipeline and retrains the ML model(s), fixes this issue, but is very inefficient since the point of this workflow is to avoid having to retrain ML models.
2. A port needs to be sent back from the cluster to your user container in order to open the display setting on the Parallel Works platform. This function has not yet been completed.
