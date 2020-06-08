# Cluster tests

## Run on AWS
It is recommended to use [aws-vault](https://github.com/99designs/aws-vault).

To get started, run `aws-vault add ods-tests`, and add your access key and secret. Then, edit
`~/.aws/config` and specify `region` and, if you use MFA, your `mfa_serial`.

Example:

```
[profile ods-tests]
region = us-west-2
mfa_serial = arn:aws:iam::859349366751:mfa/johndoe
```

Then execute the tests from within `aws-vault exec ods-tests -- bash`:

```
./run-on-aws.sh --availability-zone us-west-2c --instance-type m5a.2xlarge --subnet-id subnet-abc --security-group-id sg-abc --keypair foo
```

Subsequent tests can be run by just connecting to the existsing host:
```
./run-on-aws.sh --host <the ip address> --keypair foo
```

Don't forget to terminate the instance once you are done testing.

Often, you'd want to run the tests against the local state (e.g. to check if
your modifications break any tests). To do this, pass `--rsync` to
`./run-on-aws.sh`.

## General Usage

You can also run the tests outside AWS. Just execute `install.sh`,
`prepare-test.sh` and `test.sh` on any Ubuntu 16.04 host.
