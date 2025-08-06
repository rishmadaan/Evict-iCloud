# Evict iCloud (macOS) 🚀

A tiny Apple Script utility that frees disk space by “evicting” local copies of any iCloud Drive folder—exactly what Finder’s **Remove Download** does, but in one click.

<p align="center">
  <img src="docs/screenshot.png" alt="App dialog preview" width="550">
</p>

## Why?

* Keep archive-heavy folders in iCloud without clogging your SSD  
* Zero-terminal workflow for non-technical teammates  
* Works on macOS 12 Monterey → 15 Sequoia (uses `brctl evict`)

## Requirements

* macOS with **Optimize Mac Storage** turned **on**  
  ` › System Settings › Apple ID › iCloud › iCloud Drive`

## Installation

1. Clone or download this repo.  
2. Open **Evict-iCloud.applescript** in *Script Editor*.  
3. **File › Export…** → *Application* → save as **Evict iCloud.app**.  
4. *(Optional)* Drag the `.app` into **/Applications** or your Dock.

## Usage

1. Double-click **Evict iCloud.app**  
2. Choose any folder inside **iCloud Drive**  
3. Click **Continue** – macOS marks the files dataless and reclaims
   space almost instantly.

## How it works

```applescript
-- simplified excerpt
set tgt to choose folder "Pick an iCloud folder:"
do shell script "/usr/bin/brctl evict " & quoted form of POSIX path of tgt
