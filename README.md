Notes

***

Test Setup :
* Custom Match on House, Bomb
* 1 round only, 1 minute
* Attacker | Thatcher with -
  * L85A2 (2x, Flash Hider, Vertical Grip, Mark 1-4 Skin, Black Attachments and Skating Skeleton)
  * Pistol (Muzzle Break, Laser, Cold War-VNM Skin and Black Attachments)
  * Claymore
* Spawn should be Front Street
* Spawn will be the same and no need to move

Findings :
* Players information in a match is always present in each file. But map information is always present in the first round file. So you can, for example, replace the 3rd round of Favela replay with X (anything but first round) round of Consulate. The map will stay the same but players will change according to the Consulate file.
* Game doesn't parses the filename for Date/Time info.
* File look a Zstandard frame but it'd take some magic to make it parsable. (Bruteforce approach?) (`le u32 zstdHeader @ 0x0;`)

Questions :
* Can I put more frames? If yes then will that get parsed?
* Is player's metadata fetched online whenever I start a replay? or its hardcoded in the replay file?
* How the recording is actually happening? Is every frame recorded? or is there some other method of achieving this?

Links : 
Specs for zstd (RFC8878) -> https://datatracker.ietf.org/doc/html/rfc8878
