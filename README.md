# HCC Dashboard

## Installation

Install the prereq mysql library:

    yum install mysql-devel

Install dashing with gems (requires 1.9+ ruby):

    gem install dashing
    gem install mysql

You will also need to install node.js.  I installed it from the Linux 
binaries tarball using the command:

    tar xzvf <nodejs.tar.gz> --strip-components=1 -C /usr/local

## Configuration

The HCC dashboard requires access to the HCC database to retrive college and
department information for users. A file named `db.yml` is required to be in
the root dashboard directory with information to connect to the DB:

    rcfmysql_username: user
    rcfmysql_pass: password
    rcfmysql_host: host
    rcfmysql_db: database



Check out http://shopify.github.com/dashing for more information.
