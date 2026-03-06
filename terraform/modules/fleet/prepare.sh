#!/bin/sh

echo "Preparing database..."

while i in {1..5} ; do
    if /usr/bin/fleet prepare db --rerun_migrations ; then
        exit 0
    fi

    sleep $((i * 4))
    echo "Database preparation failed. Retrying..."
done

if /usr/bin/fleet prepare db --rerun_migrations ; then
    exit 0
fi

echo "Database preparation failed after too many attempts."
exit 1