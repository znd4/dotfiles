(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "run")
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (flow_node) @_command
        (#eq? @_command "command")
        value: (flow_node) @bash
        )
      )
    )
  )

(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "run")
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (flow_node) @_command
        (#eq? @_command "command")
        value: (block_node) @bash
        (#offset! @bash 1 0 0 0)
        (#colzero! @bash)
        )
      )
    )
  )
