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

;; github workflows
(block_mapping_pair
    key: (flow_node) @_jobs
    (#eq? @_jobs "jobs")
    value: (block_node (block_mapping (block_mapping_pair value: (block_node (block_mapping (block_mapping_pair 
        key: (flow_node) @_steps
        (#eq? @_steps "steps")
        value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair 
            key: (flow_node) @_run
            (#eq? @_run "run")
            value: (flow_node) @bash
        ))))))
    ))))))
)
(block_mapping_pair
    key: (flow_node) @_jobs
    (#eq? @_jobs "jobs")
    value: (block_node (block_mapping (block_mapping_pair value: (block_node (block_mapping (block_mapping_pair 
        key: (flow_node) @_steps
        (#eq? @_steps "steps")
        value: (block_node (block_sequence (block_sequence_item (block_node (block_mapping (block_mapping_pair 
            key: (flow_node) @_run
            (#eq? @_run "run")
            value: (block_node (block_scalar) @bash)
            (#offset! @bash 1)
            (#colzero! @bash 1)
        ))))))
    ))))))
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
