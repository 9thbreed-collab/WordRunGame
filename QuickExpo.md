# Component Extraction Process - Quick Explanation

## Overview

This document explains how to extract visual components from game map screenshots and prepare them for use in the WordRun rebuild.

---

## The Problem

We have 4 source images containing isometric map visuals:
- `GameMapInspo/Image.jpg`
- `GameMapInspo/Map1.png`
- `GameMapInspo/Map2.png`
- `GameMapInspo/Map3.png`

These images contain multiple visual elements (land cubes, trees, buildings, UI elements) that need to be **sliced into individual component images** for use in the game engine.

---

## What Already Exists

**Agent A created 42 instruction files** describing each component:

Location: `wordrun-rebuild/assets/components/instructions/`

Each instruction file (e.g., `MAP-001.json`) contains:
```json
{
  "componentId": "MAP-001",
  "name": "Grass Land Cube",
  "category": "map",
  "needsInterpolation": true,
  "dimensions": {"width": 64, "height": 48},
  "sourceImage": "Map1.png",
  "sourceCoords": {"x": 120, "y": 340},
  "regions": [
    {
      "location": "left face",
      "boundingBox": {"x": 0, "y": 20, "width": 25, "height": 40},
      "issue": "occluded by tree trunk",
      "suggestedFill": "continue grass texture"
    }
  ]
}
```

**What's missing:** The actual extracted PNG images in `wordrun-rebuild/assets/components/raw/`

---

## The Extraction Process

### Step 1: Read Instruction Files
```
For each JSON file in assets/components/instructions/:
  - Parse the JSON
  - Get sourceImage (which map file to slice from)
  - Get sourceCoords (x, y position in source image)
  - Get dimensions (width, height of component)
```

### Step 2: Open Source Image
```
Open the source image file (e.g., GameMapInspo/Map1.png)
using an image library (PIL/Pillow in Python, Sharp in Node.js)
```

### Step 3: Crop Component Region
```
Crop a rectangle from the source image:
  - left = sourceCoords.x
  - top = sourceCoords.y
  - right = sourceCoords.x + dimensions.width
  - bottom = sourceCoords.y + dimensions.height
```

### Step 4: Save Extracted Component
```
Save the cropped image to:
  wordrun-rebuild/assets/components/raw/[componentId].png

Example: MAP-001.png
```

### Step 5: Repeat for All 42 Components

---

## Python Implementation

```python
import os
import json
from PIL import Image

# Paths
PROJECT_ROOT = "/Users/nathanielgiddens/WordRunProject"
SOURCE_DIR = f"{PROJECT_ROOT}/GameMapInspo"
INSTRUCTIONS_DIR = f"{PROJECT_ROOT}/wordrun-rebuild/assets/components/instructions"
OUTPUT_DIR = f"{PROJECT_ROOT}/wordrun-rebuild/assets/components/raw"

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Process each instruction file
for filename in os.listdir(INSTRUCTIONS_DIR):
    if not filename.endswith('.json'):
        continue

    # Read instruction
    with open(f"{INSTRUCTIONS_DIR}/{filename}", 'r') as f:
        instruction = json.load(f)

    component_id = instruction['componentId']
    source_image = instruction.get('sourceImage', 'Map1.png')
    coords = instruction.get('sourceCoords', {'x': 0, 'y': 0})
    dims = instruction.get('dimensions', {'width': 64, 'height': 64})

    # Open source image
    source_path = f"{SOURCE_DIR}/{source_image}"
    if not os.path.exists(source_path):
        print(f"Source not found: {source_path}")
        continue

    img = Image.open(source_path)

    # Crop component
    left = coords['x']
    top = coords['y']
    right = left + dims['width']
    bottom = top + dims['height']

    cropped = img.crop((left, top, right, bottom))

    # Save
    output_path = f"{OUTPUT_DIR}/{component_id}.png"
    cropped.save(output_path, 'PNG')
    print(f"Extracted: {component_id}")

print("Extraction complete!")
```

---

## Node.js Alternative (using Sharp)

```javascript
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const PROJECT_ROOT = '/Users/nathanielgiddens/WordRunProject';
const SOURCE_DIR = `${PROJECT_ROOT}/GameMapInspo`;
const INSTRUCTIONS_DIR = `${PROJECT_ROOT}/wordrun-rebuild/assets/components/instructions`;
const OUTPUT_DIR = `${PROJECT_ROOT}/wordrun-rebuild/assets/components/raw`;

// Ensure output directory exists
fs.mkdirSync(OUTPUT_DIR, { recursive: true });

// Get all instruction files
const files = fs.readdirSync(INSTRUCTIONS_DIR).filter(f => f.endsWith('.json'));

async function extractAll() {
  for (const filename of files) {
    const instruction = JSON.parse(
      fs.readFileSync(`${INSTRUCTIONS_DIR}/${filename}`, 'utf8')
    );

    const { componentId, sourceImage = 'Map1.png', sourceCoords = {x:0,y:0}, dimensions = {width:64,height:64} } = instruction;

    const sourcePath = `${SOURCE_DIR}/${sourceImage}`;
    const outputPath = `${OUTPUT_DIR}/${componentId}.png`;

    await sharp(sourcePath)
      .extract({
        left: sourceCoords.x,
        top: sourceCoords.y,
        width: dimensions.width,
        height: dimensions.height
      })
      .toFile(outputPath);

    console.log(`Extracted: ${componentId}`);
  }
  console.log('Extraction complete!');
}

extractAll();
```

---

## After Extraction: Interpolation

Once raw images are extracted, **Agent A2** and **Agent A3** process them:

1. **Agent A2 (Map Components):** Uses AI image generation to fill in occluded/missing parts of land cubes, trees, buildings
2. **Agent A3 (UI Components):** Fills in simpler shapes like buttons, panels

They read the `regions` array in each instruction file to know exactly what needs fixing.

Output goes to:
- `assets/components/full/` (interpolated images)
- `assets/components/thumbnails/` (64x64 previews)

---

## After Interpolation: Index Generation

Finally, create browsable index:

1. **ComponentCatalog.html** - Visual grid of all component thumbnails
2. **components.json** - Structured data for programmatic access

---

## Dependencies

**Python:**
```bash
pip3 install Pillow
```

**Node.js:**
```bash
npm install sharp
```

---

## File Structure After Complete Process

```
wordrun-rebuild/assets/components/
├── instructions/     # Agent A output (42 JSON files) ✓ EXISTS
├── raw/              # Extracted images (42 PNG files) ← NEEDS EXTRACTION
├── full/             # Interpolated images (after A2/A3)
└── thumbnails/       # 64x64 previews (after A2/A3)
```

---

*Document created: 2026-01-21*
