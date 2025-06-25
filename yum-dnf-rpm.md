
### Question 2 - YUM repository

Configure a Local Yum/DNF Repository on ServerA using the RHEL-9 ISO image mounted on the /mnt directory.

**Overall explanation**  
**1\. Mount the RHEL-9 ISO image:**

Mount the RHEL-9.iso file to the /mnt directory as a loop device:

\# mount \-o loop RHEL-9.iso /mnt

**Explanation:**

* \-o loop: specifies mounting the ISO as a loopback device.  
* A loop device treats the ISO like a physical disk.  
* Ensure you have the RHEL-9.iso file before proceeding.

**2\. Optionally make the mount persistent (skip if not needed):**

Append the mount command to /etc/fstab to automatically mount the ISO at boot:

\# echo "/path/to/RHEL-9.iso /mnt iso9660 loop 0 0" \>\> /etc/fstab

* Replace /path/to/RHEL-9.iso with the actual location of the ISO file.  
* If you use "iso9660 defaults," the system will apply its default options for mounting ISO9660.  
* If you use "iso9660 loop," it explicitly specifies the use of the loopback device for mounting the ISO image.  
* Both approaches are valid, but the "iso9660 loop" option is often explicitly used when dealing with ISO files to make it clear that a loopback device is involved in the mounting process.

**3\. Create the local repository file:**

Copy the '/mnt/media.repo' file to '/etc/yum.repos.d/rhel9.repo' or create a new '/etc/yum.repos.d/rhel9.repo' file:

\# cp /mnt/media.repo /etc/yum.repos.d/rhel9.repo

* This file defines the repository location and settings.

**4\. Set file permissions:**

Set permissions for /etc/yum.repos.d/rhel9.repo to allow reading by all:

\# chmod 644 /etc/yum.repos.d/rhel9.repo

**5\. Edit the repository file:**

Open '/etc/yum.repos.d/rhel9.repo' in a text editor (e.g., vim).

Replace the existing content with the following:

* \[InstallMedia-BaseOS\]  
* name=RHEL 9 \- BaseOS  
* metadata\_expire=-1  
* gpgcheck=0  
* enabled=1  
* baseurl=file:///mnt/BaseOS/  
*    
* \[InstallMedia-AppStream\]  
* name=RHEL 9 \- AppStream  
* metadata\_expire=-1  
* gpgcheck=0  
* enabled=1  
* baseurl=file:///mnt/AppStream/

**Explanation:**

* The file defines two repositories: BaseOS and AppStream.  
* metadata\_expire=-1 disables metadata expiration checks.  
* gpgcheck=0 skips GPG key verification (can be enabled later).  
* enabled=1 activates the repository.  
* baseurl points to the repository base directories within the mounted ISO.

**6\. Save and quit the editor.**

**7\. Clean system caches (optional):**

Clear the Yum/DNF and subscription-manager cache:

\# dnf clean all

\# subscription-manager clean

**Note:** You might see a "This system is not registered" message. To avoid it, edit /etc/yum/pluginconf.d/subscription-manager.conf and set enabled=0.

**8\. Verify the repository setup:**

List available repositories:

\# dnf repolist

---

```bash my notes to mem

mount -o loop RHEL-9.iso /mnt
echo "/path/to/RHEL-9.iso /mnt iso9660 loop 0 0" >> /etc/fstab
cp /mnt/media.repo /etc/yum.repos.d/rhel9.repo
chmod 644 /etc/yum.repos.d/rhel9.repo

vi '/etc/yum.repos.d/rhel9.repo'
[InstallMedia-BaseOS]  
name=RHEL 9 - BaseOS  
metadata_expire=-1  
gpgcheck=0  
enabled=1  
baseurl=file:///mnt/BaseOS/  
    
[InstallMedia-AppStream]  
name=RHEL 9 - AppStream  
metadata_expire=-1  
gpgcheck=0  
enabled=1  
baseurl=file:///mnt/AppStream/

dnf clean all
subscription-manager clean
dnf repolist


```



