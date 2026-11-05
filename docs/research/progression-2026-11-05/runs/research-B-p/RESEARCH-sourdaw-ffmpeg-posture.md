---
type: research
id: RESEARCH-sourdaw-ffmpeg-posture
---

# FFmpeg posture for video decode and encode in Sourdaw

Evidence receipts: [RESEARCH-sourdaw-ffmpeg-posture.receipts.md](RESEARCH-sourdaw-ffmpeg-posture.receipts.md).
Nothing here is legal advice. Every licensing and patent conclusion below is an engineering
reading of primary texts. It needs counsel before release (see Q-1).

## Question and scope

- **Decision.** Which FFmpeg posture lets Sourdaw decode and encode video for film scoring?
  The candidates are (a) an LGPL-only FFmpeg build, dynamically linked; (b) a GPL build with
  x264; (c) a user-installed system FFmpeg; (d) platform codecs (AVFoundation, Media
  Foundation) instead of FFmpeg. Licensing and patent exposure are in scope.
- **Segment.** Sourdaw is a closed-source, commercial Electron DAW, distributed directly on
  macOS and Windows. The users are composers scoring to picture.
- **Workload assumed.** Import picture in the formats that editors and studios hand composers:
  ProRes, DNxHD/DNxHR in MOV or MXF, and H.264/HEVC reference files. Play it frame-accurately
  against the timeline. Export the mix with the picture. Exporting means either replacing the
  audio track without re-encoding the video, or rendering a new H.264 reference file. The
  formats are a DAW convention, backed by R-021. The precise format list is an assumption,
  recorded as Q-3.
- **Horizon.** The current releases as of 2026-11-05: Electron v45.2.3, FFmpeg master and 9.0.2,
  Via LA AVC terms updated 2026-09-28.
- **Out of scope.** Linux, the Mac App Store, hardware video output (SDI) beyond one note in
  R-019, and DRM content.
- **What would reverse the answer.**
  - Counsel advises that shipping any H.264 or AAC decoder in Sourdaw's own binaries needs a pool
    license whose cost or terms are unacceptable. That shifts weight toward (d) for H.264 and AAC.
  - Sourdaw is willing to open its source under the GPL. That makes (b) viable.
  - Windows users can be required to transcode ProRes and DNx before import. That makes pure (d)
    viable.

## Method and coverage

The primary sources read were:

- the FFmpeg legal page, plus FFmpeg's `configure` and `allcodecs.c` at master;
- the LGPL 2.1 text and the GPL FAQ;
- Electron's build arguments and release assets;
- the Homebrew FFmpeg formula;
- Via LA's AVC and AAC program pages, the Access Advance HEVC pricing announcements, and Cisco's
  OpenH264 FAQ;
- Microsoft's Media Foundation format and encoder documentation, and its Windows N
  documentation;
- Apple's AVFoundation codec constants, its hardened runtime entitlement, Pro Video Formats, and
  its ProRes authorization pages;
- the technical pages of REAPER and Cubase as competitor precedent.

The receipts sidecar holds commands, URLs, dates, and untouched excerpts.

Coverage gaps:

- x264.org was unreachable: it returned HTTP 403 and a Cloudflare block. x264 commercial terms
  come from a search snippet and the VideoLAN page.
- The rate cards for Access Advance HEVC software and for Via LA AAC PC software were not
  retrieved.
- No product behavior was exercised. No FFmpeg build, no AVFoundation or Media Foundation probe,
  and no Electron codec probe was run.
- No pool license agreement was read. Pool program pages state that the agreement is
  definitive.

## Findings

Each finding is marked **Observation** (what the source itself shows), **Source claim** (what a
source asserts), or **Inference** (my reading). Confidence is High, Moderate, Low, or Very low.

### Licensing

**R-001. FFmpeg's LGPL route allows closed-source use under specific conditions.**
- **Observation.** FFmpeg's legal page sets the conditions:
  - compile "without "--enable-gpl" and without "--enable-nonfree"";
  - use dynamic linking (DLLs on Windows);
  - ship the exact corresponding source, the diff, and the configure line;
  - credit FFmpeg in the about box and the EULA;
  - remove any EULA ban on reverse engineering;
  - do not obfuscate DLL names;
  - "Make sure your program is not using any GPL libraries (notably libx264)."

  The page also says FFmpeg is not available under proprietary terms at any price.
