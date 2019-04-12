FROM woahbase/alpine-ssh

# Start from a base that already has ssh (and curl, rsync, git) installed (because I'm lazy)
RUN apk --update add rdiff-backup

# done and done