---


### Question 2: repository - dnf - yum

On ServerB, set up a local Yum/DNF repository using the /RHEL-9.iso image mounted on the /repo directory. Ensure the repository is accessible for package installation and updates, and address any potential issues with Red Hat Subscription Management registration.

**Overall explanation**  
Follow these steps to set up a local Yum/DNF repository on ServerB using the RHEL-9 ISO image:

1. **Create the Mount Point**:  
   * sudo mkdir /repo  
2. This directory will serve as the mount point for the ISO file.  
3. **Mount the ISO Image**: You have two options for mounting:  
   **Option 1**: *Persistent Mounting in /etc/fstab* (recommended for repeated access):  
   * su \-c 'echo "/RHEL-9.iso /repo iso9660 loop 0 0" \>\> /etc/fstab'  
   * sudo mount \-a  
4. This automatically mounts the ISO at boot and is useful if the repository is needed regularly.  
   **Option 2**: *Manual Mounting* (suitable for one-time use):  
   * sudo mount \-o loop /RHEL-9.iso /repo  
5. **Note**: iso9660 specifies the ISO filesystem type, and loop is used for mounting the ISO file as a loopback device.  
6. **Configure the Repository**:  
   * **Copy and Modify Repository File**:  
     * sudo cp \-v /repo/media.repo /etc/yum.repos.d/rhel9.repo  
     * sudo chmod 644 /etc/yum.repos.d/rhel9.repo  
     * sudo vi /etc/yum.repos.d/rhel9.repo  
   * **Edit the repository file** to reflect the appropriate base paths: Replace the contents with:  
     * \[InstallMedia-BaseOS\]  
     * name=RHEL 9 \- BaseOS  
     * metadata\_expire=-1  
     * gpgcheck=0  
     * enabled=1  
     * baseurl=file:///repo/BaseOS/  
     *    
     * \[InstallMedia-AppStream\]  
     * name=RHEL 9 \- AppStream  
     * metadata\_expire=-1  
     * gpgcheck=0  
     * enabled=1  
     * baseurl=file:///repo/AppStream/  
   * This configuration enables the system to locate the BaseOS and AppStream repositories within the mounted ISO.  
7. **Clean Metadata and Cache**:  
   * sudo dnf clean all  
8. Clearing cache ensures that the latest metadata and repository configurations are reloaded.  
9. **Address Subscription Manager Warnings** *(if system is unregistered)*:  
   * Clear any local subscription data:  
     * sudo subscription-manager clean  
   * Disable the subscription-manager plugin to avoid warnings:  
     * sudo vi /etc/yum/pluginconf.d/subscription-manager.conf  
   * Set enabled=0 to disable warnings related to Red Hat Subscription Manager.  
10. **Verify the Repository**:  
    * sudo dnf repolist  
11. Ensure that the InstallMedia-BaseOS and InstallMedia-AppStream repositories are listed, confirming that the local repository is properly set up.

**Summary:**

This setup enables ServerB to access packages and updates directly from the local RHEL-9 ISO without requiring an active Red Hat Subscription. The repository is available at boot (if persistent mounting is configured), providing a consistent environment for package installations.

---



### Question 2: repository - dnf-yum

On ServerB, configure your client server to use an HTTP repository hosted at "http://192.168.1.12" and disable any other repositories.

**Overall explanation**  
**Answer**

**RHEL Repository Server Configuration (Not Required for RHCSA)**

*Setting up an HTTP server on RHEL 9 is not required for the RHCSA exam, but these steps are included in case you wish to try it on your own system.*

