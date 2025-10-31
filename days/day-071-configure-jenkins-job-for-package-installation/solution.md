
1-first you must download these plugins SSH,SSH Credential and SSH build agents
2-then go to credential and assign credential to the storage server with username and password specified in the sheet
3-now go to manage jenkins -> system -> ssh remote hosts and put the hostname of storage server and the credential you did in the previous step
4- now create a job and select the option ( this project is parameterized ) then select string parameter
5- go to build steps and select execute shell on remote host using ssh and type this command
echo "your-sudo-password" | sudo -S yum install $PACKAGE