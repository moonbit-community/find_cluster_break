// Test helper function for assertions

///|
fn assert_eq(a : Int, b : Int) -> Unit {
  if a != b {
    abort("Assertion failed: \{a} != \{b}")
  }
}

///|
fn assert_bool_eq(a : Bool, b : Bool) -> Unit {
  if a != b {
    abort("Boolean assertion failed: \{a} != \{b}")
  }
}

// Helper function to parse test specification and extract expected break positions

///|
fn parse_test_spec(spec : String) -> (String, Array[Int]) {
  let breaks : Array[Int] = []
  let mut result = ""
  let mut i = 0
  while i < spec.length() {
    if spec[i] == 124 { // '|' character code
      breaks.push(result.length())
      i = i + 1
    } else {
      result = result + Int::unsafe_to_char(spec[i]).to_string()
      i = i + 1
    }
  }
  (result, breaks)
}

// Test function that matches the JavaScript test pattern

///|
fn test_find_cluster_break_spec(spec : String) -> Unit {
  let (text, expected_breaks) = parse_test_spec(spec)
  let found : Array[Int] = []
  let mut i = 0
  while true {
    let next = find_cluster_break(text, i)
    if next == text.length() {
      break
    }
    found.push(next)
    i = next
  }

  // Compare found breaks with expected breaks
  if found.length() != expected_breaks.length() {
    abort(
      "Length mismatch: found \{found.length()} breaks, expected \{expected_breaks.length()}",
    )
  }
  for j = 0; j < found.length(); j = j + 1 {
    assert_eq(found[j], expected_breaks[j])
  }
}

///|
test "simple character breaks" {
  test_find_cluster_break_spec("a|b|c|d")
}

///|
test "accented characters" {
  test_find_cluster_break_spec("a|é̠|ő|x")
}

///|
test "emoji" {
  test_find_cluster_break_spec("😎|🙉")
}

///|
test "complex emoji sequences" {
  test_find_cluster_break_spec(
    "👨‍🎤|💪🏽|👩‍👩‍👧‍👦|❤",
  )
}

///|
test "regional indicator flags" {
  test_find_cluster_break_spec("🇩🇪|🇫🇷|🇪🇸|x|🇮🇹")
}

// Test the example from the README

///|
test "readme example" {
  let result = find_cluster_break("💪🏽🦋", 0)
  assert_eq(result, 4)
}

// Test is_extending_char function

///|
test "is_extending_char" {
  // Test some known extending characters
  // These are just basic tests - the actual implementation contains comprehensive ranges
  assert_bool_eq(is_extending_char(768), true) // Combining grave accent
  assert_bool_eq(is_extending_char(65), false) // 'A' - not extending
  assert_bool_eq(is_extending_char(97), false) // 'a' - not extending
}