- **Confidence.** High for what the copyright holders require. It is a primary document from the
  licensor, though it is not a court reading.
- **Relevance.** This is the copyright compliance checklist for (a), and for any hybrid that
  bundles FFmpeg.

**R-002. LGPL 2.1 itself sets two obligations and a patent-conflict clause.**
- **Observation.** The license text says:
  - §6(b) requires "a suitable shared library mechanism": one that works with a modified,
    interface-compatible library the user installs;
  - §6 requires terms that "permit modification of the work for the customer's own use and
    reverse engineering for debugging";
  - §11 says that if a patent license would not let all recipients redistribute the Library
    royalty-free, the only way to satisfy both is to refrain from distributing it.
- **Inference.** §11 sits in tension with royalty-bearing pools such as AVC (R-009). Many
  commercial products ship LGPL FFmpeg decoders anyway, and Electron is one of them (R-008). How
  §11 applies to Sourdaw is a question for counsel, not an engineering one.
- **Confidence.** High for the text. Low for how §11 applies in practice: no case law or counsel
  opinion was read.
- **Relevance.** This is a residual legal risk shared by (a), the hybrid, and today's Electron
  build.

**R-003. Enabling x264 or x265 puts all of FFmpeg under the GPL.**
- **Observation.** In FFmpeg's `configure`, `libx264` and `libx265` sit in
  `EXTERNAL_LIBRARY_GPL_LIST`. The legal page says that if the GPL parts are used, "the GPL
  applies to all of FFmpeg".
- **Inference.** A closed-source app linking a GPL FFmpeg must either be released under the GPL
  or hold a separate license for every GPL component. FFmpeg offers no such license (R-001).
- **Confidence.** High.
- **Relevance.** This disqualifies (b) for linking.

**R-004. x264 is dual-licensed, but its commercial terms are not public.**
- **Observation.** VideoLAN says x264 is "free to use under the GNU GPL" and "also available
  under a commercial license", with x264licensing@videolan.org as the contact.
- **Source claim.** A search snippet of x264.org reports:
  - x264, LLC does not disclose its commercial terms;
  - it "does not typically" license SDKs;
  - the H.264 patent fee is separate from the x264 fee. That last point rests on a 2011 mailing
    list thread.
- **Confidence.** Moderate. Downgraded because x264.org was unreachable, so its wording is
  `[unconfirmed]`, and because the patent-fee source is stale.
- **Relevance.** A commercial x264 license would solve the x264 part of (b). It would not
  relicense the rest of a GPL-configured FFmpeg (R-001, R-003). So (b) needs an LGPL FFmpeg
  linked to a commercially licensed libx264, which is no longer "a GPL build". Cost is unknown.

**R-005. The FSF treats arm's-length process communication as separate programs, with a limit.**
- **Observation.** The GPL FAQ says "pipes, sockets and command-line arguments are
  communication mechanisms normally used between two separate programs". It also warns that
  communication can be "intimate enough, exchanging complex internal data structures" to make
  the parts one program.
- **Confidence.** High for the FSF position. Moderate for its legal effect: it is the licensor's
  view, not case law.
- **Relevance.** A GPL FFmpeg could be driven as a separate `ffmpeg` executable through its CLI,
  but distributing that executable still carries the GPL source obligations. This matters for
  (b)-as-subprocess and for (c).

**R-006. The common user-installable FFmpeg builds are GPL and include x264 and x265.**
- **Observation.**
  - The Homebrew formula: FFmpeg 9.0.2, `license "GPL-3.0-or-later"`, configured with
    `--enable-gpl --enable-version3 --enable-libx264 --enable-libx265`.
  - gyan.dev's Windows builds: "All builds are 64-bit, static and licensed as GPLv3", with libx264
    and libx265 included. A release "full shared" build is also offered. The page contradicts
    itself on static versus shared, so this is reported as found.
