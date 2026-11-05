---
type: research
id: RESEARCH-sourdaw-ffmpeg-video-posture
---

# Which FFmpeg posture lets Sourdaw decode and encode video for film scoring?

## Question and scope

Decision: Sourdaw needs to decode and encode video for film scoring. It is a closed-source,
commercial Electron DAW shipped on macOS and Windows. Which codec posture should it use?

- (a) An LGPL-only FFmpeg build, dynamically linked.
- (b) A GPL FFmpeg build with x264.
- (c) Rely on an FFmpeg the user installed on their own system.
- (d) Use platform codecs (AVFoundation and VideoToolbox on macOS, Media Foundation on Windows)
  instead of FFmpeg.

In scope: copyright licensing (LGPL and GPL), patent-pool exposure (AVC/H.264, HEVC), Apple ProRes
authorization, platform codec coverage, and DAW precedent. Out of scope: Sourdaw's code and issues
(trial rule), audio-only codec pools, and legal advice. Every legal reading below comes from primary
license text or a licensor's own page. None of it is counsel's opinion.

Horizon: the current releases of FFmpeg, Electron, macOS 27, and Windows 10/11, plus the patent
pool terms published in 2026.

Any of these would reverse the recommendation:

- Counsel finds that calling an OS codec still makes Sourdaw a pool licensee.
- Apple will not authorize ProRes decoding on Windows, and Windows ProRes demand is high.
- Sourdaw must ship a software codec that only FFmpeg provides, on both platforms.

Scope questions for the owner, with no human available. Each is recorded with its recommended
answer, and the work continued on that answer:

- Q1. Which video formats must score-to-picture support? Recommended answer: ProRes (Proxy, LT,
  422), H.264, and DNxHD/DNxHR for import; H.264 or ProRes for export, plus a remux of the original
  picture with a new audio track. The format list is DAW convention, not measured prevalence (see
  R-016).
- Q2. Is Sourdaw expected to pass 100,000 distributed copies a year in the horizon? Recommended
  answer: assume no for now, and plan for yes (see R-008).

## Method and coverage

- Primary license texts were fetched and hashed: FFmpeg legal page, FFmpeg `configure`, LGPL 2.1,
  GPL 2, and the GPL FAQ. Receipts are in
  [the evidence sidecar](RESEARCH-sourdaw-ffmpeg-video-posture.receipts.md), sections E-1 and E-2.
- Electron and Chromium FFmpeg build configuration was read from source (E-3).
- AVFoundation encode and decode were exercised on macOS 27.2 for ProRes 422 Proxy, ProRes 422,
  H.264, and HEVC (E-4). The probe source is
  [RESEARCH-sourdaw-ffmpeg-video-posture.avfoundation-probe.swift](RESEARCH-sourdaw-ffmpeg-video-posture.avfoundation-probe.swift).
- Licensor pages were read: Via LA's AVC and HEVC/VVC programs, the Access Advance rate page, the
  2016 HEVC Advance press release, Apple's ProRes authorized-products page, the x264 page, and
  Cisco's OpenH264 binary license.
- Platform documentation was read: Microsoft Learn for Media Foundation, the Apple macOS SDK 27.2
  headers, and the Apple Hardened Runtime entitlement documentation.
- DAW precedent: the REAPER Blog, and Steinberg forum reports (weak evidence; the Steinberg help
  page returned HTTP 403).

Not covered:

- No Windows machine was available, so Media Foundation behavior is documented, not exercised.
- No Via LA or Access Advance license agreement was read. Only the program summaries were.
- No source covered who holds the patent licenses for the decoders that Electron bundles.

## Findings

### Licensing

**R-001. An LGPL-only FFmpeg build can ship inside closed-source software, under conditions.**
Evidence: FFmpeg legal page (E-1). Its compliance checklist says to compile without both
"--enable-gpl" and "--enable-nonfree", and to "Use dynamic linking". Independent source: LGPL 2.1
§6 (FSF) allows linking a work and distributing it "under terms of your choice". The required
mechanism is §6(b) "a suitable shared library mechanism". Outcome: **Verified**. Weakens it: the
FFmpeg page calls itself "not legal advice". Relevance: options (a) and (c) both depend on this
being possible.

