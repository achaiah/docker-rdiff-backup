# docker-rdiff-backup
Docker container with ssh and rdiff-backup to use as a backup solution. I use it to back up remote host to a local NAS (but you can do remote-to-remote or local-to-remote as well, just need rdiff-backup on each side).

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
    networks:
 ```