1. **Register and Enable the Red Hat Subscription** (Only if installing from Red Hat's repositories)  
   * \# subscription-manager register  
   * \# subscription-manager auto-attach  
2. **Install and Configure Apache HTTP Server**  
   Install the Apache HTTP server and enable it to serve files over HTTP:  
   * \# dnf install httpd  
   * \# systemctl enable \--now httpd  
3. **Open Firewall Ports for HTTP/HTTPS**  
   Configure the firewall to allow HTTP and HTTPS traffic:  
   * \# firewall-cmd \--zone=public \--permanent \--add-service=http  
   * \# firewall-cmd \--zone=public \--permanent \--add-service=https  
   * \# firewall-cmd \--reload  
4. **Set Up the Repository Files**  
   * **Create Repository Directory**:  
     * \# mkdir \-p /var/www/html/rhel9\_repo  
   * **Mount and Copy ISO Contents**: Mount the RHEL ISO to copy its content to the HTTP server directory:  
     * \# mount \-o loop /RHEL-9.iso /mnt  
     * \# tar cvf \- . | (cd /var/www/html/rhel9\_repo/; tar xvf \-)  
5. **Create Repository Metadata**  
   Install the createrepo package to generate metadata for your repository:  
   * \# dnf install createrepo yum-utils  
   * \# createrepo /var/www/html/rhel9\_repo/  
6. **Configure Repository Files**  
   Create the repository configuration file:  
   * \# vim /etc/yum.repos.d/rhel9.repo  
7. Add:  
   * \[LocalRepo\_BaseOS\]  
   * name=LocalRepo\_BaseOS  
   * enabled=1  
   * gpgcheck=0  
   * baseurl=http://192.168.1.12/rhel9\_repo/BaseOS  
   *    
   * \[LocalRepo\_AppStream\]  
   * name=LocalRepo\_AppStream  
   * enabled=1  
   * gpgcheck=0  
   * baseurl=http://192.168.1.12/rhel9\_repo/AppStream

**Configure ServerB as a Client to Use the HTTP Repository**

Follow these steps on ServerB to use the repository provided at http://192.168.1.12 and disable any other repositories:

1. **Move Existing Repositories**  
   Move existing .repo files to another directory to temporarily disable them:  
   * \# mv /etc/yum.repos.d/\*.repo /tmp/  
2. *By moving .repo files to /tmp/, only the new repository will be accessible until these files are restored.*  
3. **Create a New Repository File**  
   Open a new repository file:  
   * \# vim /etc/yum.repos.d/local.repo  
4. Add the following content:  
   * \[LocalRepo\_BaseOS\]  
   * name=LocalRepo\_BaseOS  
   * enabled=1  
   * gpgcheck=0  
   * baseurl=http://192.168.1.12/rhel9\_repo/BaseOS  
   *    
   * \[LocalRepo\_AppStream\]  
   * name=LocalRepo\_AppStream  
   * enabled=1  
   * gpgcheck=0  
   * baseurl=http://192.168.1.12/rhel9\_repo/AppStream  
5. **Set Repository File Permissions**  
   Set permissions on the new repo file so it’s readable by all:  
   * \# chmod 644 /etc/yum.repos.d/local.repo  
6. **Clean DNF Cache**  
   Refresh the cache to remove old data:  
   * \# dnf clean all  
7. **Verify and Test Repository Access**  
   * **List Enabled Repositories**:  
     * \# dnf repolist  
   * **Update Packages to Test the Repository**:  
     * \# dnf update  
   * *This command checks if the repository is working and if packages are accessible.*

**Additional Notes**

* **Repository Files**: Moving .repo files to /tmp/ effectively disables them without deleting them, making it easy to re-enable if needed.  
* **Repository Caching**: Running dnf clean all clears cached data and ensures the new repository information is loaded.  
* **Use of HTTP Repository**: HTTP repositories are commonly used in production environments to centralize package management across multiple servers.


---


### Question 2: YUM repository

On ServerB, set up a YUM repository for a locally-mounted RHEL 9 DVD. Mount the RHEL 9 DVD to the /mnt/repo/ directory.

**Overall explanation**  
**Step-by-Step Instructions**

**Step 1: Create the Mount Directory**

1. **Create a new directory** /mnt/repo/ where the DVD will be mounted:  
   * \# mkdir \-p /mnt/repo/  
   * The \-p option ensures that the directory is created along with any necessary parent directories.

**Step 2: Mount the RHEL 9 DVD or ISO to /mnt/repo/**

* If you’re using an **ISO image**:  
  * \# mount \-o loop RHEL9.iso /mnt/repo/  
  * \-o loop treats the ISO file as a virtual device for mounting.  
* If you’re using a **physical DVD** and want it to mount automatically on reboot:  
  * **Add an entry to /etc/fstab**:  
    * \# vim /etc/fstab  
  * Add the following line:  
    * /dev/sr0 /mnt/repo/ iso9660 ro,user,auto 0 0  
    * /dev/sr0 is typically the device file for the CD/DVD drive.  
    * iso9660 is the filesystem type for DVDs.  
    * ro,user,auto specifies read-only mode, allows user mounting, and mounts at boot.  
  * To save and exit:  
    * Press Esc then type :wq and press Enter.  
  * Alternatively, you can append this line directly:  
    * \# echo "/dev/sr0 /mnt/repo/ iso9660 ro,user,auto 0 0" \>\> /etc/fstab  
1. **Mount the DVD**:  
   * \# mount \-a

**Step 3: Configure the Repository File**

1. **Copy the media.repo file from the DVD to the repository directory**:  
   * \# cp /mnt/repo/media.repo /etc/yum.repos.d/rhel9dvd.repo  
2. **Set permissions on the repository file**:  
   * \# chmod 644 /etc/yum.repos.d/rhel9dvd.repo  
   * This grants read and write permissions to the owner and read-only permissions to others.

**Step 4: Edit the Repository File**

1. **Open /etc/yum.repos.d/rhel9dvd.repo**:  
   * \# vim /etc/yum.repos.d/rhel9dvd.repo  
2. **Modify settings**:  
   * Change gpgcheck=0 to gpgcheck=1 (or keep gpgcheck=0 if skipping GPG verification).  
   * Add the following lines:  
     * enabled=1  
     * baseurl=file:///mnt/repo/  
     * gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release  
3. **Sample final configuration**:  
   * \[InstallMedia\]  
   * name=DVD for Red Hat Enterprise Linux 9.1 Server  
   * mediaid=1359576196.686790  
   * metadata\_expire=-1  
   * gpgcheck=1  
   * cost=500  
   * enabled=1  
   * baseurl=file:///mnt/repo/  
   * gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release  
4. **Save and exit** by pressing Esc, typing :wq, and pressing Enter.

**Step 5: Verify and Test the Repository**

1. **Clear the YUM and subscription-manager caches**:  
   * \# dnf clean all  
   * \# subscription-manager clean  
   * If you receive a "This system is not registered" warning, you can disable the plugin by editing /etc/yum/pluginconf.d/subscription-manager.conf and setting enabled=0.  
2. **List the enabled repositories**:  
   * \# dnf repolist enabled  
3. **Test by updating the package list**:  
   * \# dnf update

**Important Notes**

* **Disabling other repositories** is recommended to avoid conflicts and ensure updates are pulled exclusively from the DVD repository.  
* For better control and security, using the GPG key for verification is advised.

---

### Question 2: DNF-Yum

On ServerB, set up a local DNF repository using the /RHEL9.iso image mounted on the /mnt/disc/ directory.

**Overall explanation**  
**Steps to Set Up a Local DNF Repository with the RHEL9 ISO**

1. **Create the Mount Directory**  
   * **Command:** \# mkdir \-p /mnt/disc/  
   * **Explanation:** This command creates the /mnt/disc/ directory, where the ISO will be mounted. The \-p option ensures that any necessary parent directories are created if they don’t already exist.  
2. **Mount the ISO Image to the Directory**  
   * **Command:** \# mount \-o loop /RHEL9.iso /mnt/disc/  
   * **Alternative Command (with filesystem type):** \# mount \-t iso9660 \-o loop /RHEL9.iso /mnt/disc/  
   * **Explanation:** Mounting the ISO with the \-o loop option allows it to be treated as a physical disk. Specifying \-t iso9660 (optional) indicates the filesystem type typically used for CD/DVD images. This step is crucial for accessing the ISO’s contents directly.  
   * **Note for Physical Media:**  
     If using a physical DVD, mount it as follows:  
     * \# mount /dev/sr0 /mnt/disc/  
3. **Copy and Configure the Repository File**  
   * **Copy the Repo File:**  
     * \# cp /mnt/disc/media.repo /etc/yum.repos.d/rhel9dvd.repo  
     * This command copies the media.repo file from the ISO to /etc/yum.repos.d/, where DNF stores repository configuration files.  
   * **Set Permissions for the Repo File:**  
     * \# chmod 644 /etc/yum.repos.d/rhel9dvd.repo  
     * Setting permissions to 0644 makes the repo file readable by all users, which is necessary for DNF to access the file.  
4. **Edit the Repository File**  
   * **Command:** \# vim /etc/yum.repos.d/rhel9dvd.repo  
   * **Explanation:** Open the copied rhel9dvd.repo file for editing to adjust settings for the local repository.  
5. **Modify the Repository File Contents**  
   * Inside vim, add or modify the following lines to configure the repository:  
     * enabled=1  
     * baseurl=file:///mnt/disc/  
     * gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release  
     * gpgcheck=1  
   * **Explanation of Each Setting:**  
     * **enabled=1**: Activates the repository.  
     * **baseurl=file:///mnt/disc/**: Points to the local mount point of the ISO as the repository source.  
     * **gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release**: Specifies the location of the GPG key to verify package integrity.  
     * **gpgcheck=1**: Enables GPG key verification, an important security practice.  
   * **Final Repository File Format:**  
     * \[InstallMedia\]  
     * name=DVD for Red Hat Enterprise Linux 9.1 Server  
     * mediaid=1359576196.686790  
     * metadata\_expire=-1  
     * gpgcheck=1  
     * cost=500  
     * enabled=1  
     * baseurl=file:///mnt/disc/  
     * gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release  
6. **Clear Cache and Disable Subscription Manager Warnings**  
   * **Clear Cache:**  
     * \# dnf clean all  
   * **Subscription Manager Cleanup:**  
     * \# subscription-manager clean  
   * **Explanation:** Running dnf clean all clears cached metadata, ensuring the updated repository is loaded. You may see a "This system is not registered" warning; to suppress this, open /etc/yum/pluginconf.d/subscription-manager.conf and change enabled=1 to enabled=0.  
7. **Verify the Repository**  
   * **Command to List Enabled Repositories:**  
     * \# dnf repolist enabled  
     * This command lists all active repositories. Confirm that rhel9dvd or InstallMedia is listed as enabled.  
8. **Check Repository Functionality by Updating Packages**  
   * **Command:** \# dnf update  
   * **Explanation:** Running dnf update ensures that the repository is functional and accessible. For reliable results, temporarily disable other repositories to avoid conflicts by setting enabled=0 in their respective .repo files.

**Additional Notes:**

* **Why Use a Local Repository with an ISO?**  
  A local ISO-based repository provides access to RHEL packages without an internet connection, useful for isolated environments or testing.  
* **Troubleshooting Tips:**  
  * **ISO Mount Issues:** Confirm that the ISO is mounted by running df \-h to check if /mnt/disc is listed.  
  * **Repository Errors:** Double-check the baseurl and gpgkey paths for accuracy. Paths must match the local file structure precisely.

---



### Question 2: yum repository

**On ServerC, configure your system to use the YUM repositories available at:**

* http://ServerB/dvd/BaseOS  
* http://ServerB/dvd/AppStream

**Ensure these repositories are set as the default, and verify the configuration.**

**Overall explanation**  
**Answer:**

You can use either of the following methods to configure and enable the YUM repositories from ServerB:

**First Method: Using yum-config-manager**

1. **Install yum-config-manager (if not already installed)**:  
   * \# rpm \-ivh http://ServerB/dvd/BaseOS/Packages/yum-utils-\*.el9.noarch.rpm  
   * **Explanation**: Installs yum-config-manager, a tool for configuring and managing YUM repositories.  
   * **Tip**: Use Tab to auto-complete the package name if you encounter multiple versions of yum-utils.  
2. **Verify the Repository URLs**:  
   * \# curl http://ServerB/dvd/BaseOS  
   * \# curl http://ServerB/dvd/AppStream  
   * **Explanation**: Verifies that the URLs are accessible and that ServerB’s repositories are reachable.  
3. **Disable All Existing Repositories**:  
   * \# dnf config-manager \--set-disabled "\*"  
   * **Explanation**: Disables all previously configured repositories to ensure ServerC uses only the new repositories from ServerB.  
4. **Add BaseOS and AppStream Repositories**:  
   * \# dnf config-manager \--add-repo http://ServerB/dvd/BaseOS  
   * \# dnf config-manager \--add-repo http://ServerB/dvd/AppStream  
   * **Explanation**: Adds the specified repositories, allowing ServerC to access packages from BaseOS and AppStream on ServerB.  
5. **Verify the New Repository Files**:  
   * \# ls /etc/yum.repos.d/  
   * **Explanation**: Lists repository configuration files in /etc/yum.repos.d/ to confirm that the new .repo files were created.  
6. **Check Repository Settings**:  
   * Use cat to inspect the new repository files and ensure settings like enabled=1 and gpgcheck=0 are correctly applied:  
     * \# cat /etc/yum.repos.d/ServerB\_dvd\_BaseOS.repo  
     * \# cat /etc/yum.repos.d/ServerB\_dvd\_AppStream.repo  
7. **Clean DNF and Subscription-Manager Cache**:  
   * \# dnf clean all  
   * \# subscription-manager clean  
   * **Explanation**: Clears cached metadata, packages, and system registration information, ensuring a clean setup for testing the new repository configuration.  
8. **List Enabled Repositories**:  
   * \# dnf repolist  
   * **Explanation**: Lists all enabled repositories to confirm that BaseOS and AppStream from ServerB are active.

**Second Method: Manually Creating the Repository Configuration File**

1. **Verify Repository Access**:  
   * \# curl http://ServerB/dvd/BaseOS  
   * \# curl http://ServerB/dvd/AppStream  
   * **Explanation**: Confirms that ServerB’s repository URLs are accessible from ServerC.  
2. **Disable Existing Repositories**:  
   * \# mv /etc/yum.repos.d/\*.repo /tmp/  
   * **Explanation**: Moves all existing .repo files to /tmp, ensuring no other repositories are enabled by default.  
3. **Create a Custom Repository Configuration File**:  
   * \# vim /etc/yum.repos.d/rhel9.repo  
   * Press I to enter insert mode, then add the following lines:  
     * \[LocalRepo\_BaseOS\]  
     * name=LocalRepo\_BaseOS  
     * enabled=1  
     * gpgcheck=0  
     * baseurl=http://ServerB/dvd/BaseOS/  
     *    
     * \[LocalRepo\_AppStream\]  
     * name=LocalRepo\_AppStream  
     * enabled=1  
     * gpgcheck=0  
     * baseurl=http://ServerB/dvd/AppStream/  
   * **Explanation**:  
     * **enabled=1**: Ensures these repositories are enabled by default.  
     * **gpgcheck=0**: Disables GPG signature checking (set this based on security requirements).  
4. **Save and Exit**:  
   * Press Esc, then type :wq and press Enter to save and close the file.  
5. **Set Correct Permissions on the .repo File**:  
   * \# chmod 644 /etc/yum.repos.d/rhel9.repo  
   * **Explanation**: Ensures that the file is readable by all users but writable only by the root user. This prevents unauthorized modification.  
6. **Clean Subscription and DNF Cache**:  
   * \# subscription-manager clean  
   * \# dnf clean all  
   * **Explanation**: Clears cached subscription data and metadata, preparing the system for a fresh repository configuration.  
7. **List Enabled Repositories**:  
   * \# dnf repolist  
   * **Explanation**: Lists all enabled repositories, confirming that BaseOS and AppStream repositories are active.  
8. **Confirm Repository Functionality**:  
   * Test by updating system packages:  
     * \# dnf update  
   * **Explanation**: Running dnf update checks if ServerC can successfully retrieve and install packages from the configured BaseOS and AppStream repositories on ServerB.

**Additional Notes:**

* **Why Disable Existing Repositories?**: Disabling all other repositories avoids potential conflicts and ensures ServerC pulls packages only from ServerB, simulating a controlled environment.  
* **Common Errors**:  
  * **Permission Issues**: Run all commands with root privileges.  
  * **Network Accessibility**: Ensure ServerB is accessible from ServerC. If not, troubleshoot connectivity or DNS resolution issues.  
* **Verifying Access**: Regularly use dnf repolist and dnf update to confirm that repositories are correctly configured and accessible.

---


### Question 41: rpm

On rhel.server.com, install the package zsh which is located on the FTP server ftp://server.example.com under the /pub/updates directory. The FTP server credentials are:

* **Username**: admin  
* **Password**: admin

**Note:**  
The domain server.example.com is a placeholder. In real-world scenarios, use a real FTP server's IP address or update /etc/hosts to map server.example.com to an appropriate IP address in your environment.

* **Pass**  
* **Fail**

**Overall explanation**  
**Method 1: Download and Install via FTP Command-Line Tool**

1. **Access the FTP server**:  
   * \# ftp server.example.com  
   * **Explanation**: Connects to the FTP server.  
2. **Log in** with the provided credentials:  
   * When prompted, enter:  
     * **Username**: admin  
     * **Password**: admin  
3. **Navigate to the updates directory**:  
   * ftp\> cd /pub/updates  
4. **Switch to binary mode** (important for non-text files):  
   * ftp\> binary  
5. **Download the zsh package**:  
   * ftp\> get zsh.rpm  
6. **Exit the FTP session**:  
   * ftp\> exit  
7. **Install the downloaded package** using rpm:  
   * \# rpm \-ivh zsh.rpm  
   * **Explanation**: The rpm \-ivh command installs the downloaded .rpm file, with \-i for install, \-v for verbose, and \-h for progress.

**Method 2: Set Up an FTP-Based DNF Repository**

1. **Create a repository configuration file**:  
   * \# vim /etc/yum.repos.d/zsh.repo  
2. **Add repository details** to the file:  
   * \[zsh\]  
   * name=ZSH repository  
   * baseurl=ftp://server.example.com/pub/updates/  
   * enabled=1  
   * gpgcheck=0  
   * **Explanation**:  
     * baseurl: Points to the directory containing zsh.rpm on the FTP server.  
     * enabled=1: Enables the repository.  
     * gpgcheck=0: Disables GPG signature verification for this setup.  
3. **Install the package** using dnf:  
   * \# dnf install zsh \-y

**Method 3: Use curl to Download and Install**

1. **Download the package** directly using curl:  
   * \# curl \-u admin:admin \-o zsh.rpm ftp://server.example.com/pub/updates/zsh.rpm  
   * **Explanation**:  
     * \-u admin:admin: Supplies FTP credentials.  
     * \-o zsh.rpm: Specifies the output filename.  
2. **Install the downloaded package**:  
   * \# dnf install \-y zsh.rpm

**Method 4: Direct Installation via DNF with FTP URL**

1. **Install zsh directly from the FTP URL**:  
   * \# dnf install \-y ftp://admin:admin@server.example.com/pub/updates/zsh.rpm

**Verification of Installation**

1. **Check the installation**:  
   * \# zsh \--version  
   * **Explanation**: Confirm that zsh is installed correctly.

**Additional Notes**

* **Binary Mode** in FTP\*\*: Using binary mode ensures that files are transferred in a format compatible with executable binaries.  
* **SELinux Considerations**: If using SELinux, you might need additional configurations for FTP.  
* **Practicality**: Each method offers a different approach for practice and flexibility depending on the scenario in the exam.

---