**R-002. LGPL compliance changes Sourdaw's EULA and its release process.** Evidence: LGPL 2.1 §6
requires terms permitting "reverse engineering for debugging such modifications". The FFmpeg
checklist says "Remove any prohibition of reverse engineering from your EULA". It also requires:
shipping the matching FFmpeg source, writing down the configure line, an about-box notice, and no
obfuscated DLL names. Outcome: **Verified** (FSF license text plus FFmpeg project). Relevance: this
is a fixed cost of (a). It is also a cost Sourdaw already carries (R-004).

**R-003. A GPL build with x264 makes the whole linked work GPL, which a closed-source product
cannot accept.** Evidence: FFmpeg `configure` lists `libx264` in `EXTERNAL_LIBRARY_GPL_LIST` (E-2).
The legal page says that if the GPL parts are used, "the GPL applies to all of FFmpeg". It lists
"Make sure your program is not using any GPL libraries (notably libx264)". Independent source: GPL 2
§2(b) (FSF) requires the derived work "to be licensed as a whole". Outcome: **Verified**. Relevance:
this rules out (b) as stated.

**R-004. Every Electron app already ships an LGPL FFmpeg with an H.264 and AAC decoder, and with
no encoders.** Observation: Electron `release.gn` says it builds FFmpeg as a shared library because
of the "LGPL requirement to ship ffmpeg as a dynamically linked library". `all.gn` sets
`proprietary_codecs = true`. The Chromium FFmpeg Chrome-branded mac config sets
`FFMPEG_LICENSE "LGPL version 2.1 or later"`, `CONFIG_H264_DECODER 1`, and
`CONFIG_PRORES_DECODER 0`, and enables zero encoders (E-3). Outcome: **Verified** (two
publishers: Electron and Chromium). Weakens it: this is the mac arm64 config only; the Windows
config was not read. Relevance:

- Sourdaw's LGPL compliance duty already exists, so the extra licensing cost of (a) is small
  (inference).
- Sourdaw already distributes an AVC decoder (inference, see R-009).
- The bundled library is no answer to the scoring need: it cannot encode and cannot read ProRes.

