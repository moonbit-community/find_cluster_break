///|
fn is_regional_indicator(code : Int) -> Bool {
  code >= 0x1F1E6 && code <= 0x1F1FF
}

///|
let zwj = 0x200d

///|
/// Returns a next grapheme cluster break _after_ (not equal to) `pos`,
/// if `forward` is true, or before otherwise. Returns `pos` itself if no
/// further cluster break is available in the string. Moves across
/// surrogate pairs, extending characters (when `include_extending` is
/// true, which is the default), characters joined with zero-width joiners,
/// and flag emoji.
pub fn find_cluster_break(
  str : String,
  pos : Int,
  forward? : Bool = true,
  include_extending? : Bool = true,
) -> Int {
  if forward {
    next_cluster_break(str, pos, include_extending)
  } else {
    prev_cluster_break(str, pos, include_extending)
  }
}

///|
fn next_cluster_break(str : String, pos : Int, include_extending : Bool) -> Int {
  let mut pos = pos
  if pos == str.length() {
    return pos
  }
  // If pos is in the middle of a surrogate pair, move to its start
  if pos > 0 &&
    surrogate_low(char_code_at(str, pos)) &&
    surrogate_high(char_code_at(str, pos - 1)) {
    pos = pos - 1
  }
  let mut prev = code_point_at(str, pos)
  pos = pos + code_point_size(prev)
  while pos < str.length() {
    let next = code_point_at(str, pos)
    if prev == zwj ||
      next == zwj ||
      (include_extending && is_extending_char(next)) {
      pos = pos + code_point_size(next)
      prev = next
    } else if is_regional_indicator(next) {
      let mut count_before = 0
      let mut i = pos - 2
      while i >= 0 && is_regional_indicator(code_point_at(str, i)) {
        count_before = count_before + 1
        i = i - 2
      }
      if count_before % 2 == 0 {
        break
      } else {
        pos = pos + 2
      }
    } else {
      break
    }
  }
  pos
}

///|
fn prev_cluster_break(str : String, pos : Int, include_extending : Bool) -> Int {
  let mut pos = pos
  while pos > 0 {
    let found = next_cluster_break(str, pos - 2, include_extending)
    if found < pos {
      return found
    }
    pos = pos - 1
  }
  0
}

///|
fn char_code_at(str : String, pos : Int) -> Int {
  str[pos] // Returns Int (character code) directly
}

///|
fn code_point_at(str : String, pos : Int) -> Int {
  let code0 = char_code_at(str, pos)
  if !surrogate_high(code0) || pos + 1 == str.length() {
    return code0
  }
  let code1 = char_code_at(str, pos + 1)
  if !surrogate_low(code1) {
    return code0
  }
  (code0 - 0xd800) * 1024 + (code1 - 0xdc00) + 0x10000 // Using * instead of << 10
}

///|
fn surrogate_low(ch : Int) -> Bool {
  ch >= 0xDC00 && ch < 0xE000
}

///|
fn surrogate_high(ch : Int) -> Bool {
  ch >= 0xD800 && ch < 0xDC00
}

///|
fn code_point_size(code : Int) -> Int {
  if code < 0x10000 {
    1
  } else {
    2
  }
}
