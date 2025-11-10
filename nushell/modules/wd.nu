# wd.nu - Directory bookmark manager for Nushell
# Similar to oh-my-zsh's wd plugin

# 获取书签文件路径
def wd-file [] {
  let config_dir = ($env | get -o XDG_CONFIG_HOME | default $"($env.HOME)/.config")
  $"($config_dir)/nushell/wd_bookmarks.json"
}

# 补全函数：获取所有书签名称
def get-bookmark-names [] {
  let bookmarks = (load-bookmarks)
  $bookmarks | columns
}

# 初始化书签文件
def init-wd [] {
  let wd_file = (wd-file)
  if not ($wd_file | path exists) {
    {} | save $wd_file
  }
}

# 加载书签
def load-bookmarks [] {
  init-wd
  open (wd-file)
}

# 保存书签
def save-bookmarks [bookmarks: record] {
  $bookmarks | save -f (wd-file)
}

# 添加书签
export def "wd add" [name?: string] {
  let current_dir = (pwd)
  let bookmark_name = if ($name | is-empty) {
    $current_dir | path basename
  } else {
    $name
  }
  let bookmarks = (load-bookmarks)
  let updated = ($bookmarks | upsert $bookmark_name $current_dir)
  save-bookmarks $updated
  print $"✓ Bookmark '($bookmark_name)' added: ($current_dir)"
}

# 列出书签
export def "wd list" [] {
  let bookmarks = (load-bookmarks)
  let count = ($bookmarks | columns | length)
  if $count == 0 {
    print "No bookmarks found. Use 'wd add <name>' to create one."
  } else {
    print "📚 Bookmarks:"
    $bookmarks | transpose key value | each { |row|
      print $"  ($row.key) → ($row.value)"
    } | ignore
  }
}

# 跳转到书签
export def --env main [
  name: string@get-bookmark-names  # 使用补全函数
] {
  let bookmarks = (load-bookmarks)
  if $name in ($bookmarks | columns) {
    let path = ($bookmarks | get $name)
    cd $path
    print $"✓ Switched to: ($path)"
  } else {
    print $"✗ Bookmark '($name)' not found"
    print "Use 'wd list' to see available bookmarks"
  }
}

# 删除书签
export def "wd rm" [
  name: string@get-bookmark-names  # 使用补全函数
] {
  let bookmarks = (load-bookmarks)
  if $name in ($bookmarks | columns) {
    let updated = ($bookmarks | reject $name)
    save-bookmarks $updated
    print $"✓ Bookmark '($name)' removed"
  } else {
    print $"✗ Bookmark '($name)' not found"
  }
}

# 显示当前目录的书签
export def "wd show" [] {
  let bookmarks = (load-bookmarks)
  let current_dir = (pwd)
  let matches = ($bookmarks | transpose key value | where value == $current_dir | get key)
  if ($matches | length) > 0 {
    print $"📍 Current directory bookmarks: ($matches | str join ', ')"
  } else {
    print "No bookmarks for current directory"
  }
}

# 清空所有书签
export def "wd clean" [] {
  let bookmarks = (load-bookmarks)
  let count = ($bookmarks | columns | length)
  if $count == 0 {
    print "No bookmarks to clean"
  } else {
    print $"⚠️  This will remove all ($count) bookmarks. Are you sure? (y/N)"
    let confirm = (input)
    if $confirm == "y" or $confirm == "Y" {
      {} | save -f (wd-file)
      print "✓ All bookmarks cleared"
    } else {
      print "Cancelled"
    }
  }
}

# 帮助信息
export def "wd help" [] {
  print "wd - Directory bookmark manager"
  print ""
  print "Usage:"
  print "  wd add <name>     - Add current directory as bookmark"
  print "  wd <name>         - Jump to bookmark"
  print "  wd list           - List all bookmarks"
  print "  wd rm <name>      - Remove bookmark"
  print "  wd show           - Show bookmarks for current directory"
  print "  wd clean          - Remove all bookmarks"
  print "  wd help           - Show this help message"
}
