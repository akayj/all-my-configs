# git.nu - Git helper commands for Nushell

# Show short git status
export def "git status-short" [] {
    git status --short
}

# Show oneline git log
export def "git log-oneline" [count?: int = 10] {
    git log --oneline -n $count
}

# Quick commit with message
export def "git commit-quick" [message: string] {
    git add -A
    git commit -m $message
}

# Push current branch to origin
export def "git push-current" [] {
    let branch = (git rev-parse --abbrev-ref HEAD | str trim)
    git push origin $branch
}

# Pull current branch from origin
export def "git pull-current" [] {
    let branch = (git rev-parse --abbrev-ref HEAD | str trim)
    git pull origin $branch
}

# Show current git branch
export def "git current-branch" [] {
    git rev-parse --abbrev-ref HEAD | str trim
}

# List all git branches
export def "git branches" [] {
    git branch -a
}

# Create and checkout new branch
export def "git new-branch" [name: string] {
    git checkout -b $name
}

# Delete branch
export def "git delete-branch" [name: string] {
    git branch -d $name
}

# Force delete branch
export def "git delete-branch-force" [name: string] {
    git branch -D $name
}

# Show git diff with color
export def "git diff-color" [] {
    git diff --color=always | less -R
}

# Show recent commits with stats
export def "git log-stats" [count?: int = 10] {
    git log --stat -n $count
}

# Show git graph
export def "git log-graph" [count?: int = 20] {
    git log --graph --oneline --decorate --all -n $count
}

# Git aliases for common commands
export alias gs = git status-short
export alias gl = git log-oneline
export alias gp = git push-current
export alias gpl = git pull-current
export alias gc = git commit-quick
export alias gb = git current-branch
export alias gd = git diff
export alias ga = git add
export alias gc = git clone
