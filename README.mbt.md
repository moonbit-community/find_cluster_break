# Find Cluster Break

A MoonBit implementation of Unicode grapheme cluster break detection. This library finds the position of grapheme cluster breaks in a string, helping you properly handle complex Unicode text including emoji, accented characters, and other multi-codepoint sequences.

## Overview

This is a MoonBit port of the JavaScript library [find-cluster-break](https://github.com/marijnh/find-cluster-break) by Marijn Haverbeke. It implements the Unicode Standard Annex #29 for grapheme cluster boundary detection, ensuring that visually perceived characters are treated as single units.

A grapheme cluster is what users typically think of as a "character" - it could be a simple letter like 'a', an accented character like 'é', or a complex emoji sequence like '👨‍🎤' (man singer emoji). This library helps you find the boundaries between these clusters.

## Installation

Add this package to your MoonBit project:

```bash
moon add hackwaly/find_cluster_break
```

Then import it in your `moon.pkg.json`:

```json
{
  "import": ["hackwaly/find_cluster_break"]
}
```

## API Reference

### find_cluster_break

The main function for finding grapheme cluster breaks:

```moonbit
test "basic usage" {
  // Find the next cluster break after position 0
  let result = @find_cluster_break.find_cluster_break("💪🏽🦋", 0)
  inspect(result, content="4") // Points to start of butterfly emoji
}
```

```moonbit
test "find all cluster breaks" {
  let text = "👨‍🎤💪🏽👩‍👩‍👧‍👦"
  let breaks : Array[Int] = []
  let mut pos = 0
  
  while pos < text.length() {
    let next_break = @find_cluster_break.find_cluster_break(text, pos)
    if next_break == text.length() {
      break
    }
    breaks.push(next_break)
    pos = next_break
  }
  
  inspect(breaks, content="[5, 9]") // Positions of cluster boundaries
}
```

### Forward and Backward Search

You can search for cluster breaks in both directions:

```moonbit
test "directional search" {
  let text = "a👨‍🎤b"
  
  // Forward search (default)
  let forward = @find_cluster_break.find_cluster_break(text, 0, forward=true)
  inspect(forward, content="1")
  
  // Backward search
  let backward = @find_cluster_break.find_cluster_break(text, text.length(), forward=false)
  inspect(backward, content="6") // Start of last cluster
}
```

### Including Extending Characters

Control whether extending characters are considered part of clusters:

```moonbit
test "extending characters" {
  let text = "é̠" // 'e' + combining grave + combining left angle below
  
  // With extending characters (default)
  let with_extending = @find_cluster_break.find_cluster_break(text, 0, include_extending=true)
  inspect(with_extending, content="2") // Treats the whole sequence as one cluster
  
  // Without extending characters
  let without_extending = @find_cluster_break.find_cluster_break(text, 0, include_extending=false)
  inspect(without_extending, content="1") // Only the base 'e'
}
```

### is_extending_char

Check if a Unicode code point is an extending character:

```moonbit
test "extending character detection" {
  // Combining grave accent (U+0300)
  let is_combining = @find_cluster_break.is_extending_char(768)
  inspect(is_combining, content="true")
  
  // Regular letter 'A'
  let is_letter = @find_cluster_break.is_extending_char(65)
  inspect(is_letter, content="false")
  
  // Skin tone modifier (U+1F3FD)
  let is_modifier = @find_cluster_break.is_extending_char(0x1F3FD)
  inspect(is_modifier, content="true")
}
```

## Complex Text Handling

### Emoji Sequences

The library correctly handles complex emoji sequences:

```moonbit
test "emoji sequences" {
  // Man singer: man + ZWJ + microphone
  let singer = "👨‍🎤"
  let break_pos = @find_cluster_break.find_cluster_break(singer, 0)
  inspect(break_pos, content="5") // Entire sequence is one cluster
  
  // Flexed bicep with skin tone
  let flexed = "💪🏽"
  let muscle_break = @find_cluster_break.find_cluster_break(flexed, 0)
  inspect(muscle_break, content="4") // Emoji + skin tone modifier
}
```

### Regional Indicator Sequences (Flags)

Flag emoji are correctly handled as pairs:

```moonbit
test "flag emoji" {
  let flags = "🇩🇪🇫🇷🇪🇸" // German, French, Spanish flags
  let breaks : Array[Int] = []
  let mut pos = 0
  
  while pos < flags.length() {
    let next = @find_cluster_break.find_cluster_break(flags, pos)
    if next == flags.length() {
      break
    }
    breaks.push(next)
    pos = next
  }
  
  inspect(breaks, content="[4, 8]") // Each flag is 4 bytes (2 regional indicators)
}
```

### Accented Characters

Handles both precomposed and decomposed accented characters:

```moonbit
test "accented characters" {
  // Decomposed: 'e' + combining acute accent
  let decomposed = "é"
  let d_break = @find_cluster_break.find_cluster_break(decomposed, 0)
  inspect(d_break, content="1") // Treats as single cluster
  
  // Complex accents: 'o' + multiple combining marks
  let complex = "ő̠" // o + double acute + left angle below
  let c_break = @find_cluster_break.find_cluster_break(complex, 0)
  inspect(c_break, content="2") // All combining marks included
}
```

## Character Counting

Use this library to count visual characters correctly:

```moonbit
test "visual character counting" {
  fn count_grapheme_clusters(text : String) -> Int {
    let mut count = 0
    let mut pos = 0
    
    while pos < text.length() {
      let next = @find_cluster_break.find_cluster_break(text, pos)
      if next == pos {
        break
      }
      count = count + 1
      pos = next
    }
    
    count
  }
  
  let text = "Hello 👨‍👩‍👧‍👦 World!"
  let cluster_count = count_grapheme_clusters(text)
  inspect(cluster_count, content="14") // Visual characters, not code units
  
  // Compare with string length (code units)
  let code_unit_length = text.length()
  inspect(code_unit_length, content="24") // Much larger due to emoji
}
```

## Text Processing

### Substring Extraction

Extract substrings by grapheme clusters:

```moonbit
test "cluster-aware substring" {
  fn substring_by_clusters(text : String, start : Int, length : Int) -> String {
    let mut current_cluster = 0
    let mut pos = 0
    let mut start_pos = 0
    let mut end_pos = text.length()
    
    // Find start position
    while current_cluster < start && pos < text.length() {
      let next = @find_cluster_break.find_cluster_break(text, pos)
      if next == pos {
        break
      }
      current_cluster = current_cluster + 1
      pos = next
      if current_cluster == start {
        start_pos = pos
      }
    }
    
    // Find end position
    let mut remaining = length
    while remaining > 0 && pos < text.length() {
      let next = @find_cluster_break.find_cluster_break(text, pos)
      if next == pos {
        break
      }
      remaining = remaining - 1
      pos = next
      if remaining == 0 {
        end_pos = pos
      }
    }
    
    text.substring(start=start_pos, end=end_pos)
  }
  
  let text = "🚀✨🎯"
  let sub = substring_by_clusters(text, 1, 1) // Get second cluster
  inspect(sub, content="✨") // Just the sparkles emoji
}
```

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Related

This is a MoonBit port of the JavaScript library [find-cluster-break](https://github.com/marijnh/find-cluster-break). The original implementation and algorithm design credit goes to Marijn Haverbeke.

For more information about Unicode grapheme clusters, see:
- [Unicode Standard Annex #29](https://unicode.org/reports/tr29/)
- [Unicode Grapheme Cluster Boundaries](https://unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries)
