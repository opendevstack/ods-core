# ODS Box build bot
On a build server ODS box builds will be triggered by a cron job 4 times a day.
```
0 */6 * * * export PACKER_LOG=1 && export AWS_MAX_ATTEMPTS=400 && export AWS_POLL_DELAY_SECONDS=15 && source /home/georg/.packerrc && date && cd /home/georg/opendevstack/ods-core &&  time bash 2>&1 ods-devenv/packer/create_ods_box_image.sh --target create_ods_box_ami --aws-access-key "${aws_access_key}" --aws-secret-key "${aws_secret_access_key}" --ods-branch "${branch}" --instance-type ${instance_type} | tee "/home/georg/tmp/ami_builds/build_$(echo "${branch}" | tr "/" "_")_$(date +\%Y\%m\%dT\%H\%M\%S).log"
```
The corresponding logs will be scanned for success or error messages by the buildbot.
The build result will be served under the URL
https://buildbot_domain/build/result

# Configuration
The user running the buildbot should have the .packerrc file available in their $HOME path, as defined by the template in ods-devenv/packer/.packerrc.
