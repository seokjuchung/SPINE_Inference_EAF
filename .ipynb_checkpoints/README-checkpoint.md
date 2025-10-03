# Fermilab EAF — quick guide

EAF is a Fermilab GPU cluster (NVIDIA A100). If you have a Fermilab Services account, you also have EAF access.

Notes
- Each user gets a single GPU with a memory quota. Use EAF for in-house sample production and light workloads. For heavy jobs, use Polaris or hand off to the production team.

## Access from offsite

You need either a VPN or a browser proxy.

Option: SOCKS proxy for your browser (Firefox)
1. Start a dynamic SOCKS proxy to a FNAL host:
   ```bash
   ssh -D 3128 USER@FNAL_MACHINE
   ```
2. In Firefox, set the Automatic proxy configuration URL to the provided PAC file: https://www.nevis.columbia.edu/~sc5303/fnal-proxy.pac

Tip: The PAC file assumes port 3128, matching the command above.

## Storage and SPINE paths

- EAF mounts nearly the same disks as the GPVMs, except `/pnfs` is not mounted.
- For SPINE software, use: `/exp/sbnd/app/users/sc5303/SPINE`.

## Apptainer

EAF does not include Apptainer by default. The easiest route is to install it inside a Conda environment.

Quota tip: EAF has a small `/home` quota. Point Conda/Pip/Apptainer caches to `/exp/sbnd/data` or `/exp/sbnd/app` to avoid filling `/home`.

Recommended cache settings (add to your shell startup):
```bash
export APPTAINER_CACHEDIR=/exp/sbnd/data/users/USERNAME/apptainer_cache
export PIP_CACHE_DIR=/exp/sbnd/data/users/USERNAME/pip_cache
export XDG_CACHE_HOME=/exp/sbnd/data/users/USERNAME/.cache
```

Example `.condarc`:
```
pkgs_dirs:
  - /exp/sbnd/data/users/sc5303/apptainer_cache/pkgs
envs_dirs:
  - /exp/sbnd/data/users/sc5303/apptainer_cache/envs
channels:
  - conda-forge
solver: libmamba
```

## OpT0Finder

Build OpT0Finder (from the repository root):
```bash
source configure.sh
make -j
```

## Inference

Inference uses a trained model to produce predictions on unseen data. In this workflow, it creates HDF5 files from LArCV inputs.

Script used: `/exp/sbnd/app/users/sc5303/SPINE/inference/inference.sh`

Key variables inside the script
1. CFG — Configuration file path
2. LOG_DIR — Directory for logs
3. FNAME — Input LArCV file(s); can be a list
4. workdir — Output directory (use `/exp/sbnd/data` due to size)
5. container — Apptainer image path
6. CUDA_VISIBLE_DEVICES — Set to `0` (EAF provides one GPU)

Ensure the output directory exists and has sufficient space.

## Sources

Where to get components:
1. Inference bash script: https://github.com/bear-is-asleep/sbnd_spine_train/blob/master/deghost/train_uresnet.sh (modify for EAF)
2. Configuration files (CFG): https://github.com/DeepLearnPhysics/spine-prod/tree/main/config/sbnd

Need to pull from github
1. OpT0Finder: https://github.com/bear-is-asleep/OpT0Finder
2. spine: https://github.com/DeepLearnPhysics/spine/tree/v0.7.6
3. spine-prod: https://github.com/DeepLearnPhysics/spine-prod


 