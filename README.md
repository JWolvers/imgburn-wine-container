![Github License](https://img.shields.io/github/license/JWolvers/imgburn-wine-container?style=flat-square)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/JWolvers/imgburn-wine-container/total)
![Maintenance](https://img.shields.io/maintenance/yes/2024?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/JWolvers/imgburn-wine-container?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/JWolvers/imgburn-wine-container?style=flat-square)
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)

# ImgBurn Docker Container

This Docker container runs ImgBurn via [WINE](https://www.winehq.org), so that you can back up your optical disks with the separation and portability capabilities of Docker on Linux.

It runs the ImgBurn and starts a virtual X server and a VNC server with Web GUI, so that you can interact with it.

⚠️ This project is not affiliated with ImgBurn ⚠️

## Table of Content

   * **[ImgBurn Docker Container](#ImgBurn-Docker-Container)**
      * [Table of Content](#table-of-content)
      * [Project Status](#project-status)
      * [Docker Images](#docker-images)
         * [Content](#content)
         * [Tags](#tags)
         * [Platforms](#platforms)
      * [Environment Variables](#environment-variables)
      * [Config Directory](#config-directory)
      * [Ports](#ports)
      * [Volumes](#volumes)
      * [Accessing the GUI](#accessing-the-gui)
      * [Security](#security)
         * [SSVNC](#ssvnc)
         * [Certificates](#certificates)
         * [VNC Password](#vnc-password)
         * [DH Parameters](#dh-parameters)
      * **[Installation](#installation)**
      * [Additional Information](#additional-information)
      * [Credits](#credits)

## Project Status

This project is a fork of [JonathanTreffler/backblaze-personal-wine-container](https://github.com/JonathanTreffler/backblaze-personal-wine-container), with minimal adjustments to run ImgBurn instead of the Backblaze personal backup client.

## Docker Images
### Content
Here are the main components of this image:
  * [S6-overlay], a process supervisor for containers.
  * [x11vnc], a X11 VNC server.
  * [xvfb], a X virtual framebuffer display server.
  * [openbox], a windows manager.
  * [noVNC], a HTML5 VNC client.
  * [NGINX], a high-performance HTTP server.
  * [stunnel], a proxy encrypting arbitrary TCP connections with SSL/TLS.
  * [WINE], a compatibility layer for windows applications on Linux
  * [Winetricks] is a helper script to download and install various redistributable runtime libraries needed to run some programs in Wine
  * [ImgBurn]

[S6-overlay]: https://github.com/just-containers/s6-overlay
[x11vnc]: http://www.karlrunge.com/x11vnc/
[xvfb]: http://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml
[openbox]: http://openbox.org
[noVNC]: https://github.com/novnc/noVNC
[NGINX]: https://www.nginx.com
[stunnel]: https://www.stunnel.org
[WINE]: https://www.winehq.org/
[Winetricks]: https://wiki.winehq.org/Winetricks
[ImgBurn]: https://www.imgburn.com/

### Tags

| Tag | Description |
|-----|-------------|
| latest | Latest stable version of the image based on ubuntu 20 |
| ubuntu22 | Latest stable version of the image based on ubuntu 22 |
| ubuntu18 | Latest stable version of the image based on ubuntu 18 **(End of Life - unmaintained)** |
| v1.x | Versioned stable releases based on ubuntu 20 |
| main | Automatic build of the main branch (may be unstable) based on ubuntu 20 |

There are currently no versioned ubuntu22 or ubuntu18 builds.

### Platforms

| Platform | Support |
|-----|-------------|
| linux/amd64 | Fully supported |
| linux/arm64 | Currently no support (maybe in the future) |
| linux/arm/v7 | No support |
| linux/arm/v6 | No support |
| linux/riscv64 | Currently no support (maybe in the future) |
| linux/s390x | No support |
| linux/ppc64le | No support |
| linux/386 | No support |

As ImgBurn only runs on Windows, there is no point in supporting windows platforms.

## Environment Variables

Environment variables can be set by adding one or more arguments `-e "<VAR>=<VALUE>"` to the `docker run` command.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`DISABLE_VIRTUAL_DESKTOP` | Disables Wine's Virtual Desktop Mode | false |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`USER_ID`| When mounting docker-volumes, permission issues can arise between the docker host and the container. You can pass the User_ID permissions to the container with this variable. | `1000` |
|`GROUP_ID`| When mounting docker-volumes, permission issues can arise between the docker host and the container. You can pass the Group_ID permissions to the container with this variable. | `1000` |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are deleted during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the virtual screen's window. (Has to be divisible by 4) | `900` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the virtual screen's window. (Has to be divisible by 4) | `700` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via a web browser or VNC client).  See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open-source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

## Config Directory
Inside the container, wine's configuration and with it ImgBurn's configuration is stored in the
`/config/wine/` directory.

This directory is also used to store the VNC password.  See the
[VNC Pasword](#vnc-password) section for more details.

## Ports

Here is the list of ports used by container.  They can be mapped to the host
via the `-p <HOST_PORT>:<CONTAINER_PORT>` parameter.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## Volumes

A minimum of 2 volumes need to be mounted to the container

  * /config - This is where Wine and ImgBurn will be installed
  * Storage - these are the locations you wish to ImgButn to have access to, any volume that is mounted as /drive_**driveletter** (from d up to z) will be mounted automatically for use in ImgBurn with their equivalent letter, for example /drive_d will be mounted as D:

You can mount drives with different paths, but these will need to be mounted manually within wine using the following method

1. Add your storage path as a wine drive, so ImgBurn can access it

    ````shell
    docker exec --user app imgburn-wine ln -s /backup_volume/ /config/wine/dosdevices/d:
    ````

2. Restart the docker to get Backblaze to recognize the new drive

    ````shell
    docker restart imgburn-wine
    ````

3. Reload the Web Interface

    ![Bildschirmfoto von 2022-01-16 14-49-45](https://user-images.githubusercontent.com/28999431/149662817-27f3c9e8-12ba-494c-898d-d9492541a5fb.png)

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:5800
```

  * Any VNC client:
```
<HOST IP ADDR>:5900
```

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

### SSVNC

[SSVNC] is a VNC viewer that adds encryption security to VNC connections.

While the Linux version of [SSVNC] works well, the Windows version has some
issues.  At the time of writing, the latest version `1.0.30` is not functional,
as a connection fails with the following error:
```
ReadExact: Socket error while reading
```
However, for your convienence, an unoffical and working version is provided
here:

https://github.com/jlesage/docker-baseimage-gui/raw/master/tools/ssvnc_windows_only-1.0.30-r1.zip

The only difference with the offical package is that the bundled version of
`stunnel` has been upgraded to version `5.49`, which fixes the connection
problems.

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:
  * By using the `VNC_PASSWORD` environment variable.
  * By creating a `.vncpass_clear` file at the root of the `/config` volume.
    This file should contains the password in clear-text.  During the container
    startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:
  * The type of communication channel (encrypted/unencrypted).
  * How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

Access to the host by unexpected users with sufficient privileges can be
dangerous as they can retrieve the password with the following methods:
  * By looking at the `VNC_PASSWORD` environment variable value via the
    `docker inspect` command.  By defaut, the `docker` command can be run only
    by the root user.  However, it is possible to configure the system to allow
    the `docker` command to be run by any users part of a specific group.
  * By decrypting the `/config/.vncpass` file.  This requires the user to have
    the appropriate permission to read the file:  it has to be root or be the
    user defined by the `USER_ID` environment variable.  Also, to be able to
    retrieve the correct decryption key, one needs to know that the content of
    the file was generated by `x11vnc`.

### DH Parameters

Diffie-Hellman (DH) parameters define how the [DH key-exchange] is performed.
More details about this algorithm can be found on the [OpenSSL Wiki].

DH Parameters are saved into the PEM encoded file located inside the container
at `/config/certs/dhparam.pem`.  By default, when this file is missing, 2048
bits DH parameters are automatically generated.  Note that this one-time
operation takes some time to perform and increases the startup time of the
container.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html
[DH key-exchange]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[OpenSSL Wiki]: https://wiki.openssl.org/index.php/Diffie_Hellman

## Installation:
1. Check for yourself if using this docker complies with the ImgBurn [terms of service](https://www.imgburn.com/index.php?act=terms)
1. Modify the following for your setup (in terms of [ports](#ports), [volumes](#volumes) and [environment variables](#environment-variables)) and run it

    **NOTE**: root priviliges may be needed
    ````shell
    docker run \
        -p 8080:5800 \
        --init \
        --name imgburn-wine \
        -v "[backup folder]/:/drive_d/" \
        -v "[config folder]/:/config/" \
        tessypowder/backblaze-personal-wine:latest
    ````

1. Open the Web Interface (on the port you specified in the docker run command, in this example 8080):
2. You may see wine being updated, this will take a couple of minutes
   
   ![image](https://github.com/xela1/backblaze-personal-wine-container/assets/357319/4f401b31-8d1d-40fe-85a3-ec4637c23bf5)
3. Follow the ImgBurn installer as you normally would, it is important that you do not change the install location!
4. After install is complete ImgBurn should Automatically start.
5. Use ImgBurn as usual.
  
## Additional Information

1. You can browse the files accessible to ImgBurn using:
    ````shell
    docker exec --user app imgburn-wine wine explorer
    ````
2. You can open the Wine Config using:
    ````shell
    docker exec --user app imgburn-wine winecfg
    ````
3. We are using Wine's virtual desktop mode as default and are using a default screen resoluzion of 900x700 pixels. It's larger than the ImgBUrn's UI. You can always modify the resolution as you like with DISPLAY_WIDTH and DISPLAY_HEIGHT:
    ````shell
    docker run ... -e "DISPLAY_WIDTH=1280" -e "DISPLAY_HEIGHT=800" ...
    ````

# Credits
This was originally developed by @JonathanTreffler (https://github.com/JonathanTreffler/backblaze-personal-wine-container).

The ImgBurn name, logo and application is the property of ImgBurn.

This docker does not redistribute the ImgBUrn application. It gets downloaded from the official ImgBUrn Servers.

This docker image is based on @jlesage 's excellent [base image](https://github.com/jlesage/docker-baseimage-gui).

## Contributors:
This project was made by:

<a href="https://github.com/JWolvers/imgburn-wine-container/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=JWolvers/imgburn-wine-container" />
</a>
