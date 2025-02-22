# Oscillody
- - -
## Real-time oscilloscope-based audio visualizer
- - -
Oscillody is an easy-to-use program developed by [Akosmo](https://akosmo.carrd.co) to create audio visualizers, whether it is for music, or recordings.
It displays the waveform of your imported audio in real-time. You can customize the visualizer to your taste with plenty of options, export the result as a video, and do whatever you want with it.
[Click here to watch the trailer](https://www.youtube.com/watch?v=djpyHuEzR0w).

## How and why it was built
- - -
This project started on July 6, 2024, as a personal challenge to make audio visualization using the [Godot Engine](https://godotengine.org), a free and open-source game engine. Since this is my first project, it served as a learning experience for future game projects.
It was built using Godot's ability to return audio sample data, perform FFT, and export videos.
I've always liked audio visualizers, especially the ones with waveform display. However, it was not easy for me to find a simple program to create such visualizers for my videos, without using high-end video editing software.
Even if there might be options around nowadays, this project also serves as a free and simple alternative for those who just want to create a simple visualizer for any reason, without having to tweak a lot of settings or spending money on a video editor.

## Free and open-source
- - -
This is a free and open-source project distributed under the GPL-3.0-or-later versions. You're free to take a look at the code, however, I'm not accepting code contributions at the moment.
Oscillody will always be free (here as in 0 cost), but you can find many ways to support me on my [homepage](https://akosmo.carrd.co).

## How to use
- - -
### Files panel:
- Import MP3 files. Either just a master to use with one waveform displayed, or up to 4 stems of the master to be displayed in 4 different waveforms. The audio output is still going to be the imported master.
- Export MP4. Resolution is set to 1440p. Videos are exported first as a sequence of PNG files, to the Temp folder in the app's directory. Once it's done rendering PNGs, it launches FFmpeg (see how to install below) and encodes all PNG files to MP4, exporting to your chosen path. During the encoding step, the app will be frozen, so to cancel it, try closing the command prompt. PNGs are removed once the encoding finishes or any process is canceled (this may trigger your antivirus).

### Customize panel:
- Load and save presets.
- Change the amount of displayed waveforms and their layout.
- Add text.
- Change the look of the waveform.
- Change the background between a solid color, an image, or a domain warping shader.
- Add an image to the middle of the visualizer.
- Use post-processing effects.
- Make things react to audio.

### Settings panel:
- Change the amount of displayed audio samples (requires the app to be restarted).
- Turn on/off low-specs mode if the framerate is constantly and severely under 60 FPS. Use this if you're noticing weird waveform behavior.

For more details, each option has a tooltip. Just hover your mouse over it.

Use space to play/pause, F10 to toggle UI visibility, and F11 to fullscreen.

Also note that Oscillody is a Windows-only app.

## How to install FFmpeg and choose its path in Oscillody
- - -
Access [FFmpeg's download page](https://www.ffmpeg.org/download.html#build-windows), and click on gyan.dev's Windows build (under "Get packages & executable files").
Look for "latest git master branch build" under "git master builds". Download either the essentials or full version.
Choose a location and extract the folder.
In the app, select "Files", then select click the button to select FFmpeg path. Navigate to the location where you extracted FFmpeg's zip file, and go in the "bin" folder, and select "FFmpeg.exe".

## Credits and inspiration
- - -
- [Hash Function by James Harnett](https://www.shadertoy.com/view/MdcfDj)
- [Blend Modes by Jamie Owen](https://github.com/jamieowen/glsl-blend)
- [ALMAMplayer](https://almam.itch.io/almamplayer), [Wav2Bar](https://picorims.github.io/wav2bar-website/), and [The Book of Shaders](https://thebookofshaders.com/13/) for inspirations.
- My partner Gwen Hemoxia!
- All other testers listed below.
- All [Godot](https://github.com/godotengine/godot) contributors!

## Testers
- - -
- [Gwen Hemoxia](https://bsky.app/profile/gwenhemoxia.bsky.social)
- [Endobear](https://bsky.app/profile/endobear.bsky.social)
- [Emerald](https://bsky.app/profile/emmy2gay.bsky.social)
- guess
- [soar](https://www.youtube.com/@soaryoutube)
- [Kefflen R.](https://github.com/kefflen)

## App status and planned updates
- - -
The app is in development as of February 23, 2025, but my current focus is on game development for now.

### Planned updates:
- Proper rendering and encoding progress bar
- Audio spectrum (along with smoother audio reaction)
- Option for video background
- WAV importing
- Custom user shaders
- Reaction strength control for each element
- Icon rotation (incl. for reaction)
- Background wiggle

## Support
- - -
If you need help in using the app, feel free to contact me via any links [here](https://akosmo.carrd.co).

## Known issues
- - -
- Leaving maximized window doesn't return to its previous size.
- Waveform may look incomplete depending on your output device and audio settings (e.g. some headsets).
- Spectrum data (used for audio reaction) returns jittered values.
- The title may appear on the wrong place on the first frame.