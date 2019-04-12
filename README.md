# docker-rdiff-backup
Docker container with ssh and rdiff-backup to use as a backup solution. I use it to back up a remote host to a local NAS (but you can do remote-to-remote or local-to-remote as well, just need rdiff-backup on each side).

Mount your volumes from host into this container. I suggest something simple like `/bckp/dir1`, `/bckp/dir2/dir2_subdir` etc. You may also need to expose a port that is different than 22 (e.g. if you're running through a reverse proxy). In that case, you will want to specify a `remote-schema` for your rdiff-backup like so:
```
rdiff-backup -v5 --print-statistics --remote-schema "ssh -C -p7777 %s rdiff-backup --server" alpine@server.com::/bckp /local/storage/dir
```

Here's a full docker-compose snippet that exposes more options:
```
  rdiffbckp:
    image: achaiah/docker-rdiff-backup
    container_name: rdiffbckp
    restart: always
    environment:
      - CNTUSER=alpine
      - CNTPASS=insecurebydefault
      - ROOTPASS=insecurebydefaultroot
      - PGID=1000
      - PUID=1000
    volumes:
       - /nginx:/bckp/nginx
       - /data:/bckp/data
       - /app:/bckp/app
    ports:
      - "7777:22"
 ```
 
##### Security
It is generally a bad idea to use login/password so instead you should use rsa keys. For that you will need to:
  1. [Generate public/private key pair](https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/)
  2. [Disable password-based logins ([see Step 4](https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/))
  3. Mount your modified `sshd_config` as well as your `authorized_keys` inside the container so they don't get wiped when your container is re-created
 Your `volumes:` section might look like this:
 ```
 volumes:
     - /nginx:/bckp/nginx
     - /data:/bckp/data
     - /app:/bckp/app
     -/rdiff/authorized_keys:/etc/ssh/sshd_config
     -/rdiff/.ssh/authorized_keys:/home/alpine/.ssh/authorized_keys
 ```
 Finally, you'll want to make sure you reference the rsa file when calling rdiff-backup:
 ```
rdiff-backup -v5 --print-statistics --remote-schema "ssh -i /somedir/my_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -C -p7777 %s rdiff-backup --server" alpine@server.com::/bckp /local/storage/dir
```
