---
source: https://trigger.dev/docs/config/extensions/audioWaveform
scraped: 2026-02-28
---

# Audio Waveform

The audioWaveform build extension enables Audio Waveform support in your project.

## Overview

"Previously, we installed Audio Waveform in the build image. That's been moved to a build extension" — meaning you'll now configure it differently than before.

## Configuration

To add audioWaveform to your project, import and register the extension in your configuration file:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { audioWaveform } from "@trigger.dev/build/extensions/audioWaveform";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [audioWaveform()], // uses version 1.1.0 of audiowaveform by default
  },
});
```

By default, this setup uses version 1.1.0 of audiowaveform. The extension is based on the [BBC's audiowaveform project](https://github.com/bbc/audiowaveform).
