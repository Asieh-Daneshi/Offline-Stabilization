# Offline stabilisation of AOSLO videos

MATLAB code I used at the University Clinic Bonn (2020-2022) to stabilise adaptive-optics scanning laser ophthalmoscope (AOSLO) videos of the retina after recording, and to build clean averaged retinal images from them.

Eye movements distort AOSLO frames during the scan, so each frame has to be registered strip by strip to a reference frame before frames can be averaged.

## My contribution

- **Tuning the stabilisation.** The strip-based stabilisation toolbox (see below) was available in the lab, but with its original settings it failed on our recordings: about half of the frames were discarded because noise was not handled well, and the frames that remained were of poor quality. I re-tuned its parameters so that the maximum number of frames was kept, in some recordings all of them, at high image quality.
- **Automatic reference-frame selection** (`MainStabilizer.m` and helpers). The result of strip-based stabilisation depends strongly on the reference frame. My pipeline chooses it automatically:
  1. removes dark and sheared frames from the raw video (`BadFrameFinder.m`);
  2. keeps the sharpest frames as candidates, using the ratio of central to outer energy in the 2-D Fourier spectrum (`CandidateFrames.m`);
  3. registers all frames to each other with a translation model (`MyRegBatch.m`);
  4. picks as reference the candidates with the highest average structural similarity (SSIM) to all other frames, i.e. the least distorted ones (`BestFrame.m`).

## Strip-based stabilisation toolbox

`stabilizefromraw_*.m`, `StabilizeFromRaw_Function.m`, `StabilizerFromRaw_App.mlapp` and the folders `Stabilizing Programs`, `Correlation Programs`, `Reference Making Programs`, `Shift Analysis Programs` and `Utilities` are the AOSLO stabilisation toolbox used in the lab, which goes back to earlier AOSLO groups (see `AOSLO_GKR_SBS_readme.m`). Several `stabilizefromraw_multiple_*` files are versions adapted by different lab members. For Bonn data use `stabilizefromraw_multiple_ND_13_03_2019.m`; `README.txt` lists the thresholds that control how many strips and frames are kept.

## Changes in 2026

Three bugs in the reference-selection pipeline were fixed when the code was published:
- `BadFrameFinder.m`: the shear test compared each frame with itself, so it never rejected a frame. It now compares each frame with the median of the video (`shearThreshold`, set it to `Inf` to switch the test off), and it no longer deletes unrelated TIFF files in the folder.
- `BestFrame.m`: candidates were sorted in ascending order, so the least similar frames were returned. They are now sorted from most to least similar, and the comparison of a frame with itself is excluded.
- `CandidateFrames.m`: `delete frequency_ok` (which tries to delete a file) is replaced by `clear frequency_ok`.

## Requirements

MATLAB R2014b or later with the Image Processing Toolbox; `parfor` loops use the Parallel Computing Toolbox if available. `keep.m` (MATLAB File Exchange) must be on the path. The raw AOSLO recordings are not included.