**R-005. An LGPL FFmpeg build can still encode H.264, HEVC, and ProRes by calling the OS
encoders.** Evidence: `configure` declares `h264_videotoolbox`, `hevc_videotoolbox`,
`prores_videotoolbox`, `h264_mf`, and `hevc_mf` encoders. Their dependencies are only `pthreads` or
`mediafoundation`, never `gpl` or `nonfree` (E-2). Outcome: **Verified** for build configuration,
from a single source (FFmpeg's own build script, the competent source for its own flags). Not
exercised: no LGPL build was compiled. Relevance: (a) does not need x264 to encode H.264, which
weakens the main reason for (b).

**R-006. A commercial x264 license exists. It is not shown to make an FFmpeg-plus-x264 build
non-GPL.** Evidence: VideoLAN says x264 is "also available under a commercial license". The FFmpeg
wrapper `libavcodec/libx264.c` itself carries an LGPL notice. FFmpeg says it is "not available under
any other licensing terms". `configure` still forces `--enable-gpl` to enable `libx264`, and that
flag also turns on 33 GPL-only libavfilter filters (E-2). Outcome: **Unverified**. The check that
would settle it: written terms from x264licensing@videolan.org on use through FFmpeg, plus a build
proving that no GPL filter is compiled. Relevance: this is the only path that could rescue (b),
and it costs money. It is not needed if R-005 holds.

**R-007. Running a user-installed FFmpeg as a separate program normally keeps it a separate work.
Loading its libraries into Sourdaw's own process probably does not.** Evidence: the GPL FAQ says
"pipes, sockets and command-line arguments" are "normally used between two separate programs". It
also says modules in "a shared address space" mean "almost surely" one program. GPL 2 §0 says
activities other than copying, distribution, and modification are "not covered". Typical installs
are GPL: Homebrew `ffmpeg` 9.0.2 is `GPL-3.0-or-later` with `--enable-libx264`, and gyan.dev
Windows builds are "licensed as GPLv3" (E-6). Outcome: **Verified** for what the FSF says and what
the builds are. **Unverified** for whether dynamically loading user-installed GPL libraries without
distributing them creates a GPL obligation; no court or counsel source was reached. Settling check:
counsel opinion. Relevance: (c) is safe for licensing only if it drives the FFmpeg command-line
program, never if it loads the user's libav* libraries in-process.

### Patent exposure

**R-008. Via LA's AVC/H.264 terms charge per unit for encoders and decoders sold to end users.
The first 100,000 units a year are royalty-free.** Evidence: the Via LA AVC program page (updated
2026-09-28) covers products sold to end users "except for products that are part of a personal
computer's operating system". It charges $0.00 for units 1 to 100,000, then $0.20 each up to
5,000,000, then $0.10, with a $9.75M enterprise cap since 2017. A "unit" is a decoder, an encoder,
or one of each. Outcome: **Verified**. Weakens it: the only independent source (Ozer, 2017
presentation) reproduces the same terms from MPEG LA's own document, so it shares the underlying
data. Via LA says only the actual agreement is definitive. Relevance: shipping FFmpeg's own H.264
decoder or encoder in (a) or (b) makes Sourdaw a candidate licensee. The fee is zero below 100k
units a year, but signing and reporting are still owed. Under Q2's recommended answer this is a
compliance cost, not a royalty.

**R-009. Licensing for the H.264 decoder Electron bundles is not established.** Inference from
R-004 and R-008: Electron's `libffmpeg` contains an AVC decoder, and Sourdaw distributes it with
every copy. Outcome: **Unverified**. Settling check: counsel review, or a statement from Electron or
OpenJS about any pool license. Relevance: this exposure exists under every option. FFmpeg's own
H.264 decoder would add little new decoder exposure, but an encoder would add some (inference).

**R-010. HEVC is covered by two pools. The software exemption is dated and narrow.** Evidence:

- The Via LA HEVC/VVC page says the pool is now administered by a subsidiary of Access Advance. It
  charges $0.00 for units 1 to 100,000, then $0.30 (Region 1) or $0.20 (Region 2), with a $30M cap.
- HEVC Advance's 22 Nov 2016 press release waived royalties for "application layer software"
  installed on PCs after sale, where decoding runs "fully executed in software on a general
  purpose CPU".
- The current Access Advance rate page (as of 1 July 2026) does not mention that waiver.

Outcome: **Verified** for the Via LA HEVC/VVC terms. **Unverified** for whether the 2016 waiver
still applies; it also excludes hardware-accelerated decoding. Settling check: written
confirmation from Access Advance. Relevance: shipping FFmpeg's HEVC decoder creates exposure to
two pools. OS HEVC codecs avoid it (inference, R-012).

**R-011. Apple treats FFmpeg's ProRes as unauthorized. It authorizes named third-party products,
Pro Tools and DaVinci Resolve among them.** Evidence: Apple's "ProRes and ProRes RAW Authorized
Products" page (published 2026-08-09) names "the FFmpeg and derivative implementations" as
unauthorized. It warns of decoding errors and instability, and sends licensing questions to
ProRes@apple.com. Outcome: **Verified** for Apple's stated position (first-party record of the
licensor's stance). **Unverified** for any patent claim: the page asserts no patents and gives no
fee terms. Relevance: ProRes through FFmpeg on Windows carries reputational and compatibility risk,
and possibly legal risk. On macOS, ProRes is available from the OS (R-013).

**R-012. Pool terms treat a codec built into the OS as the OS vendor's product.** Evidence: Via LA
AVC lists a separate tier for products "incorporated into a personal computer's operating system at
the time of sale". Its end-product tier explicitly excludes OS components. Outcome: **Verified**
for the terms. Inference, **Unverified**: an application that only calls the OS codec does not
itself distribute an AVC unit. Settling check: counsel reading of the Via LA agreement. Relevance:
this is the patent advantage of (d), and of an (a) build limited to OS encoders.

**R-013. Cisco's OpenH264 binary is royalty-covered only when downloaded separately and controlled
by the user.** Evidence: Cisco's binary license grants coverage "at no cost to you" only if the
binary is "separately downloaded" and "not integrated into or combined with third party
software". The user must be able to enable and disable it. Outcome: **Verified** (single
first-party source, the competent source for its own grant). Relevance: this is a software H.264
encoder fallback for (a) when no OS encoder exists. It adds a download step.