- **Inference.** On the FSF reading (R-005), Sourdaw loading the libraries of a typical system
  FFmpeg into its own process forms a combined work with GPL code. Calling the `ffmpeg` CLI keeps
  the arm's-length argument.
- **Confidence.** High for the builds. Moderate for the inference.
- **Relevance.** Under (c), the app does not choose the license: the user's build does, and it
  is GPL by default.

**R-007. A system FFmpeg is a moving ABI target.**
- **Source claim.** reaper.blog says FFmpeg 5.0 did not work with REAPER 6.43 to 7.65. REAPER 7.66
  (March 2026) added support for newer FFmpeg versions, installed through Winget or Homebrew.
- **Observation.** Homebrew currently ships 9.0.2.
- **Confidence.** Moderate. Downgraded because reaper.blog is a community blog, not Cockos.
- **Relevance.** (c) carries a recurring compatibility cost and a support burden. Each FFmpeg
  major version can break the integration.

### What Sourdaw already ships

**R-008. Stock Electron already ships an LGPL FFmpeg with the H.264 and AAC decoders.**
- **Observation.**
  - Electron's `build/args/all.gn` sets `ffmpeg_branding = "Chrome"` and
    `proprietary_codecs = true`.
  - `release.gn` builds FFmpeg as a shared library (`is_component_ffmpeg = true`) for users "who
    don't want to ship proprietary codecs in ffmpeg, or who have an LGPL requirement".
  - `ffmpeg.gn` builds a drop-in library with `proprietary_codecs = false`.
  - Release v45.2.3 publishes those drop-in libraries as `ffmpeg-v45.2.3-<platform>.zip`.
- **Inference.**
  - Sourdaw's H.264 and AAC decoder patent exposure exists today, whatever this decision says,
    unless it swaps in the non-proprietary library.
  - Sourdaw also already carries the LGPL relinking question on macOS (R-020).
- **Confidence.** High. Read from source.
- **Relevance.** The patent question is not new to (a). Adding a second FFmpeg changes the count
  of decoders shipped, not the category of exposure.

### Patents

**R-009. Via LA's AVC/H.264 royalties for PC end products have a free tier and a cap.**
- **Observation.** For products sold to end users or OEMs for PCs, excluding the PC operating
  system, the rates are:

  | Units per year | Royalty per unit |
  | --- | --- |
  | 1 to 100,000 | $0.00, one legal entity per affiliated group |
  | 100,001 to 5,000,000 | $0.20 |
  | Above 5,000,000 | $0.10 |

  The enterprise cap is $9.75M per year from 2017. One unit is a decoder, an encoder, or one of
  each. Operating system products are licensed so that end users may use them "for personal and
  consumer purposes (including internal business) without remuneration". The page is "Updated
  September 28, 2026" and says the agreement is definitive.
- **Inference.** Below 100,000 units a year, a licensed AVC codec in Sourdaw costs $0 in
  royalties, but it still needs a signed license and reporting. Whether a composer's paid
  delivery of H.264 reference files is covered by the OS vendor's end-user grant is unclear from
  the summary page.
- **Confidence.** High for the rates. Low for the coverage inference.
- **Relevance.** This sizes the H.264 exposure for (a), (b), and the hybrid. It also sets the
  boundary of what (d) shifts to the OS vendor.

**R-010. Via LA's AAC royalties have no free tier.**
- **Observation.** End-product units are tiered from $0.98 each (first 500,000 units) down to
  $0.10. No free tier is listed. PC software rates sit on a separate page, which was not read. The
  patent list is labelled 26Q3.
- **Confidence.** Moderate. Downgraded because the PC software rate page was not read.
- **Relevance.** Bundling FFmpeg's native AAC encoder is a second royalty line. Platform AAC
  encoders avoid it: Media Foundation's `aac_mf` and AudioToolbox's `aac_at`, both reachable
  from an LGPL FFmpeg (R-018). Exporting PCM in MOV avoids it too.

