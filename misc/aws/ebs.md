# How to mount EBS on EC2
Create EBS using console
EC2 and EBS should be part of same AZ
Attach EBS to EC2 using console
Login into EC2
Run below command to check the volumes
lsblk
Then mount the volume
sudo mkdir /mnt/ebs
To check if data exists on the volume
sudo file -s /dev/nvme1n1
Make filesystem if it is empty
sudo mkfs -t  xfs /dev/nvme1n1
To mount the volume
sudo mount /dev/nvme1n1 /mnt/ebs

# How to remount EBS on EC2
First re-attch the volume to EC2  using console
Unmount the earlier mounted volume
sudo umount /dev/nvme1n1
Check the volume location using lsblk
Mount the volume
sudo mount /dev/nvme1n2 /mnt/ebs