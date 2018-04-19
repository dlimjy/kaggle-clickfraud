##### AWS Startup
#!/bin/bash
#install R
yum install -y R

#install RStudio-Server 1.0.153 (2017-07-20)
wget https://download2.rstudio.org/rstudio-server-rhel-1.1.447-x86_64.rpm
yum install -y --nogpgcheck rstudio-server-rhel-1.1.447-x86_64.rpm
rm rstudio-server-rhel-1.1.447-x86_64.rpm

#add user(s)
useradd dlim
echo dlim:Smartie199310 | chpasswd 

#####
# Switch folders user from ec2-user to dlim
su dlim
chmod 777 /home/dlim

# Set R to use gcc64 otherwise data.table won't install!
echo "CC=gcc64" >> ~/.R/Makevars
# cp /home/ec2-user/train.csv /home/dlim/train.csv  --optional, could just path to /home/ec2-user, just not sure if /home/dlim will persist after cluster shutdown
# Maybe unzip instead? could be faster