**R-011. HEVC licensing is fragmented and its prices are rising.**
- **Observation.**
  - Access Advance applied a 25% rate increase for new licensees. The deadline to lock the old
    rates moved to 2026-06-30, which has passed.
  - Access Advance absorbed Via LA's HEVC/VVC program.
  - The exact software rates were not retrieved.
- **Confidence.** Low. Downgraded for indirectness and missing rate cards.
- **Relevance.** This argues against shipping Sourdaw's own HEVC decoder or encoder. Decode and
  encode HEVC through the OS (R-016, R-013, R-014).

**R-012. Cisco's OpenH264 is a patent-covered H.264 encoder only under narrow conditions.**
- **Observation.**
  - The source is BSD-2-Clause.
  - "Cisco is only covering the licensing fees for its own binary module".
  - The product must download that module "at the time the product or project is installed".
  - FFmpeg's `libopenh264` is outside its GPL and nonfree lists.
  - The FAQ states "The initial code has the baseline profile."
- **Confidence.** Moderate. The FAQ is undated and may be stale on profiles.
- **Relevance.** This is a fallback H.264 encoder for the LGPL route. It adds an install-time
  network download and is limited to baseline quality.

### Platform codecs

**R-013. Media Foundation natively lacks every professional film-scoring codec.**
- **Observation.**
  - Video codecs listed: DV, H.264 (decode and encode), H.263, MJPEG, MPEG-4 Part 2, MPEG-4
    v1-v3, and WMV.
  - Containers listed include MPEG-4, which covers .mov and .mp4, as both source and sink.
  - ProRes, DNxHD, HEVC, and MXF are not listed.
  - The H.264 encoder supports Baseline, Main, and High profiles, and uses a certified hardware
    encoder when one is present.
- **Confidence.** High. The page is primary and was updated 2025-04-15.
- **Relevance.** Pure (d) on Windows cannot open ProRes or DNx picture.

**R-014. Windows N editions ship without Media Foundation.**
- **Observation.** N editions exclude Media Foundation and the H.264/H.265 codecs until the user
  installs the Media Feature Pack. HEVC is a separate Store extension. A Microsoft Q&A user
  reports DaVinci Resolve failing to start without `MFPlat.dll`.
- **Confidence.** Moderate to High. The pages are primary support pages; the Resolve report is
  an anecdote.
- **Relevance.** Under (d), Sourdaw must detect N editions and missing extensions and guide the
  user to install them.

**R-015. Apple offers no third-party ProRes 422/4444 decoder for Windows.**
- **Observation.** Apple ProRes RAW for Windows 1.3 targets Windows 10 64-bit, and the only
  compatible apps it lists are Adobe's.
- **Source claim.** No result showed an Apple Media Foundation decoder for ProRes 422/4444.
- **Confidence.** Moderate. Downgraded because this is an absence finding from searches; its
  completeness is `[unconfirmed]`.
- **Relevance.** On Windows, ProRes decode means either FFmpeg's decoder or a licensed SDK, such
  as MainConcept, which Apple lists as authorized (R-017).

**R-016. macOS covers the film-scoring codecs natively.**
- **Observation.**
  - AVFoundation's `AVVideoCodecType` includes `h264`, `hevc`, `hevcWithAlpha`, the `proRes422`
    and `proRes4444` families, `proResRAW`, and `proResRAWHQ`.
  - Apple's Pro Video Formats 3.2 (macOS 11.0.1 or later) adds an Avid DNxHD/DNxHR decoder,
    AVC-Intra, XAVC, XF-AVC, XF-HEVC, and XDCAM. It is a separate download.
- **Confidence.** High.
- **Relevance.** On macOS, (d) is nearly complete, and the codecs are Apple's own. MXF container
  support through AVFoundation was not confirmed (`[unconfirmed]`).

**R-017. Apple names FFmpeg's ProRes as unauthorized, but warns only of technical risk.**
- **Source claim.** Apple says "Using any unauthorized implementation (like the FFmpeg and
  derivative implementations) may lead to decoding errors, performance degradation,
  incompatibility, and instability". Licensing and certification go through ProRes@apple.com, and
  authorized products include the MainConcept ProRes Decoder SDK.
