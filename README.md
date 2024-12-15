(Card) Forge for private (remote) use
=====================================

Forge for personal/private use (rdesktop)

> [!NOTE]
> This image is based on my [gbraad-devenv/fedora](https://github.com/gbraad-devenv/fedora) image, and is therefore personalized;
> it uses  `gbraad` as user with my [dotfiles](https://github.com/gbraad/dotfiles) and tailored to use services exposed by my [homelab](https://github.com/gbraad-homelab) setup.


## Usage instructions

```shell
$ podman run -d --name cardforge \
   --hostname ${HOSTNAME}-cardforge -p 8444:8444 \
   -v ~/.cache/forge:/home/gbraad/.cache/forge \
   ghcr.io/gbraad-gaming/cardforge:latest
$ podman exec -it cardforge su - gbraad
$ kasmvncserver
```

This allows you to open the remote session from your IP, like
`https://[remote_ip]:8444`. 

Otherwise, you can use tailscale to allow remote use:

```shell
$ sudo systemctl enable --now tailscaled
$ sudo tailscale up
$ tailscale ip
```

... and then open `https://[tailscale_ip]:8444`

### Devcontainer

A devcontainer is available for testing purposes. While it starts, the kasmvnc server
can not be used on localhost. Preferably the following can be done

As `root`
```
$ tmux new-session -s tailscaled -d
$ tmux send -t tailscaled "tailscaled" ENTER
$ tailscale up
```

and then use another user:
```
$ su - gbraad
$ kasmvncserver
$ tailscale ip
```

... and then open `https://[tailscale_ip]:8444`
