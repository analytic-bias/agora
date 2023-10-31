# Running Games Locally

The installation instructions are not yet tested on Mac/Windows. Comments very welcome!

There are several options to play a game locally:

- VSCode Dev Container: needs `docker` installed on your machine
- Codespaces: Needs active internet connection and computing time is limited.
- Gitpod: does not work yet (I that true?)
- Manual installation: Needs `npm` installed on your system

The recommended option is "VSCode Dev containers" but you may choose any option above depending on your setup.

## VSCode Dev Containers

1.  **Install Docker and Dev Containers** *(once)*:<br/>
    See [official instructions](https://code.visualstudio.com/docs/devcontainers/containers#_getting-started).
    Explicitely this means:
    * Install docker engine if you have not yet: [Instructions](https://docs.docker.com/engine/install/).
      I followed the "Server" instructions for linux.
    * Note that on Linux you need to add your user to the `docker` group
      ([see instructions](https://docs.docker.com/engine/install/linux-postinstall/)) and probably reboot.
    * Open the games folder in VSCode: `cd NNG4 && code .` or "Open Folder" within VSCode
    * a message appears prompting you to install the "Dev Containers" extension (by Microsoft). (Alternatively install it from the VSCode extensions).

2.  **Open Project in Dev Container** *(everytime)*:<br/>
    Once you have the Dev Containers Extension installed, (re)open the project folder of your game in VSCode.
    A message appears asking you to "Reopen in Container".

    * The first start will take a while, ca. 2-10 minutes. After the first
      start this should be very quickly.
    * Once built, you can open http://localhost:3000 in your browser. which should load the game

3.  **Editing Files** *(everytime)*:<br/>
    After editing some Lean files in VSCode, open VSCode's terminal (View > Terminal) and run `lake build`. Now you can reload your browser to see the changes.

### Errors

* If you don't get the pop-up, you might have disabled them and you can reenable it by
  running the `remote-containers.showReopenInContainerNotificationReset` command in vscode.
* If the starting the container fails, in particular with a message `Error: network xyz not found`,
  you might have deleted stuff from docker via your shell. Try deleting the container and image
  explicitely in VSCode (left side, "Docker" icon). Then reopen vscode and let it rebuild the
  container. (this will again take some time)

## Codespaces

You can work on your game using Github codespaces (click "Code" and then "Codespaces" and then "create codespace on main"). It it should run the game locally in the background. You can open it for example under "Ports" and clicking on "Open in Browser".

Note: You have to wait until npm started properly. In particular, this is after a message like `[client] webpack 5.81.0 compiled successfully in 38119 ms` appears in the terminal, which might take a good while.

As with devcontainers, you need to run `lake build` after changing any lean files and then reload the browser.

## Gitpod

TODO: Not sure this works yet!

Open the game clicking on the gitpod link. Again you will need to wait until it is fully built and then enter `lake build` in the shell whenever you made changes.

## Manual installation

This installs the `lean4game` manually on your computer. (It is the same installation as one would
use to setup a proper server online, only the run command (i.e. `npm start`) is different.)

Install `nvm`:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
```
then reopen bash and test with `command -v nvm` if it is available (Should print "nvm").

Now install node:
```bash
nvm install node
```

Clone the game (e.g. `NNG4` here):
```bash
git clone https://github.com/hhu-adam/NNG4.git
# or: git clone git@github.com:hhu-adam/NNG4.git
```

Download dependencies and build the game:
```bash
cd NNG4
lake update
lake exe cache get   # if your game depends on mathlib
lake build
```

Clone the game repository into a directory next to the game:
```bash
cd ..
git clone https://github.com/leanprover-community/lean4game.git
# or: git clone git@github.com:leanprover-community/lean4game.git
```
The folders `NNG4` and `lean4game` must be in the same directory!

In `lean4game`, install dependencies:
```bash
cd lean4game
npm install
```

Run the game:
```bash
npm start
```

This takes a little time. Eventually, the game is available on http://localhost:3000/#/g/local/NNG4. Replace `NNG4` with the folder name of your local game.

## Modifying the GameServer

When modifying the game engine itself (in particular the content in `lean4game/server`) you can test it live with the same setup as above (manual installation) by setting `export NODE_ENV=development` inside your local game before building it:

```bash
cd NNG4
export NODE_ENV=development
lake update
lake build
```
This causes lake to search locally for the `GameServer` lake package instead of using the version from github. Therefore, when you `lake build` your game, it will rebuild with the modified `GameServer`.
