# Everdrive FDS Save file patch maker

This project creates ROMs that can be loaded on an Everdrive.

After the ROM starts, you remove the Everdrive cart and swap in the FDS Ram adapter.

With the RAM adapter in place you press a button on the controller and it will attempt to overwrite a file on the disk.

It will notify that it's started by playing an audible beep. When finished it will attempt to start the game.

## How to create a patch

So because it's very easy to create a patch that bricks your disks, I've not made an easy 'wizard' to create the patches. You will need cc65, a hex editor, and some FDS knowledge. I'll use FDS Explorer to look up  https://www.romhacking.net/utilities/662/

If you open "patch.s" there are 4 segments that need to be updated:
- DiskIDString is an identifier that will be checked against the disk to try to prevent writing the file to the wrong disk. If you open the FDS file in a hex editor, you will see a text "\*NINTENDO-HVC\*", the ten bytes following is the DiskID. There are different DiskIDs for every disk and side, so make sure you pick the correct one.

![DiskID](img0.PNG)

- FileNo is the "No" field in FDS Explorer, it's a number that starts at 0 for the first file and increments.

- SaveFileHeader has 3 relevant values:
  - The File ID which is the (ID in FDS Explorer)
  - An exactly 8 character long Filename (Filename in FDS Explorer)
  - The Address where the data will be placed when loaded (Address in FDS Explorer)

- SaveFileData is the actual data to be written to the file.

The example patch.s in the project is for Super Mario Bros 2, and will create a save with 4 stars.

After modifying the patch to whatever you want, run 'make' in the folder to build the ROM.


