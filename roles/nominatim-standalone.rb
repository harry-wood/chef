name "nominatim-standalone"
description "Role applied to all stand-alone nominatim servers"

default_attributes(
  :apt => {
    :sources => ["postgresql"]
  },
  :postgresql => {
    :versions => ["9.4"]
  },
  :nominatim => {
    :enable_backup => false
  }
)

run_list(
  "role[nominatim]",
  "recipe[nominatim::standalone]"
)
