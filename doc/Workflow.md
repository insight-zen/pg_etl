# Creating a GEM

## Start with a bare repository on github
* Keep it completely bare. Do not add any files to it.

## Build a new gem locally
Additional information at https://bundler.io/v2.2/guides/creating_gem.html

**Do not clone the github repo** in this step. We will do that after completing the initial setup.

`bundle gem pg_etl`

`git branch -M main`

This creates a `pg_etl` directory locally, which we will use to map the github repo. Work in the `main` branch and complete the local edits.

## Local Repo edit
* Edit README and remove the TODOs
* Copy .gitignore from pg_etl. This will exclude Gemfile.lock from the repo.
* Edit .gemspec, cleanup TODOs, add dependencies (gem and development)
  Testing gems such as simple_cov, byebug etc.
* Add/edit Guardfile Use pg_etl as reference
  Adjust the test file regex. We use test with code_test.rb - test as the suffix.
  'git add Guardfile`
* modify test_helper. Use pg_etl as reference.
  Add the AssertiveTest module to enable writing the tests in dsl format
* Copy .rubycop.yml to the gem root
  Even though a local copy of rubocop exists, this will ensure self contained linting.
* Check Rakefile

## Pre commit checks
#### Run bundle
`bundle install`

### Run rake and rake test
`rake test`

### Run rake rubocop and auto_correct
`rake rubocop`

`rake rubocop:auto_correct`

### Check git status
`git status`
* Ensure Gemfile.lock is **not** added to the git repo. Check the `.gitignore` in this gem as reference.

## Make a first commit
`git commit -a -m "First Commit that passes bundle, rake test"

## Push to github
`git branch -M main`

`git remote add origin git@github.com:insight-zen/pg_etl.git`

`git push -u origin main`
