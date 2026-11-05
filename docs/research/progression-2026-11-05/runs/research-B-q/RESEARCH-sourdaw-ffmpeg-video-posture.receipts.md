# Evidence receipts: RESEARCH-sourdaw-ffmpeg-video-posture

Sidecar to [the research artifact](RESEARCH-sourdaw-ffmpeg-video-posture.md). All fetches on
2026-11-05 from this Mac (macOS 27.2, build 26B123, arm64). Downloads kept in `/tmp/rq-ffmpeg/`,
outside any repository.

## E-1 Fetched primary documents

| File | Source URL | SHA-256 |
| --- | --- | --- |
| legal.html | https://ffmpeg.org/legal.html | 0c0f84b347baa5edb55ad594cb9b8dc3a6ae47b652131ff4533a16b3773e89df |
| configure | https://raw.githubusercontent.com/FFmpeg/FFmpeg/master/configure (master at 0893feba6528, committed 2026-11-05T04:43:58Z) | b7aef8b590028bd90261b628ad3fdfd2456d1ac282f8b6d65571bbe190ad78cf |
| lgpl21.txt | https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt | 20e50fe7aae3e56378ebf0417d9de904f55a0e61e4df315333e632a4d3555d95 |
| gpl2.txt | https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt | edaef632cbb643e4e7a221717a6c441a4c1a7c918e6e4d56debc3d8739b233f6 |
| gplfaq.html | https://www.gnu.org/licenses/gpl-faq.html | 6b48c709107e216b22c8415ed5c190c1c10818ac79f792563dfa501ee8dcec14 |
| config.h | chromium/third_party/ffmpeg master, `chromium/config/Chrome/mac/arm64/config.h` | eaa3c9932afbb92213332270a5bc8785108b83cf1a944fa17eb767b518eaf1eb |
| config_components.h | same directory, `config_components.h` | c23d36375a4195410d50e60bebe7ad45011044310cf05aaeedaae2779c9a34ec |

## E-2 FFmpeg configure license lists (untouched excerpt)

```
EXTERNAL_LIBRARY_GPL_LIST="
    avisynth
    frei0r
    libcdio
    libdavs2
    libdvdnav
    libdvdread
    librubberband
    libvidstab
    libx264
    libx265
    libxavs
    libxavs2
    libxvid
"
EXTERNAL_LIBRARY_NONFREE_LIST="
    decklink
    libfdk_aac
    libfdk_xhe_aac
    libmpeghdec
"
```

OS-backed encoder declarations, none depending on `gpl` or `nonfree`:

```
3613:h264_mf_encoder_deps="mediafoundation"
3639:hevc_mf_encoder_deps="mediafoundation"
3785:h264_videotoolbox_encoder_deps="pthreads"
3787:hevc_videotoolbox_encoder_deps="pthreads"
3789:prores_videotoolbox_encoder_deps="pthreads"
```

`grep -c '^[a-z0-9_]+_deps="[^"]*\bgpl\b'` over configure returned 33; every match shown was a
libavfilter filter (for example `cropdetect_filter_deps="gpl"`).

`libavcodec/libx264.c` header: the wrapper file itself carries the LGPL 2.1-or-later notice.

## E-3 Electron and Chromium FFmpeg build (untouched excerpts)

`electron/electron` main, `build/args/release.gn`:

```
# By default, Electron builds ffmpeg with proprietary codecs enabled. In order
# to facilitate users who don't want to ship proprietary codecs in ffmpeg, or
# who have an LGPL requirement to ship ffmpeg as a dynamically linked library,
# we build ffmpeg as a shared library.
is_component_ffmpeg = true
```

`build/args/all.gn`:

```
59:ffmpeg_branding = "Chrome"
60-proprietary_codecs = true
```

Chromium FFmpeg, Chrome branding, mac arm64:

```
#define FFMPEG_LICENSE "LGPL version 2.1 or later"
#define CONFIG_GPL 0
#define CONFIG_NONFREE 0
#define CONFIG_H264_DECODER 1
#define CONFIG_AAC_DECODER 1
#define CONFIG_PRORES_DECODER 0
```

`grep -c "_ENCODER 1" config_components.h` returned `0`.

## E-4 AVFoundation exercise

Command, 2026-11-05T09:13:02Z, Swift 6.4.2, macOS SDK 27.2, Apple silicon:
`swiftc -O -o probe probe.swift && ./probe`. Source:
[RESEARCH-sourdaw-ffmpeg-video-posture.avfoundation-probe.swift](RESEARCH-sourdaw-ffmpeg-video-posture.avfoundation-probe.swift).
It writes 24 synthetic 1920x1080 frames per codec with `AVAssetWriter` into a `.mov`, then decodes
every frame back with `AVAssetReader`. Status `2` is `completed` for both writer and reader.

Untouched output:

```
codec=apco canApply=true writerStatus=2 err=nil fourcc=apco bytes=493677 decodedFrames=24 readerStatus=2
codec=apcn canApply=true writerStatus=2 err=nil fourcc=apcn bytes=510813 decodedFrames=24 readerStatus=2
codec=avc1 canApply=true writerStatus=2 err=nil fourcc=avc1 bytes=14744 decodedFrames=24 readerStatus=2
codec=hvc1 canApply=true writerStatus=2 err=nil fourcc=hvc1 bytes=14186 decodedFrames=24 readerStatus=2
```

`apco` is ProRes 422 Proxy, `apcn` ProRes 422, `avc1` H.264, `hvc1` HEVC. No Windows machine was
available, so Media Foundation was not exercised.

## E-5 System FFmpeg presence on this Mac

```
ls: /usr/bin/ffmpeg: No such file or directory
ffmpeg not found
ffprobe not found
```

This proves only that this macOS install has no FFmpeg on `PATH` or in `/usr/bin`; it is one
machine, not a population.

## E-6 Third-party distribution builds

- Homebrew `ffmpeg` formula (homebrew-core main, version 9.0.2): `license "GPL-3.0-or-later"`,
  configure arguments include `--enable-gpl`, `--enable-version3`, `--enable-libx264`,
  `--enable-libx265`; formula API reports `GPL-3.0-or-later`.
- gyan.dev Windows builds page (release 9.0.2, 2026-09-19): states all builds are licensed as
  GPLv3 and lists libx264 among bundled libraries.
