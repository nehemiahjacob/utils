-- $Id$

BEGIN ISOLATION LEVEL SERIALIZABLE;
    \echo
    \echo ================ Sett avstanden hjemmefra ================

    UPDATE logg SET avst = '(60.42543,5.29959)'::point <-> coor
        WHERE date > (
            SELECT laststed FROM stat
                WHERE lastupdate IS NOT NULL
                ORDER BY lastupdate DESC LIMIT 1
        );

    \echo
    \echo ================ Oppdater sted og dist ================

    UPDATE logg SET sted = clname(coor)
        WHERE date > (
            SELECT laststed FROM stat
                WHERE lastupdate IS NOT NULL
                ORDER BY lastupdate DESC LIMIT 1
        );
    UPDATE logg SET dist = cldist(coor)
        WHERE date > (
            SELECT laststed FROM stat
                WHERE lastupdate IS NOT NULL
                ORDER BY lastupdate DESC LIMIT 1
        );

    INSERT INTO stat (lastupdate, laststed) VALUES (
        now(),
        (SELECT max(date) FROM logg)
    );
COMMIT;