- **Inference.** Apple frames the warning as technical risk; it asserts no infringement claim on
  the page. Whether FFmpeg's ProRes raises patent or trademark exposure is not established by any
  source read.
- **Confidence.** High for Apple's statement. Very low for any legal inference.
- **Relevance.**
  - Use AVFoundation for ProRes on macOS.
  - On Windows, FFmpeg's ProRes decoder is the practical route.
  - Avoid claiming "ProRes support" in marketing without Apple authorization (Q-2).

### FFmpeg capabilities and the hardened runtime

**R-018. An LGPL FFmpeg covers the professional codecs and can delegate encoding to the OS.**
- **Observation.** FFmpeg master registers:
  - native `prores` and `dnxhd` decoders and encoders, plus `prores_ks`;
  - `h264` and `hevc` decoders;
  - the platform encoder wrappers `h264_videotoolbox`, `hevc_videotoolbox`,
    `prores_videotoolbox`, `h264_mf`, `hevc_mf`, `aac_mf`, and `aac_at`;
  - `libopenh264`.

  None of these is in the GPL or nonfree lists.
- **Inference.** An LGPL-only build can demux and mux MOV, MP4, and MXF, and software-decode
  ProRes and DNx on Windows. It can hand H.264, HEVC, AAC, and ProRes (on Apple platforms)
  encoding to OS encoders, which are licensed by the OS vendor. Build flags can also disable
  FFmpeg's own H.264, HEVC, and AAC codecs.
- **Confidence.** High for the registry. Moderate for the inference: no build was run.
- **Relevance.** This makes a hybrid of (a) and (d) feasible.

**R-019. FFmpeg's DeckLink support is nonfree.**
- **Observation.** `decklink` sits in FFmpeg's `EXTERNAL_LIBRARY_NONFREE_LIST`.
- **Inference.** Video output to Blackmagic hardware must use the DeckLink SDK directly, never
  through FFmpeg. A nonfree build is unredistributable.
- **Confidence.** High.
- **Relevance.** This is a guardrail for any future work on video output to a second screen.

**R-020. macOS library validation blocks user-swapped libraries by default.**
- **Observation.** The hardened runtime's library validation blocks libraries not signed by
  Apple or by the same Team ID. The `com.apple.security.cs.disable-library-validation`
  entitlement lifts this, and Gatekeeper then runs extra checks.
- **Inference.** Under LGPL §6(b) (R-002), a user's modified FFmpeg `.dylib` will not load into a
  notarized Sourdaw unless one of two things holds:
  - Sourdaw disables library validation, which affects security posture; or
  - the user re-signs the whole app ad hoc, and Sourdaw documents how to do that.

  This applies equally to Electron's own `libffmpeg.dylib` (R-008).
- **Confidence.** High for the platform behavior. Low for the compliance inference.
- **Relevance.** This is an LGPL compliance detail for (a) and the hybrid. It goes to counsel as
  part of Q-1.

### Precedent

**R-021. Shipping DAWs combine platform codecs with a minimal bundled FFmpeg.**
- **Observation.**
  - REAPER decodes through AVFoundation, Windows Media Foundation, DirectShow, QuickTime, and
    "FFmpeg ... (minimal subset included)", plus optional VLC. It encodes through AVFoundation,
    FFmpeg, and Windows Media Foundation.
  - Cubase Pro 15's Export Video dialog has a "Replace Audio in Video" tab, which embeds the mix
    "without re-rendering", and a separate "Render New Video File" tab.
- **Source claim.** Steinberg ships an Avid-licensed DNxHD decoder. A forum user claims FFmpeg
  runs underneath; that is unconfirmed.
- **Confidence.** High for the REAPER and Cubase pages. Low for the forum claim.
- **Relevance.**
  - The hybrid matches what shipping DAWs do.
  - "Replace audio without re-rendering" is an established export mode. It needs only muxing, so
    no video encoder is required.

**R-022. Chromium encodes H.264 only through OpenH264 or platform encoders.**
- **Source claim.** Chromium developers say H.264 encoding uses either OpenH264 (Chrome builds)
  or platform encoders. x264 is excluded for GPL reasons.