### Platform coverage

**R-014. macOS AVFoundation encodes and decodes ProRes 422 Proxy, ProRes 422, H.264, and HEVC.**
Observation: the exercise on macOS 27.2 wrote 24 frames for each codec. All four writers completed,
and all 24 frames decoded back each time, with fourccs `apco`, `apcn`, `avc1`, and `hvc1` (E-4).
Independent source: the SDK 27.2 header `AVVideoSettings.h` declares `AVVideoCodecTypeH264` and
`AVVideoCodecTypeHEVC` from macOS 10.13, `AVVideoCodecTypeAppleProRes422` from 10.13, and
`AVVideoCodecTypeAppleProRes422Proxy` from 10.15. Outcome: **Verified**. Weakens it: one machine,
synthetic frames, and DNxHD not tested. Relevance: on macOS, (d) covers the core scoring formats
with no FFmpeg at all.

**R-015. Windows Media Foundation natively covers H.264 decode and encode, and MPEG-4/MOV
containers. It does not natively cover ProRes or DNxHD.** Evidence: Microsoft Learn's "Supported
Media Formats in Media Foundation" (updated 2025-04-15) lists an H.264 decoder and encoder from
Windows 7, and an MPEG-4 file source and sink for `.mov` and `.mp4`. ProRes and DNxHD do not appear.
It says third parties add formats "by writing custom plug-ins". The HEVC decoder page requires
Windows 10 and names `hevcdecoder_store.dll`. Outcome: **Verified** for what the documents list.
Not exercised. **Unverified**: whether HEVC needs the paid Store extension on a clean install.
Relevance: on Windows, (d) alone cannot import ProRes or DNxHD, which leaves the main gap in
film-scoring coverage.

**R-016. DAW precedent runs platform codecs first, with FFmpeg as an optional extension.**
Evidence:

- The REAPER Blog (community-run, not Cockos) says Media Foundation support "allows for H.264
  rendering", so users "may not need to install FFMPEG anymore".
- REAPER 7.66 (19 March 2026) shows users installing FFmpeg via Winget or Homebrew. REAPER versions
  6.43 to 7.65 accepted only FFmpeg 4.4: "5.0 will not work".
- Apple lists Avid Pro Tools among authorized ProRes products (R-011).
- Steinberg forum users report that Steinberg's own engine needs a paid Avid DNxHD decoder license.

Outcome: **Unverified** as a load-bearing claim. The REAPER design rests on one community blog;
the Cockos forum threads appeared only as search snippets and were not read. Settling check:
REAPER's official changelog. Also **Unverified** for
Steinberg (forum only; the official help page returned 403) and for which formats composers
actually receive. Relevance:

- The REAPER design is option (c) as an add-on to (d), not a replacement for it.
- In-process loading of user FFmpeg breaks across major versions.
- DNxHD carries its own licensing cost.

**R-017. Code signing on macOS can fight LGPL user replacement of FFmpeg libraries.** Evidence:
Apple's Hardened Runtime documentation says library validation blocks libraries unless "signed by
Apple or signed with the same Team ID". LGPL 2.1 §6(b) requires that the work "will operate
properly with a modified version of the library". Outcome: **Verified** for both texts.
**Unverified** for whether a re-sign step or the `disable-library-validation` entitlement satisfies
§6(b). Settling check: counsel or an FSF compliance opinion. Relevance: this is not unique to (a),
since Electron's own `libffmpeg` has the same tension (R-004).

## Options

