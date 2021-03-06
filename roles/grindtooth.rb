name "grindtooth"
description "Master role applied to grindtooth"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "em1",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.19"
      },
      :external_ipv4 => {
        :interface => "em2",
        :role => :external,
        :family => :inet,
        :address => "128.40.45.199"
      }
    }
  }
)

run_list(
  "role[ucl-wolfson]",
  "role[hp-dl360-g6]",
  "role[taginfo]"
)
