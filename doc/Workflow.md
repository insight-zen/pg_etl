# Creating a GEM

## Start with a bare repository on github or GIT host and clone it locally
https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository
`git clone git@github.com:insight-zen/pg_etl.git`

Be sure to include `README.md`, `.gitignore` and `MIT License` in the repository.

## Build a new gem locally
Additional information at https://bundler.io/v2.2/guides/creating_gem.html

**Do not clone the github repo** in this step. We will do that after completing the initial setup.

`bundle gem pg_etl`

This creates a `pg_etl` directory locally, which we will use to map the github repo.

## Local Repo edit

### Edit README.md
Add a brief description here.

### Pre commit checks
#### Run bundle
The following checks ensure that all the prerequisites have been met.
`bundle`
* Check for any remaining TODOs or FIXes in the .gemspec
* Add the testing gems commonly used -- minitest_reporters, byebug, simple_cov etc. Refer to the .gemspec in this gem.

#### Run rake and rake test
`rake test`
* Add the needed prelude to test_helper. Refer to `test_helper` in this gem. It also adds rails style dsl for writing tests in a declarative syntax.
* Edit `Rakefile` to set the test file name convention regex. See the `Rakefile` in this gem.

`rake rubocop`
* Ensure the rubocop.yml the present in this gem maps to the standard in use.




`rake rubocop:auto_correct`
* Run this if needed. At this point the only ruby code is in test_helper.

#### Check git status
`git status`
* Ensure Gemfile.lock is **not** added to the git repo. Check the `.gitignore` in this gem as reference.

### Make a first commit
`git commit -a -m "First Commit that passes bundle, rake test"

### Push to github
`git remote add origin git@github.com:insight-zen/pg_etl.git`
git push -u origin main
