///|
fnalias @find_cluster_break.(find_cluster_break, is_extending_char)

///|
fn main {
  // Test the example from the README
  let result = find_cluster_break("💪🏽🦋", 0)
  println("Example from README: \{result}")

  // Test simple text
  let simple = find_cluster_break("hello", 0)
  println("Simple text 'hello' first break: \{simple}")

  // Test with extending character
  let extending = is_extending_char(768)
  println("Is 768 an extending char: \{extending}")

  // Test complex emoji
  let emoji_breaks = []
  let emoji_text = "👨‍🎤💪🏽👩‍👩‍👧‍👦"
  let mut pos = 0
  while pos < emoji_text.length() {
    let next = find_cluster_break(emoji_text, pos)
    if next == emoji_text.length() {
      break
    }
    emoji_breaks.push(next)
    pos = next
  }
  println("Emoji breaks: \{emoji_breaks}")
}
