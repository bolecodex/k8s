# Task
Configure a Pod with the name initdemo that runs 2 containers. The first container(alpine) should create the file /data/runfile.txt. The second container(busybox) should only start once this file has been created. The second container should run the "sleep 10000" command as its task
