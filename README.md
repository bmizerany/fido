# Fido - he fetches

## Usage

    $ fido git://github.com/sinatra/sinatra.git
    $ cd sinatra
    $ git branch
    * master
    $ git log --format=%h | head -n1
    6d8b333

The second run will perform no operation because it's already been fetched.
This is for safety so any local work isn't interupted

    $ .. add file and commit
    $ cd ..
    $ fido git://github.com/sinatra/sinatra.git
    $ git log --format=%h | head -n1
    71435b7

## Branch failover
This is where fido becomes interesting

    $ fido git://github.com/sinatra/sinatra.git foo 0.3.x bar baz
    $ cd sinatra
    $ git branch
    * 0.3.x

We told fido we want to clone the sinatra repo and checkout one branch
with preference to `foo` if `origin/foo`, then `0.3.x`, etc.

## Destruction
After fido has fetched a repo he knows that it can be bad to interupt
any local work.  He can be told destruction is ok.

    $ fido git://github.com/sinatra/sinatra.git foo 0.3.x bar baz
    $ cd sinatra
    $ git branch
    * 0.3.x

    $ cd ..
    $ fido git://github.com/sinatra/sinatra.git -f 0.9.x
    $ cd sinatra
    $ git branch
      0.3.x
    * 0.9.x