| Option | Licensing | Patent exposure | Scoring coverage | Verdict |
| --- | --- | --- | --- | --- |
| (a) LGPL FFmpeg, dynamic | Compatible with closed source under the §6 duties (R-001, R-002). Sourdaw already carries these duties for Electron (R-004). | FFmpeg's own H.264/HEVC codecs make Sourdaw a candidate pool licensee (R-008, R-010). Using only the OS encoders shifts that to the OS (R-005, R-012). ProRes is "unauthorized" (R-011). | Full: ProRes, DNx, H.264, HEVC, MXF, and remuxing on both platforms. | Viable, narrowed |
| (b) GPL with x264 | Incompatible with closed source (R-003). The commercial x264 route is unproven (R-006). | Same as (a), plus an x264 encoder unit (R-008). | Full | Reject |
| (c) User-installed FFmpeg | Safe only through the command-line program. In-process loading of a GPL build is likely one combined program (R-007). | Sourdaw ships no codec (inference). The user's FFmpeg is unlicensed. | Variable. Breaks across versions (R-016). Absent by default (E-5, one machine). | Optional add-on only |
| (d) Platform codecs | No copyleft duties added. | The OS vendor is the pool licensee (R-012, inference). | macOS: ProRes, H.264, HEVC exercised (R-014). Windows: H.264 only natively; no ProRes or DNx (R-015). | Baseline, with a Windows gap |

## Open questions

- O-1, Windows ProRes. Spend or legal exposure, so the owner decides. Options:
  - License ProRes from Apple (ProRes@apple.com).
  - Ship FFmpeg's ProRes decoder on Windows and accept Apple's "unauthorized" warning.
  - Do not support ProRes import on Windows.

  Recommended answer: email Apple first. Until Apple replies, treat Windows ProRes as
  unsupported, or as available only through the optional user FFmpeg command-line path.
- O-2, Via LA AVC registration. Shipping any FFmpeg H.264 software codec makes Sourdaw a candidate
  pool licensee, at zero royalty below 100k units. Recommended answer: avoid it by keeping H.264 and
  HEVC on OS codecs. Have counsel settle R-009 for the decoder Electron already bundles.
- O-3, DNxHD. Settling check: test AVFoundation and Media Foundation decode of a DNxHD MOV, and ask
  Avid about decoder licensing. FFmpeg's native `dnxhd` codec is LGPL, but its patent and licensing
  status was not researched.
- O-4, WebCodecs. Electron's Chromium may already expose OS H.264 and HEVC encode and decode
  through WebCodecs, with no native addon. Not researched. Settling check: an
  `VideoEncoder.isConfigSupported` probe in Sourdaw's Electron version on both platforms.
- O-5, codesign and LGPL §6(b) (R-017). Counsel question.
- O-6, H.264 patent expiry. One unofficial source claims the last major US AVC patent expires in
  late 2027. Unverified. Settling check: Via LA's published patent list. If confirmed, it
  shrinks R-008 and R-009 within the horizon.

## Recommendation

The evidence supports a hybrid of (d) and a narrow (a). It rules out (b), and allows (c) only as
an add-on.

1. **Make (d) the baseline.** Use AVFoundation and VideoToolbox on macOS (R-014) and Media
   Foundation on Windows (R-015) for H.264 and HEVC decode and encode. This keeps patent-pool units
   with the OS vendor (R-012) and adds no copyleft.
2. **Add a narrow LGPL FFmpeg build, per (a), for what the platforms lack.**
   - Use it for container demuxing and remuxing (picture plus a new audio track, with no video
     re-encode) and for DNx decode.
   - Build it without `--enable-gpl` or `--enable-nonfree`, link it dynamically, and enable only
     the OS-backed `*_videotoolbox` and `*_mf` encoders (R-001, R-005).
   - Fold its compliance into the LGPL duties Sourdaw already has for Electron's `libffmpeg`
     (R-002, R-004).
   - Exclude the software H.264 and HEVC codecs unless O-2 is settled.
   - Exclude FFmpeg ProRes on Windows until O-1 is settled (R-011).
3. **Reject (b).** GPL §2(b) would cover all of Sourdaw (R-003), and R-005 removes the need for
   x264.
4. **Allow (c) only as an opt-in power-user path.** Run the user's `ffmpeg` command-line program
   as a separate process. Never load its libraries in-process (R-007), and never make it the
   baseline (R-016).

What would decide the remaining uncertainty:

- Apple's ProRes answer (O-1).
- Counsel on R-009, R-012, and R-017.
- A Windows run of Media Foundation and WebCodecs against ProRes, DNxHD, H.264, and HEVC sample
  files (R-015, O-4).

The decision stays with the owner.