- **Confidence.** Low. The evidence is search summaries, and Electron's OpenH264 status is
  `[unconfirmed]`.
- **Relevance.** WebCodecs in Electron might cover H.264 and HEVC decode and encode with no extra
  native code. It cannot cover ProRes or DNx, so it complements but does not replace the
  options. This was not probed.

## Options

| Option | Copyright licensing | Patent exposure | Film-scoring coverage | Cost and risk | Verdict |
| --- | --- | --- | --- | --- | --- |
| (a) LGPL-only FFmpeg, dynamic | Compatible with closed source if the checklist is met (R-001, R-002). Relinking on macOS needs a decision (R-020). | Sourdaw distributes the H.264, HEVC, and AAC decoders and any native encoders itself (R-009, R-010, R-011). This is in addition to the exposure Electron already carries (R-008). §11 tension (R-002). | Full decode on both OSes, including ProRes and DNx on Windows (R-018). H.264 encode needs OpenH264 (R-012) or platform wrappers (R-018), because native FFmpeg has no H.264 encoder. | Moderate build and compliance work. Apple calls FFmpeg's ProRes unauthorized (R-017). | Viable. Best as the base of a hybrid. |
| (b) GPL build with x264 | Incompatible with closed source when linked (R-003). As a subprocess, it still carries GPL source obligations for the shipped binary (R-005). x264's commercial license does not relicense the rest of FFmpeg (R-004). | Sourdaw ships an H.264 encoder: an AVC pool license is needed (R-009); x264's fee is separate (R-004). | Best H.264 encoder quality. No coverage gain over (a) for decoding. | Highest legal risk. Commercial x264 terms unknown. | Reject, unless Sourdaw goes GPL. |
| (c) User-installed system FFmpeg | Sourdaw distributes no FFmpeg. Typical builds are GPL (R-006), so in-process linking is risky (R-005). CLI use is arm's length. | Moves the codec to the user's install. Possible inducement exposure is an unassessed legal question (Q-1). | Whatever the user installed. Inconsistent across machines. | ABI churn (R-007), install friction, and support load. A film-scoring DAW that cannot open picture out of the box fails the core workflow. | Reject as primary. Acceptable only as an optional "advanced decoder" slot, through the CLI. |
| (d) Platform codecs only | No FFmpeg obligations. | OS vendors license their codecs (R-009, OS category). Coverage of professional delivery use is unclear (R-009). Lowest Sourdaw-owned exposure. | macOS: ProRes, H.264, HEVC native, plus DNx and XAVC with Pro Video Formats (R-016). Windows: no ProRes, no DNx, no MXF (R-013, R-015). N editions and HEVC need user installs (R-014). | Two native integrations (AVFoundation, Media Foundation) behind one interface. Windows coverage gap. | Viable on macOS. Insufficient alone on Windows. |
| (e) Hybrid: (d) first, LGPL FFmpeg for the rest | As (a), but FFmpeg can be built with its H.264, HEVC, and AAC codecs disabled (R-018). | Sourdaw's own codec exposure drops to ProRes and DNx software decode on Windows and FFmpeg's container code. H.264, HEVC, and AAC go through the OS (R-016, R-013) or remain only in Electron's bundled FFmpeg (R-008). | Full on both OSes. Replace-audio export needs no video encoder (R-021). New-render export uses VideoToolbox or Media Foundation H.264 (R-018). | Most engineering work: two platform paths plus FFmpeg. Matches REAPER (R-021). | Recommended. |

## Open questions

These are questions for the human. No human was available, so each one records a recommended
answer and the work continued on it.

**Q-1. Counsel review of patent and LGPL posture.** This is a question of legal exposure, which
is the owner's call.
- **Options.**
  - Retain codec counsel before the first video-capable release. Recommended. Cost: legal fees.
  - Sign the Via LA AVC license on our own reading and stay inside the free tier. Cost: a signed
    agreement and reporting, with the §11 question unresolved.
  - Ship the hybrid without any pool license, on the theory that H.264, HEVC, and AAC go through
    the OS. Cost: the risk carried by Electron's bundled decoders (R-008) stays unaddressed.
