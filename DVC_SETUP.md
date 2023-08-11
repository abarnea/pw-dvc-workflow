# Data Version Control (DVC) Setup Instructions

The following file contains information about how to:

1. Create a DVC repository.
2. Store and use your remote cloud storage access key.
    1. This file will explain how to do this with a sample Google Cloud Storage Bucket.
3. Connect your DVC repository to your remote cloud storage.
4. Automate a DVC Machine Learning data training pipeline.

All of this information can be found on the Data Version Control (DVC) Wiki located [here](https://dvc.org/doc/start/data-management).

### 1. Creating a DVC Repository

To create your DVC repository, simply navigate to your Github repository and type `dvc init` in the home directory. A directory `.dvc` will be created, along with two files `.dvc/config` and `.dvc/.gitignore` will be staged for commit to Github -- commit them.

Now you can grab your data. You can do that by either using `dvc get` (similar to `wget`), or if you want to pull your data from a Github repository (Ex: the Parallel Works documentation, which is constantly being updated), you can use `dvc import` (this checks for updates whenever you pull or retrain data).

After getting your data, you simply need to `dvc add` your data file or folder, and then `git add` the corresponding `.dvc` files in the same directory where your data is stored. The `.dvc` file is text file which contains the information that Github and DVC need to pinpoint where you are storing your data in remote cloud storage.

Once you've added your data to DVC tracking and your `.dvc` files to Github, you'll need to set up your remote storage container. To do so, just run `dvc remote add -d mystorage gs://mybucket/location/here`, where the file is your remote storage access key file. For Google Cloud Storage (GCS) used here, this would be a `bucket.json` file. You can replace `gs` with `s3` or another cloud storage bucket of your choosing. For configuring this in a Parallel Works cluster, see section 2.

Now that your remote storage has been set up, you can run `dvc push` to push your data to remote cloud storage, and `git push` to connect it to Github for version tracking.

### 2. Accessing your Remote Cloud Storage Bucket

To access your remote cloud storage bucket on a spun-up cluster on the Parallel Works platform, you will need to store your `bucket.json` access key in your `/contrib` directory of your cluster, and add two commands to your Resource `Bootstrap`, i.e. commands run when you launch your cluster. We'll take this step-by-step.

1. You need to spin up your cluster and `ssh` into it. Then, navigate to `/contrib/USERNAME` and either add your `bucket.json` file here, or, for better practice, make a directory called `service-accounts` and add your `bucket.json` file there.

2. Now that you've added your `bucket.json` file to your `/contrib` directory, you will need to add the following two commands to your Resource `Boostrap`. You can access this by going to your user container home page and clicking `Resources > YOUR RESOURCE > Bootstrap`. Make sure that your resource is <u>turned off</u>. Now, add the following lines:
    1. `gcloud auth activate-service-account --key-file=/contrib/USERNAME/service-accounts/bucket.json`
    2. `echo "export storage_bucket_path='/contrib/USERNAME/service-accounts/bucket.json'" >> ~/.bashrc`

For both steps, make sure you replace `USERNAME` with your username (Ex: `abarnea`) and `bucket.json` with the name of your access key file.

Now, whenever you launch your cluster, you will be able to access your credentials path with the environment variable `$storage_bucket_path`.

### 3. Connecting DVC to Remote Cloud Storage

Since you need to connect to your remote cloud storage in your Parallel Works cluster and you set up your DVC repository elsewhere, the `remote_dvc_setup.sh` script automatically modifies your credentials path for DVC based off of your `$storage_bucket_path` variable. Make sure you follow the steps in `2.`, otherwise this workflow <u>will not be able to access your remote cloud storage bucket to pull from.</u>

For some context, the workflow is able to do this by modifying your local credentials path to the new location of your `bucket.json` file using your `$storage_bucket_path` variable.

### 4. Creating a DVC Data Pipeline

Now that you have DVC fully set up in both your Github repository and in your Parallel Works account, you can now create your DVC data pipeline locally. With this pipeline, the DVC Wrapper workflow will be able to automatically pull your data and model, and either re-train and re-push your model back to cloud storage or run a script of your choosing on your PW cluster with the cloud stored ML models.

This section contains instructions for creating this pipeline. You can also find detailed instructions on the DVC Data Pipeline wiki page [here](https://dvc.org/doc/start/data-management/data-pipelines).

To create your DVC Data Pipeline, you can run the following command:

```
dvc stage add -n train \
-d data/training_set -d data/additional_training_set -d src/train.py \
-o model.bin -o model.bin.syn1neg.npy -o model.bin.wv.vectors.npy \
python src/create_model.py data/training_set
```

This is an example of what your `dvc.yaml` should look like afterwards:
```
stages:
  train:
    cmd: python3 src/create_model.py data/training_set
    deps:
    - data/training_set
    - data/additional_training_set
    - src/train.py
    outs:
    - models/model.bin
    - models/model.bin.syn1neg.npy
    - models/model.bin.wv.vectors.npy
```

Let's break down how this works.

1. The first part, `dvc stage add`, sets the stage for the data pipeline.
2. The next part is <i>naming</i> the stage. That is, `-n train`. This tells DVC that we're setting the <i>name</i> of the current stage to `train`.
3. The next part is setting the <i>dependencies</i> for the stage. Each `-d data/file` in this line is another dependency that DVC needs to check before running the stage. In this case, we're telling DVC that, to run this `train` stage, we need to have the data folders `training_set` and `additional_training_set` in the `data` directory, and the Python script `train.py` in the `src` directory.
4. The next line is setting the <i>outputs</i> of the stage. Each `-o models/file` in this line is another output that DVC needs to track. In this example stage, we told DVC that our pipeline needs to output the files `model.bin`, `model.bin.syn1neg.npy`, and `model.bin.wv.vectors.npy` in the `models` directory.
5. The final line of the stage creation command is the <i>command to run</i> if any of the dependencies or outputs are not present. In this case, the command would be `python3 src/create_model.py data/training_set`, i.e. run the `create_model.py` script in the `src` directory with the `training_set` data in the `data` directory as an input.

<b>Make sure that all dependencies, outputs, and scripts you are including in your DVC Data Pipeline are <u>tracked by DVC ahead of time</u>.</b>

You can repeat this stage creation as many times as you want. For example, if you want to create `prepare`, `featurize`, and `train` stages, you can do that! Just make sure to set different stage names, dependencies, outputs, and commands for each one! To see a diagram of your different pipeline stages, you can run `dvc dag` from the command line.

Now, how does this pipeline work exactly? Let's understand it.

1. When you run this pipeline, DVC first checks if all of the dependencies are in their correct locations.
    - If they are, then DVC proceeds.
    - If they aren't, then DVC pulls the files from remote cloud storage (remember: all of these dependencies should already be DVC tracked and in remote cloud storage!).
2. DVC then checks to see if there have been any changes to the dependencies based off of its cache.
    - If there haven't been changes to the dependencies, DVC proceeds.
    - If there have been changes to the dependencies, then DVC will check the outputs to see if they exist and have been updated.
        - Usually, they haven't, so DVC will run the `cmd` line and create new model(s) from the updated data!
        - If they have, then DVC skips and tells you that no changes need to be made and you are done!
3. If there haven't been changes to the dependencies, DVC goes to the outputs and checks if the files exist.
    - If the outputs don't exist, then DVC will either:
        - Pull the models from remote storage if the dependencies haven't changed.
        - If there <i>have</i> been changes to the dependencies, DVC will run the `cmd` line and create new model(s) from the updated data (as explained in Step 2).

Basically, DVC checks to see if your dependencies/data have changed. If they have, DVC will train a new model for you based on the provided script if you don't have an updated model locally or in cloud storage. If they haven't, DVC will pull the already trained model from cache or remote storage, so you don't have to retrain your model!

The benefits of creating such a data pipeline lies in the ability to <i>reproduce</i> this pipeline whenever you want without having to waste time to re-train your model, since it's all cached and version tracked!

Now, after running all of these commands and creating your stages, you will have both a `dvc.yaml` and `dvc.lock` file. The `dvc.yaml` file is the editable document containing your stages, and the `dvc.lock` file is a backend DVC file for reading your stage (DON'T EDIT THE LOCK FILE). You'll need to push these files to Github after creating the stages using `git add .gitignore data/.gitignore dvc.yaml` and `git commit -m "Define pipeline`.

Finally, to run this pipeline, simply type `dvc repro`, and the pipeline will launch! If you would like to pull updated data first before running the pipeline, you can run `dvc repro --pull` instead.