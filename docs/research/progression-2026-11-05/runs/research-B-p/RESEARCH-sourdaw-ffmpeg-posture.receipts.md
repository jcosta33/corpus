# Evidence receipts: RESEARCH-sourdaw-ffmpeg-posture

Untyped sidecar to [RESEARCH-sourdaw-ffmpeg-posture](RESEARCH-sourdaw-ffmpeg-posture.md).
Collected 2026-11-05 from a macOS host. Web pages were read through a fetch-and-summarize tool,
so page quotes below are short excerpts returned by that tool, not full captures. Command outputs
are untouched excerpts.

## E-01 Electron build flags (source, `electron/electron` default branch, read 2026-11-05)

```
$ gh api repos/electron/electron/contents/build/args/all.gn -H "Accept: application/vnd.github.raw" | grep -n -i -E "codec|ffmpeg"
59:ffmpeg_branding = "Chrome"
60:proprietary_codecs = true
```

```
$ gh api repos/electron/electron/contents/build/args/release.gn ...
# By default, Electron builds ffmpeg with proprietary codecs enabled. In order
# to facilitate users who don't want to ship proprietary codecs in ffmpeg, or
# who have an LGPL requirement to ship ffmpeg as a dynamically linked library,
# we build ffmpeg as a shared library.
is_component_ffmpeg = true
```

```
$ gh api repos/electron/electron/contents/build/args/ffmpeg.gn ...
ffmpeg_branding = "Chromium"
proprietary_codecs = false
```

```
$ gh release view --repo electron/electron --json tagName,publishedAt,assets ...
{"date":"2026-11-04T21:21:59Z","ff":["ffmpeg-v45.2.3-darwin-arm64.zip","ffmpeg-v45.2.3-darwin-x64.zip", ... "ffmpeg-v45.2.3-win32-x64.zip"],"tag":"v45.2.3"}
```

## E-02 FFmpeg source (`FFmpeg/FFmpeg` master `0893feba6528`, committed 2026-11-05T04:43:58Z)

`libavcodec/allcodecs.c` registers, among others:

```
95:extern const FFCodec ff_dnxhd_encoder;
96:extern const FFCodec ff_dnxhd_decoder;
151:extern const FFCodec ff_h264_decoder;
161:extern const FFCodec ff_hevc_decoder;
271:extern const FFCodec ff_prores_encoder;
272:extern const FFCodec ff_prores_decoder;
274:extern const FFCodec ff_prores_ks_encoder;
426:extern const FFCodec ff_aac_encoder;
757:extern const FFCodec ff_aac_at_encoder;
834:extern const FFCodec ff_libx264_encoder;
852:extern const FFCodec ff_aac_mf_encoder;
872:extern const FFCodec ff_libopenh264_encoder;
878:extern const FFCodec ff_h264_mf_encoder;
885:extern const FFCodec ff_h264_videotoolbox_encoder;
893:extern const FFCodec ff_hevc_mf_encoder;
900:extern const FFCodec ff_hevc_videotoolbox_encoder;
917:extern const FFCodec ff_prores_videotoolbox_encoder;
```

`configure`:

```
2005:EXTERNAL_LIBRARY_GPL_LIST="
2006-    avisynth
...
2014-    libx264
2015-    libx265
...
2021:EXTERNAL_LIBRARY_NONFREE_LIST="
2022-    decklink
2023-    libfdk_aac
2024-    libfdk_xhe_aac
2025-    libmpeghdec
261:  --enable-libopenh264     enable H.264 encoding via OpenH264 [no]
2087:    libopenh264
```

`libopenh264` sits on line 2087, outside the GPL list (2005-2017) and the nonfree list (2021-2026).

## E-03 Homebrew FFmpeg formula (`Homebrew/homebrew-core` `Formula/f/ffmpeg.rb`, read 2026-11-05)

```
4:  url "https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz"
9:  license "GPL-3.0-or-later"
42:  depends_on "x264"
43:  depends_on "x265"
70:      --enable-version3
75:      --enable-gpl
78:      --enable-libx264
83:      --enable-libx265
```

## E-04 Apple developer documentation JSON (read 2026-11-05)

`https://developer.apple.com/tutorials/data/documentation/avfoundation/avvideocodectype.json`
lists the constants `h264`, `hevc`, `hevcWithAlpha`, `jpeg`, `proRes422`, `proRes422HQ`,
`proRes422LT`, `proRes422Proxy`, `proRes4444`, `appleProRes4444XQ`, `proResRAW`, `proResRAWHQ`.

`.../bundleresources/entitlements/com.apple.security.cs.disable-library-validation.json`, body text:

> This security-hardening feature prevents a program from loading frameworks, plug-ins, or
> libraries unless they're either signed by Apple or signed with the same Team ID as the main
> executable. ... Gatekeeper runs extra security checks on programs that have it disabled.

## E-05 Web pages (fetched 2026-11-05)

