module VibeCode.Agents where

import VibeCode.Types

-- inspired by https://github.com/VacTube/vibedetector/blob/main/main.go
agents :: [Agent]
agents =
  [ Agent
      { aiName        = "Claude Code"
      , aiUrl         = "https://claude.ai/code"
      , aiFiles       = ["CLAUDE.md"]
      , aiDirectories = [".claude"]
      , aiGitNeedles  = [GitCommitMessage "^Co-Authored-By: Claude"]
      }
  , Agent
      { aiName        = "Cursor"
      , aiUrl         = "https://cursor.com"
      , aiFiles       = [".cursorrules"]
      , aiDirectories = [".cursor"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Windsurf"
      , aiUrl         = "https://codeium.com/windsurf"
      , aiFiles       = [".windsurfrules"]
      , aiDirectories = [".windsurf"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "GitHub Copilot"
      , aiUrl         = "https://github.com/features/copilot"
      , aiFiles       = [".github/copilot-instructions.md"]
      , aiDirectories = []
      , aiGitNeedles  = [GitCommitMessage "^Agent-Logs-Url: https://github.com/", GitAuthor "Copilot@users.noreply.github.com"]
      }
  , Agent
      { aiName        = "Aider"
      , aiUrl         = "https://aider.chat"
      , aiFiles       = [".aider.conf.yml", ".aiderignore", "CONVENTIONS.md"]
      , aiDirectories = [".aider"]
      , aiGitNeedles  = [GitCommitMessage "^Co-Authored-By: aider", GitAuthor "(aider)"]
      }
  , Agent
      { aiName        = "Cline"
      , aiUrl         = "https://github.com/cline/cline"
      , aiFiles       = [".clinerules"]
      , aiDirectories = [".clinerules"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Zed"
      , aiUrl         = "https://zed.dev"
      , aiFiles       = []
      , aiDirectories = [".zed"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Continue.dev"
      , aiUrl         = "https://continue.dev"
      , aiFiles       = []
      , aiDirectories = [".continue"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Kiro"
      , aiUrl         = "https://kiro.dev"
      , aiFiles       = []
      , aiDirectories = [".kiro"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Gemini CLI"
      , aiUrl         = "https://developers.google.com/gemini-code-assist"
      , aiFiles       = ["GEMINI.md", "AGENT.md"]
      , aiDirectories = [".gemini"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "AGENTS.md Standard"
      , aiUrl         = "https://github.com/anthropics/agent-rules"
      , aiFiles       = ["AGENTS.md"]
      , aiDirectories = []
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Bolt"
      , aiUrl         = "https://bolt.new"
      , aiFiles       = [".bolt"]
      , aiDirectories = [".bolt"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Replit Agent"
      , aiUrl         = "https://replit.com"
      , aiFiles       = [".replit"]
      , aiDirectories = [".replit"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Codex CLI"
      , aiUrl         = "https://github.com/openai/codex"
      , aiFiles       = ["codex.md"]
      , aiDirectories = [".codex"]
      , aiGitNeedles  = [GitAuthor "Codex Text", GitCommitMessage "^Co-Authored-By: Codex"]
      }
  , Agent
      { aiName        = "Tabnine"
      , aiUrl         = "https://tabnine.com"
      , aiFiles       = [".tabnine.json", "tabnine.yaml"]
      , aiDirectories = [".tabnine"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Amazon Q Developer"
      , aiUrl         = "https://aws.amazon.com/q/developer/"
      , aiFiles       = []
      , aiDirectories = [".amazonq", ".q"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Sourcegraph Cody"
      , aiUrl         = "https://sourcegraph.com/cody"
      , aiFiles       = [".cody.json", "cody.json"]
      , aiDirectories = [".cody"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Augment Code"
      , aiUrl         = "https://augmentcode.com"
      , aiFiles       = []
      , aiDirectories = [".augment"]
      , aiGitNeedles  = []
      }
  , Agent
      { aiName        = "Supermaven"
      , aiUrl         = "https://supermaven.com"
      , aiFiles       = []
      , aiDirectories = [".supermaven"]
      , aiGitNeedles  = []
      }
  ]
