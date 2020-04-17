mkdir /drop
wget -P /drop -nv https://packages.chef.io/files/stable/chef-server/13.2.0/el/7/chef-server-core-13.2.0-1.el7.x86_64.rpm
wget -P /drop -nv https://packages.chef.io/files/stable/chef-manage/2.5.16/el/7/chef-manage-2.5.16-1.el7.x86_64.rpm
yum localinstall -y /drop/chef-server-core-13.2.0-1.el7.x86_64.rpm /drop/chef-manage-2.5.16-1.el7.x86_64.rpm

chef-server-ctl reconfigure --chef-license=accept

until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done

chef-server-ctl user-create chefadmin Chef Admin admin@therek.net insecurepassword --filename /drop/chefadmin.pem
chef-server-ctl org-create therek "therekNET" --association_user chefadmin --filename therek-validator.pem

opscode-manage-ctl reconfigure --chef-license=accept
