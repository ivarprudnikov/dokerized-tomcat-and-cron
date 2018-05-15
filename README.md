Example - Docker with multiple processes
========================================

In order to run multiple processes on Docker it is expected to execute them via `supervisor` program that monitors and restarts configured processes, this `supervisor` will be the sole process that is monitored by Docker.

Supervisor needs configuration (`supervisord.conf`) that states the processes which need to start.

There is one catch though, `supervisor` does not exit if one of the processes transitions to `failed state`,
which means that process reached the limit of failed restarts. For this reason there is particular
event listener set in `supervisord.conf` which makes sure that process exits in case one of child processes
transitions to `failed state`.

### Running container locally

Container needs to be built and for this it needs `.WAR`, `Dockerfile`.

- `$ docker build -t myapp .` - here `myapp` is arbitrary tag name we're gonna reuse in next command
- Then run container
  ```
  $ docker run --rm -e "JAVA_OPTS=-Xmx1g -Xms512M -XX:MaxPermSize=1024m" -it -p 8080:8080 myapp
  ```
  - `JAVA_OPTS` are optional but instance might run out of PermGen space, this depends on your program packed in `war` file
- Open browser at `http://localhost:8080`

### Check if all expected processes are running

- `$ docker ps` - find docker `CONTAINER ID` and use it in next command (replace `$id`)
- `$ docker exec -it $id bash` - ssh into docker container
- `root@$id:/usr/local/tomcat# top` - should show all processes, there should be:
  - `supervisord` - main process that makes sure `tomcat` and `cron` are running
  - `java` - tomcat
  - `cron` - cron job that sends data to BigQuery
  - `python` - event listener that makes sure `supervisord` makes suicide is `cron` or `java` tranision to failed state
- `root@$id:/usr/local/tomcat# supervisorctl` - states of processes under supervisor:
  - `exit_on_any_fatal` has to be in `RUNNING` state
  - `catalina` has to be in `RUNNING` state
  - `cron` has to be in `RUNNING` state
- `supervisor> exit` - exit the supervisor

#### Check `cron` is executing

Provided `cron` is running (see above):

- `root@$id:/usr/local/tomcat# crontab -l` - list cron jobs, should contain appropriate cron config
- `root@$id:/usr/local/tomcat# wc -l logs/cron.log` - check how many lines log contains, it should increase every minute.
