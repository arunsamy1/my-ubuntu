
---
### Some of Linux commands


#### To use through scripts

- echo "Current date is $(date)"
- echo "Current date is $(PWD)"
- echo "processes running $(ps -ef | grep java)"
- echo "$(ps -ef | grep java)"
- echo "$(df -h)

---

#### For loop

```bash
for X in `find *.log -maxdepth 1 type f -mtime +5`; do ls -lrth $X; done
```

---

#### Set File Access control list

```bash
setfacl -m g::rwx -m o::rx log
setfacl -m default:g::rwx -m o::rx log/
```

```bash

setfacl -m g::rwx -m o::rx log_folder 
    ---- giving read write executable permission for the log folder g=RWX others=RX
```
```bash
setfacl -m default:g::rwx -m o::rx log_folder/ 
    ---- giving read permission for the files inside the log folder g=RWX others=RX
```

works only when we have a new folder setup.  Take backup of entire folder.  Create new folder. Apply the above acl. Start the instance to generate the logs --.  

---

#### SSH setup for remote login

if the destination server is having /appserver, make sure you have the following permissions.

```
/appserver -755
/appserver/.ssh - 700
/appserver/.ssh/known_hosts -640
/appserver/.ssh/authorized_keys - 640
```

---------------------------------------------------------------------

#### How to verify your password reset day for your user_account

Go to command prompt

Run the below command

    net user user_account /domain

or

    net user /domain "user_account"

---

History list without timestamp and unique 


---


history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq

---

---
#### openssl encryption & decryption of a file

printf "&&&&&*****" | openssl dgst -sha3-512  
openssl enc -e -aes-256-cbc -in input_file.tar.gz -out input_file_aes256cbc_sha3-512.tar.gz  

mkdir test_temp; cd test_temp  
openssl enc -d -aes-256-cbc -in ../input_file_aes256cbc_sha3-512.tar.gz -out output_file.tar.gz  

---
