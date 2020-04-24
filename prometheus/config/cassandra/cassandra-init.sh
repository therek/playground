cat >/import.cql <<EOF
DROP keyspace cortex;
CREATE KEYSPACE cortex WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
EOF

# You may add some other conditionals that fits your stuation here
until cqlsh -f /import.cql; do
  echo "cqlsh: Cassandra is unavailable to initialize - will retry later"
  sleep 2
done &

exec /docker-entrypoint.sh "$@"
