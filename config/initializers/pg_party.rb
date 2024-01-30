# in a Rails initializer
PgParty.configure do |c|
  c.caching_ttl = 60
  c.schema_exclude_partitions = false
  c.include_subpartitions_in_partition_list = true
  c.create_template_tables = true
  c.create_with_primary_key = false
end