- **Recommended answer.** Retain counsel. Scope the review to four items:
  - whether Electron's proprietary-codec FFmpeg (R-008) needs a Via LA AVC and AAC license
    for Sourdaw;
  - whether OS-codec use covers professional delivery (R-009);
  - how LGPL §11 applies (R-002);
  - the macOS relinking route (R-020).

**Q-2. ProRes claims and authorization.** This changes what the product claims to be.
- **Options.**
  - Use AVFoundation ProRes on macOS and FFmpeg's decoder on Windows. Describe the Windows path
    neutrally, as "decodes ProRes-encoded media", without the Apple mark. Recommended.
  - License the MainConcept ProRes SDK for Windows. Cost: unknown license fees.
  - Email ProRes@apple.com to seek authorization. Cost: time, with an uncertain outcome.
- **Recommended answer.** The first option for v1. Revisit if Apple or customers raise it.

**Q-3. Required format list.** This is an engineering assumption.
- **Recommended answer.** Decode ProRes 422/4444, DNxHD/DNxHR, H.264, and HEVC in MOV, MP4, and
  MXF. Export by replacing audio (re-wrap) plus an H.264 MP4 reference. Confirm it against a
  composer survey or a support-ticket sample before freezing the scope.

**Q-4. Annual unit volume.** This decides the AVC royalty tier (R-009).
- **Recommended answer.** Assume under 100,000 units a year for the first release, which costs $0
  in AVC royalties if licensed. Re-check at each annual reporting date.

**Q-5. WebCodecs as the decode and encode path for H.264 and HEVC inside Electron (R-022).**
- **Recommended answer.** Probe it before writing the Media Foundation H.264 path. If WebCodecs
  covers frame-accurate H.264 and HEVC decode and encode on both OSes, it replaces part of (d).
- **Test.** Run `VideoDecoder.isConfigSupported` and `VideoEncoder.isConfigSupported` for
  `avc1.640028` and `hvc1.1.6.L120.90` in Sourdaw's Electron build on macOS and on Windows.
  Then decode-seek accuracy over a 10-minute 23.976 file.

## Recommendation

Adopt option (e): platform codecs first, with an LGPL-only, dynamically linked FFmpeg for what
the platforms lack. Reject (b) and (c) as primary postures.

1. **macOS.** Decode and encode through AVFoundation and VideoToolbox: H.264, HEVC, and ProRes,
   plus DNx and XAVC when Pro Video Formats is installed. See R-016 and R-017.
2. **Windows.** Use Media Foundation for H.264 decode and encode and for AAC (R-013), and detect
   N editions and the HEVC extension (R-014). Use the LGPL FFmpeg for MXF and MOV demux and for
   ProRes and DNx decode (R-015, R-018).
3. **FFmpeg build.** Configure without `--enable-gpl` and `--enable-nonfree`. Disable FFmpeg's
   native H.264, HEVC, and AAC decoders and encoders where the OS path covers them. Ship the
   libraries as unrenamed shared libraries and follow the FFmpeg checklist in full (R-001,
   R-002, R-003, R-018). Never link libx264, libx265, or DeckLink through FFmpeg (R-003, R-019).
4. **Export.** Make "replace audio in video" (re-wrap, no video encode) the default. Render new
   H.264 only through `h264_videotoolbox` or `h264_mf`, or AVFoundation and Media Foundation
   directly. Export audio as PCM or platform AAC (R-010, R-018, R-021).
5. **System FFmpeg.** Allow it at most as an opt-in decoder of last resort, invoked as a separate
   `ffmpeg` process and never loaded in-process (R-005, R-006, R-007).
6. **Before release.** Resolve Q-1 with counsel. It covers today's Electron exposure (R-008) as
   well as this decision.

The weakest links are the legal inferences in R-002, R-009, R-017, and R-020. None of them is
backed by counsel or case law. The engineering direction holds whatever counsel says on licence
fees, because (e) minimizes the codecs Sourdaw itself distributes. A finding that the OS-codec
route does not cover professional use would change only the pool licenses to sign, not the
architecture. The decision stays with the owner.
