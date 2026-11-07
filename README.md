# OStim NPCs

Mod for The Elder Scrolls V: Skyrim which makes NPCs start OStim scenes with each other around the world, in an immersive, non-invasive and normal gameplay friendly way.

## Building

### Requirements
- [xmake](https://xmake.io/) 3.0.0 or newer
- [Visual Studio 2022](https://visualstudio.microsoft.com/) with the "Desktop development with C++" workload (for MSVC compiler)
- [Pyro](https://github.com/fireundubh/pyro/releases) (download a release and unzip it anywhere you want on your computer)
- [Skyrim SE Creation Kit](https://store.steampowered.com/app/1946180/Skyrim_Special_Edition_Creation_Kit/) so you have the Papyrus Compiler. Don't forget to unzip the `Scripts.zip` folder it comes with, which is put inside your Skyrim Data folder

### Setup
- Clone this repository
- Open the terminal, switch into the repository's folder and fetch submodules: `git submodule update --init --recursive`
- In the `pyro.config.json` file of this repository, set the `pyro_path` to where `pyro.exe` that you downloaded above resides. `game_path` is optional, you should only need to set it if Pyro has trouble finding the game folder. Don't commit changes to this file. Example of how `pyro.config.json` may look like:
```json
{
  "pyro_path": "C:\\Skyrim Projects\\pyro-master-1656807840\\pyro.exe",
  "game_path": ""
}
```
- Generate a Github personal access token with `public_repo` access scope and create a `.secrets` file in the same folder where `pyro.exe` resides. This is needed for Pyro to fetch the OStim NPCs Papyrus dependencies that reside in Github repositories. For more information, see [Pyro Remotes](https://wiki.fireundubh.com/pyro/remotes). The `.secrets` file should look something like this:
```ini
[github.com]
access_token = your_access_token
```

From here you have several options depending on what you're looking to do:
- `xmake papyrus` - compiles only the Papyrus scripts
- `xmake build` - builds only the DLL and PDB files
- `xmake dist --skip-dll` - compile only the Papyrus scripts and make `.zip` package to install with mod manager. It will reuse an already existing DLL file if there is any
- `xmake dist --skip-papyrus` - compile only the DLL, skipping Papyrus scripts compilation, and make `.zip` package to install with mod manager. It will reuse the already existing compiled `.pex` scripts for the `.zip` package
- `xmake dist` - builds the entire project (compile Papyrus scripts + compile DLL + make .zip package to install with mod manager)

The `.zip` package created by `xmake dist` commands will be created in `contrib\Artifact`.

For most cases or if you are unsure, `xmake dist` is what you should be using, since it does all the work and necessary packaging for you.

Run xmake from PowerShell or the Developer Command Prompt. From Git Bash, xmake detects MinGW instead of MSVC; if you need to use it, configure once with `xmake f -p windows -a x64`.

After every DLL build, `OStimNPCs.dll` and `OStimNPCs.pdb` are also copied to `SKSE\Plugins` in the repository root (ignored by git). If the `MO2_MODS_DIR` environment variable is set to your MO2 `mods` folder, they are copied to `<MO2_MODS_DIR>\OStimNPCs - <mode>\SKSE\Plugins` too.

You can compile the Papyrus scripts in the Creation Kit if you want to. However, Pyro is preferred since it anonymizes scripts properly (Papyrus compiler includes metadata in the compiled scripts that may have information about your computer and Windows username). Besides that, Pyro is also much faster and lightweight.

The compiled `.pex` scripts in `Scripts` are committed, since the Github CI build can't compile Papyrus. Recompile and commit them whenever you change a `.psc` file.

## Versioning and Git builds

OStim NPCs uses semantic versioning. When making a PR, upgrade the version in `xmake.lua` and `ostim_npcs.ppj` taking into account whether it should be a patch, minor or major version upgrade.

Failing to upgrade version means that the Git CI build automatic release will fail, because there was already a version built with the current version number.
