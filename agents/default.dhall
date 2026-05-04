let GitNeedle =
      < GitCommitMessage : Text
			| GitAuthor : Text
			>

let Agent =
			{ aiName : Text
			, aiUrl : Text
			, aiFiles : List Text
			, aiDirectories : List Text
			, aiGitNeedles : List GitNeedle
			}

let agents : List Agent =
  [ { aiName = "Claude Code"
		, aiUrl = "https://claude.ai/code"
		, aiFiles = [ "CLAUDE.md" ]
		, aiDirectories = [ ".claude" ]
		, aiGitNeedles =
			[ GitNeedle.GitCommitMessage
					"^Co-Authored-By: Claude"
			, GitNeedle.GitCommitMessage
					"^Assisted-by: Claude"
			]
		}
	, { aiName = "Cursor"
		, aiUrl = "https://cursor.com"
		, aiFiles = [ ".cursorrules" ]
		, aiDirectories = [ ".cursor" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Windsurf"
		, aiUrl = "https://codeium.com/windsurf"
		, aiFiles = [ ".windsurfrules" ]
		, aiDirectories = [ ".windsurf" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "GitHub Copilot"
		, aiUrl = "https://github.com/features/copilot"
		, aiFiles = [ ".github/copilot-instructions.md" ]
		, aiDirectories = [] : List Text
		, aiGitNeedles =
			[ GitNeedle.GitCommitMessage
					"^Agent-Logs-Url: https://github.com/"
			, GitNeedle.GitAuthor
					"Copilot@users.noreply.github.com"
			]
		}
	, { aiName = "Aider"
		, aiUrl = "https://aider.chat"
		, aiFiles = [ ".aider.conf.yml", ".aiderignore", "CONVENTIONS.md" ]
		, aiDirectories = [ ".aider" ]
		, aiGitNeedles =
			[ GitNeedle.GitCommitMessage
					"^Co-Authored-By: aider"
			, GitNeedle.GitCommitMessage
					"^Assisted-by: aider"
			, GitNeedle.GitAuthor "(aider)"
			]
		}
	, { aiName = "Cline"
		, aiUrl = "https://github.com/cline/cline"
		, aiFiles = [ ".clinerules" ]
		, aiDirectories = [ ".clinerules" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Zed"
		, aiUrl = "https://zed.dev"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".zed" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Continue.dev"
		, aiUrl = "https://continue.dev"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".continue" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Kiro"
		, aiUrl = "https://kiro.dev"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".kiro" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Gemini CLI"
		, aiUrl = "https://developers.google.com/gemini-code-assist"
		, aiFiles = [ "GEMINI.md", "AGENT.md" ]
		, aiDirectories = [ ".gemini" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "AGENTS.md Standard"
		, aiUrl = "https://github.com/anthropics/agent-rules"
		, aiFiles = [ "AGENTS.md" ]
		, aiDirectories = [] : List Text
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Bolt"
		, aiUrl = "https://bolt.new"
		, aiFiles = [ ".bolt" ]
		, aiDirectories = [ ".bolt" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Replit Agent"
		, aiUrl = "https://replit.com"
		, aiFiles = [ ".replit" ]
		, aiDirectories = [ ".replit" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Codex CLI"
		, aiUrl = "https://github.com/openai/codex"
		, aiFiles = [ "codex.md" ]
		, aiDirectories = [ ".codex" ]
		, aiGitNeedles =
			[ GitNeedle.GitAuthor "Codex Text"
			, GitNeedle.GitCommitMessage
					"^Co-Authored-By: Codex"
			, GitNeedle.GitCommitMessage
					"^Assisted-by: Codex"
			]
		}
	, { aiName = "Tabnine"
		, aiUrl = "https://tabnine.com"
		, aiFiles = [ ".tabnine.json", "tabnine.yaml" ]
		, aiDirectories = [ ".tabnine" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Amazon Q Developer"
		, aiUrl = "https://aws.amazon.com/q/developer/"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".amazonq", ".q" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Sourcegraph Cody"
		, aiUrl = "https://sourcegraph.com/cody"
		, aiFiles = [ ".cody.json", "cody.json" ]
		, aiDirectories = [ ".cody" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Augment Code"
		, aiUrl = "https://augmentcode.com"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".augment" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	, { aiName = "Supermaven"
		, aiUrl = "https://supermaven.com"
		, aiFiles = [] : List Text
		, aiDirectories = [ ".supermaven" ]
		, aiGitNeedles = [] : List GitNeedle
		}
	]
in agents
