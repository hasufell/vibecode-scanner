# Vibecode scanner

This tool detects vibe coded projects. It can:

* scan hackage packages
* scan git repositories
* audit all dependencies of your current cabal project

It does so by analyzing:

* git history
* presence of agent files

## Known limitations

* we rely on git, so projects that use darcs or whatever won't work
* when scanning hackage packages we rely on `source repository head` stanza in the cabal file
  * without access to the git repo we can't do any interesting checks anyway
  * most cabal files only specify `head` and no tags, so we can't really check specific tags/versions
* since we don't want to depend on `cabal-install` for getting project dependencies we parse `plan.json` and do some overly simplistic tricks
  * we run `cabal get` to fetch packages, so complicated configs with remote tarballs and third party repos won't work

## TODO

- [ ] Dhall support to overwrite/extend the [agents definition](https://github.com/hasufell/vibecode-scanner/blob/master/lib/VibeCode/Agents.hs)

