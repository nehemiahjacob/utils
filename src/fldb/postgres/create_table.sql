-- $Id$

CREATE TABLE files (
    id bigserial PRIMARY KEY,
    idate time DEFAULT now(),
    sha1 varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    mtime timestamptz,
    ctime timestamptz,
    calctime real,
    path varchar,
    inode bigint,
    device varchar,
    hostname varchar,
    uid varchar,
    gid varchar,
    perm varchar,
    lastver varchar(40),
    nextver varchar(40),
    descr varchar
);

CREATE TABLE other (
    id bigserial PRIMARY KEY,
    idate time DEFAULT now(),
    kind varchar,
    sha1 varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    symlink varchar,
    mtime timestamptz,
    ctime timestamptz,
    calctime real,
    path varchar,
    inode bigint,
    device varchar,
    hostname varchar,
    uid varchar,
    gid varchar,
    perm varchar,
    lastver varchar(40),
    nextver varchar(40),
    descr varchar
);