| Key | URL | Date on page | Returned excerpt used |
| --- | --- | --- | --- |
| ffmpeg-legal | https://ffmpeg.org/legal.html | none | Checklist items 1-3, 18: "Compile FFmpeg without "--enable-gpl" and without "--enable-nonfree"."; "Use dynamic linking"; "Make sure your program is not using any GPL libraries (notably libx264)."; patents: "We do not know, we are not lawyers" |
| lgpl21 | https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html | license text | §6(b) suitable shared library mechanism; §6 "permit modification of the work for the customer's own use and reverse engineering for debugging"; §11 refrain-from-distribution clause |
| gpl-faq | https://www.gnu.org/licenses/gpl-faq.html | none | "pipes, sockets and command-line arguments are communication mechanisms normally used between two separate programs"; "if the semantics of the communication are intimate enough, exchanging complex internal data structures" |
| via-avc | https://www.via-la.com/licensing-programs/avc-h-264/ | "Updated September 28, 2026" | 1-100,000 units $0.00; 100,001-5,000,000 $0.20; >5,000,000 $0.10; cap $9.75M/yr 2017 and after; "The actual License agreement provides the only definitive and reliable statement of license terms." |
| via-aac | https://www.via-la.com/licensing-programs/aac/ | "Copyright © 2025", patent list "26Q3" | 1-500,000 units $0.98, tiers down to $0.10; no free tier; PC software rates on a separate page, not read |
| aa-hevc | https://accessadvance.com/2025/07/21/access-advance-announces-hevc-advance-and-vvc-advance-pricing-through-2030/ and BusinessWire 2026-01-26 | 2025-07-21; 2026-01-26 | 25% rate increase for new licensees, deadline moved to 2026-06-30; exact software rates not obtained |
| openh264 | https://www.openh264.org/faq.html | none | "Cisco is only covering the licensing fees for its own binary module."; must download "at the time the product or project is installed"; "Two-Clause BSD license"; "The initial code has the baseline profile." |
| x264-vlc | https://www.videolan.org/developers/x264.html | none | "free to use under the GNU GPL"; "also available under a commercial license"; x264licensing@videolan.org |
| x264-org | https://x264.org/licensing/ | n/a | Unreachable: WebFetch HTTP 403; curl returned a Cloudflare block page. Terms below came from a search-engine snippet only. |
| mf-formats | https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation | updated 2025-04-15 | Video codecs: DV, H.264 (dec+enc), H.263, MJPEG, MPEG-4 Part 2, MPEG-4 v1-v3, WMV. Containers: 3GP, ASF, ADTS, AVI, MP3, MPEG-4 (.mov/.mp4 source+sink), SAMI, WAVE. No ProRes, DNxHD, HEVC, or MXF entry. |
| mf-h264enc | https://learn.microsoft.com/en-us/windows/win32/medfound/h-264-video-encoder | updated 2021-08-19 | Baseline, Main, High (Windows 8+); certified hardware encoder used when present |
| win-n | https://support.microsoft.com/en-us/windows/experience/platform-variants/media-feature-pack-for-windows-n | not captured | N editions exclude Media Foundation and the H.264/H.265 codecs until the Media Feature Pack; HEVC extension installable from the Store afterward |
| apple-pvf | https://support.apple.com/en-us/106396 | Pro Video Formats 3.2 | macOS 11.0.1; includes Avid DNxHD/DNxHR decoder, AVC-Intra, XAVC, XF-AVC, XF-HEVC, XDCAM |
| apple-prores-auth | https://support.apple.com/en-us/118584 | not captured | "Using any unauthorized implementation (like the FFmpeg and derivative implementations) may lead to decoding errors, performance degradation, incompatibility, and instability."; licensing via ProRes@apple.com |
| apple-prores-raw-win | https://support.apple.com/en-us/106401 | 1.3 | Windows 10 64-bit; compatible apps listed are Adobe applications only |
| reaper-tech | https://www.reaper.fm/technical.php | none | Decode: AVFoundation, "FFmpeg 1.2.x-4.0.x (minimal subset included)", VLC (not included), DirectShow, QuickTime, WMF. Encode: AVFoundation, FFmpeg, WMF. |
| reaper-blog | https://reaper.blog/2021/12/ffmpeg-for-reaper-643/ and https://reaper.blog/2026/03/766-update/ | 2021-12; 2026-03 | FFmpeg 5.0 did not work with REAPER 6.43-7.65; 7.66 adds support for more recent FFmpeg, installed via Winget or Homebrew |
| cubase15 | https://www.steinberg.help/r/cubase-pro/15.0/en/cubase_nuendo/topics/video/video_replacing_audio_in_video_t.html | Cubase Pro 15 | "Replace Audio in Video" embeds the mix "without re-rendering"; separate "Render New Video File" tab |
| steinberg-dnx | https://forums.steinberg.net/t/video-decoder-for-avid-dnxhd-and-nuendo-8-0-15-released/94320/40 | forum | Steinberg shipped an Avid-licensed DNxHD decoder; a user claims FFmpeg underneath (unconfirmed) |
| gyan | https://www.gyan.dev/ffmpeg/builds/ | none | "All builds are 64-bit, static and licensed as GPLv3."; libx264, libx265 in essentials; a release full shared build is also offered |
| electron-34236 | https://github.com/electron/electron/issues/34236 | 2022 | Maintainer and reporter on LGPL vs patent licensing of Electron's ffmpeg builds |
| chromium-h264 | https://groups.google.com/g/discuss-webrtc/c/-yOpc5bP42Y | not captured | Chrome encodes H.264 with OpenH264 or platform encoders; x264 excluded for GPL reasons (search summary only) |

## E-06 Failed or partial retrievals

- `https://x264.org/licensing/`: HTTP 403 by WebFetch; Cloudflare block page by curl.
- `https://helpcenter.steinberg.de/hc/en-us/articles/115000808250`: HTTP 403.
- `https://www.gnu.org/licenses/gpl-faq.html`: two HTTP 429 responses, then success on retry.
- Access Advance software and PC royalty rate card: not retrieved.
- Via LA AAC PC software rate page: not retrieved.
