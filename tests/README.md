# Cluster tests

To run on AWS using [aws-vault](https://github.com/99designs/aws-vault):

Run `aws-vault add ods-tests`, and add your access key and secret. Then, edit
`~/.aws/config` and specify `region` and, if you use MFA, your `mfa_serial`.

Example:

```
[profile ods-tests]
region = us-west-2
mfa_serial = arn:aws:iam::859349366751:mfa/johndoe
```

Then execute the tests:
```
aws-vault exec ods-tests -- tests/run.sh --availability-zone us-west-2c --instance-type m5ad.4xlarge --subnet-id subnet-abc --security-group-id sg-abc --key-name foo --private-key private-key.pem
```
